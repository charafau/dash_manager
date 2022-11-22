import 'package:dash_manager/models/file_system_entity.dart';
import 'package:dash_manager/notifiers/commander_notifier.dart';
import 'package:dash_manager/notifiers/side_panel_focus_notifier.dart';
import 'package:dash_manager/widgets/copy_confirm_dialog.dart';
import 'package:dash_manager/widgets/copy_dialog.dart';
import 'package:dash_manager/widgets/create_folder_dialog.dart';
import 'package:dash_manager/widgets/delete_confirm_dialog.dart';
import 'package:dash_manager/widgets/delete_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:data_table_2/data_table_2.dart';

class FileColumn extends ConsumerWidget {
  // final Color color;
  final SidePanelFocus columnSide;
  final FocusNode opposidePanelFocusNode;
  final FocusNode panelFocusNode;
  ScrollController scrollController = ScrollController();

  FileColumn({
    Key? key,
    // required this.color,
    required this.columnSide,
    required this.opposidePanelFocusNode,
    required this.panelFocusNode,
  }) : super(key: key);
  final double itemHeight = 28;

  Future scrollToCurrentItem(CommanderNotifierState state, int index) async {
    // await Scrollable.ensureVisible(state.getItemContext(index),
    //     alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
    //     alignment: 0.5);
    scrollController.jumpTo(index.toDouble());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final side = ref.watch(sidePanelFocusNotifierProvider);

    late CommanderNotifier commanderNotifier;
    late CommanderNotifierState state;
    if (columnSide == SidePanelFocus.left) {
      commanderNotifier = ref.watch(leftCommanderNotifierProvider.notifier);
      state = ref.watch(leftCommanderNotifierProvider);
    } else {
      commanderNotifier = ref.watch(rightCommanderNotifierProvider.notifier);
      state = ref.watch(rightCommanderNotifierProvider);
    }
    final sidePanelFocusNotifier =
        ref.watch(sidePanelFocusNotifierProvider.notifier);

    return Focus(
        onKey: (focusNode, keyboard) {
          if (side == columnSide) {
            // focusNode.requestFocus();
            panelFocusNode.requestFocus();
            if (keyboard is RawKeyDownEvent) {
              print('key ${keyboard.data.logicalKey}');
              if (keyboard.data.logicalKey == LogicalKeyboardKey.arrowDown) {
                commanderNotifier.goToNextItem();
              } else if (keyboard.data.logicalKey ==
                  LogicalKeyboardKey.arrowUp) {
                commanderNotifier.goToPreviousItem();
              } else if (keyboard.data.logicalKey == LogicalKeyboardKey.home) {
                commanderNotifier.goToFirstItem();
              } else if (keyboard.data.logicalKey == LogicalKeyboardKey.end) {
                commanderNotifier.goToLastItem();
              } else if (keyboard.data.logicalKey == LogicalKeyboardKey.tab) {
                sidePanelFocusNotifier.changeSide();
                opposidePanelFocusNode.requestFocus();
              } else if (keyboard.data.logicalKey == LogicalKeyboardKey.enter) {
                commanderNotifier.openCurrentItem();
              } else if (keyboard.data.logicalKey == LogicalKeyboardKey.f5) {
                // copy
                final fileSystemItem = state.currentFileSystemItem;
                if (fileSystemItem != null) {
                  copyFile(
                    context,
                    fileSystemItem,
                    ref,
                  ).then((value) {
                    if (value) {
                      _reloadOpposidePanel(ref, side);
                    }
                  });
                }
              } else if (keyboard.data.logicalKey == LogicalKeyboardKey.f7) {
                showCreateFolderDialog(context, state.currentPath)
                    .then((value) {
                  if (value) {
                    commanderNotifier.reloadCurrentFolder();
                  }
                });
              } else if (keyboard.data.logicalKey == LogicalKeyboardKey.f8) {
                if (state.currentFileSystemItem != null) {
                  showDeleteDialog(context, [state.currentFileSystemItem!.name])
                      .then((value) {
                    if (value) {
                      showDialog(
                        context: context,
                        builder: (context) => DeleteDialog(
                          itemsToDelete: [state.currentFileSystemItem!],
                        ),
                      ).then((value) {
                        commanderNotifier.reloadCurrentFolder();
                      });
                    }
                  });
                }
              }

              if (state.currentlySelectedItemIndex > -1) {
                scrollToCurrentItem(state, state.currentlySelectedItemIndex);
              }
            }
          }

          return KeyEventResult.handled;
        },
        descendantsAreFocusable: false,
        focusNode: panelFocusNode,
        child: CustomScrollView(
          slivers: [
            // child: ,
            SliverAppBar(
              toolbarHeight: 20,
              titleSpacing: 0,
              elevation: 0,
              pinned: true,
              title: SingleRowItem(
                  name: 'Name', ext: 'Ext', size: 'Size', date: 'Date'),
            ),
            SliverFixedExtentList(
              itemExtent: 20,
              delegate: SliverChildBuilderDelegate(
                childCount: state.pathItems.length,
                (context, index) {
                  final item = state.pathItems[index];
                  return SingleRowItem(
                      key: state.pathItemsKeys[index],
                      name: item.name,
                      ext: 'ext',
                      size: '123kb',
                      date: '2022-02-10 12:12:12');
                },
              ),
            )
          ],
        ));
  }

  void _reloadOpposidePanel(WidgetRef ref, SidePanelFocus side) {
    _getNotifier(
            ref,
            side == SidePanelFocus.left
                ? SidePanelFocus.right
                : SidePanelFocus.left)
        .reloadCurrentFolder();
  }

  Future<bool> copyFile(BuildContext context, FileSystemItem fileSystemItem,
      WidgetRef ref) async {
    late CommanderNotifierState opposideState;

    if (columnSide == SidePanelFocus.right) {
      opposideState = ref.watch(leftCommanderNotifierProvider);
    } else {
      opposideState = ref.watch(rightCommanderNotifierProvider);
    }

    final shouldCopy = await showDialog<bool>(
      context: context,
      builder: (context) {
        return CopyConfirmDialog(
          copyDestination: opposideState.currentPath,
          copyItem: fileSystemItem.fileSystemEntity!.path,
        );
      },
    );

    if (shouldCopy != null && shouldCopy) {
      await showDialog(
        context: context,
        builder: (context) => CopyDialog(
          copyDestination: opposideState.currentPath,
          copyItem: fileSystemItem,
        ),
      );

      return true;
    }

    return false;
  }

  Future<bool> showCreateFolderDialog(
      BuildContext context, String currentPath) async {
    return await showDialog(
      context: context,
      builder: (context) => CreateFolderDialog(
        currentPath: currentPath,
      ),
    );
  }

  Future<bool> showDeleteDialog(
      BuildContext context, List<String> items) async {
    return await showDialog(
      context: context,
      builder: (context) => DeleteConfirmDialog(
        deleteItems: items,
      ),
    );
  }

  CommanderNotifier _getNotifier(WidgetRef ref, SidePanelFocus side) {
    late CommanderNotifier notifier;

    if (columnSide == SidePanelFocus.right) {
      notifier = ref.watch(leftCommanderNotifierProvider.notifier);
    } else {
      notifier = ref.watch(rightCommanderNotifierProvider.notifier);
    }
    return notifier;
  }
}

class SingleRowItem extends StatelessWidget {
  final String name;
  final String ext;
  final String size;
  final String date;

  const SingleRowItem({
    Key? key,
    required this.name,
    required this.ext,
    required this.size,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
            flex: 5,
            child: Container(
                color: Colors.red,
                child: Text(
                  name,
                  style: TextStyle(fontSize: 12),
                ))),
        Expanded(
            flex: 1,
            child: Container(
                color: Colors.green,
                child: Text(
                  ext,
                  style: TextStyle(fontSize: 12),
                ))),
        Expanded(
            flex: 1,
            child: Container(
                color: Colors.blue,
                child: Text(
                  size,
                  style: TextStyle(fontSize: 12),
                ))),
        Expanded(
            flex: 1,
            child: Container(
                color: Colors.yellow,
                child: Text(
                  date,
                  style: TextStyle(fontSize: 12),
                ))),
      ],
    );
  }
}

enum FileColumnSide { left, right }

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

// child: DataTable2(
//     scrollController: scrollController,
//     columns: const [
//       DataColumn2(label: Text('#'), fixedWidth: 14),
//       DataColumn2(label: Text('Name')),
//       DataColumn2(label: Text('Ext'), fixedWidth: 170),
//       DataColumn2(label: Text('Size'), fixedWidth: 170),
//       DataColumn2(label: Text('Date'), fixedWidth: 170),
//     ],
//     rows: state.pathItems
//         .asMap()
//         .entries
//         .map(
//           (item) => DataRow2(
//             key: state.pathItemsKeys[item.key],
//             color: MaterialStateProperty.resolveWith((states) {
//               if (state.currentlySelectedItemIndex == item.key) {
//                 return MacosColors.controlAccentColor;
//               }

//               return item.key % 2 == 0
//                   ? MacosColors.controlBackgroundColor
//                   : Colors.grey.shade200;
//             }),
//             cells: [
//               DataCell(
//                 Icon(item.value.entityType == FileSystemItemType.file
//                     ? Icons.file_copy
//                     : Icons.folder),
//               ),
//               DataCell(Text(item.value.name)),
//               DataCell(Text(item.value.entityType.name)),
//               DataCell(Text('123')),
//               DataCell(Text(DateTime.now().toString())),
//             ],
//           ),
//         )
//         .toList()),
