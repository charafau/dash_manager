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

class FileColumn extends ConsumerWidget {
  // final Color color;
  final SidePanelFocus columnSide;
  final FocusNode opposidePanelFocusNode;
  final FocusNode panelFocusNode;

  const FileColumn({
    super.key,
    // required this.color,
    required this.columnSide,
    required this.opposidePanelFocusNode,
    required this.panelFocusNode,
  });
  final double itemHeight = 28;

  Future scrollToCurrentItem(CommanderNotifierState state, int index) async {
    await Scrollable.ensureVisible(
      state.getItemContext(index),
      alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
      alignment: 0.5,
    );
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
    final sidePanelFocusNotifier = ref.watch(
      sidePanelFocusNotifierProvider.notifier,
    );

    return Flexible(
      child: Focus(
        onKeyEvent: (FocusNode node, KeyEvent event) {
          if (side == columnSide) {
            // focusNode.requestFocus();
            panelFocusNode.requestFocus();
            if (event is KeyDownEvent) {
              if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
                commanderNotifier.goToNextItem();
              } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
                commanderNotifier.goToPreviousItem();
              } else if (event.logicalKey == LogicalKeyboardKey.home) {
                commanderNotifier.goToFirstItem();
              } else if (event.logicalKey == LogicalKeyboardKey.end) {
                commanderNotifier.goToLastItem();
              } else if (event.logicalKey == LogicalKeyboardKey.tab) {
                sidePanelFocusNotifier.changeSide();
                opposidePanelFocusNode.requestFocus();
              } else if (event.logicalKey == LogicalKeyboardKey.enter) {
                commanderNotifier.openCurrentItem();
              } else if (event.logicalKey == LogicalKeyboardKey.f5) {
                // copy
                final fileSystemItem = state.currentFileSystemItem;
                if (fileSystemItem != null) {
                  copyFile(context, fileSystemItem, ref).then((value) {
                    if (value) {
                      _reloadOpposidePanel(ref, side);
                    }
                  });
                }
              } else if (event.logicalKey == LogicalKeyboardKey.f7) {
                showCreateFolderDialog(context, state.currentPath).then((
                  value,
                ) {
                  if (value) {
                    commanderNotifier.reloadCurrentFolder();
                  }
                });
              } else if (event.logicalKey == LogicalKeyboardKey.f8) {
                if (state.currentFileSystemItem != null) {
                  showDeleteDialog(context, [
                    state.currentFileSystemItem!.name,
                  ]).then((value) {
                    if (value) {
                      showDialog(
                        context: context,
                        builder:
                            (context) => DeleteDialog(
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
        child: SizedBox(
          height: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              children:
                  state.pathItems
                      .asMap()
                      .entries
                      .map(
                        (item) => InkWell(
                          key: state.pathItemsKeys[item.key],
                          onTap: () {
                            commanderNotifier.setCurrentlySelectedIndex(
                              item.key,
                            );
                            panelFocusNode.requestFocus();
                            sidePanelFocusNotifier.changeSide(side: columnSide);
                          },
                          onDoubleTap:
                              () => commanderNotifier.openCurrentItem(),
                          child: Container(
                            height: 28,
                            color:
                                state.currentlySelectedItemIndex == item.key
                                    ? MacosColors.controlAccentColor
                                    : null,
                            child: Row(
                              children: [
                                Icon(
                                  item.value.entityType ==
                                          FileSystemItemType.file
                                      ? Icons.file_copy
                                      : Icons.folder,
                                ),
                                Flexible(
                                  child: Text(
                                    item.value.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color:
                                          state.currentlySelectedItemIndex ==
                                                  item.key
                                              ? Colors.white
                                              : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _reloadOpposidePanel(WidgetRef ref, SidePanelFocus side) {
    _getNotifier(
      ref,
      side == SidePanelFocus.left ? SidePanelFocus.right : SidePanelFocus.left,
    ).reloadCurrentFolder();
  }

  Future<bool> copyFile(
    BuildContext context,
    FileSystemItem fileSystemItem,
    WidgetRef ref,
  ) async {
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
        builder:
            (context) => CopyDialog(
              copyDestination: opposideState.currentPath,
              copyItem: fileSystemItem,
            ),
      );

      return true;
    }

    return false;
  }

  Future<bool> showCreateFolderDialog(
    BuildContext context,
    String currentPath,
  ) async {
    return await showDialog(
      context: context,
      builder: (context) => CreateFolderDialog(currentPath: currentPath),
    );
  }

  Future<bool> showDeleteDialog(
    BuildContext context,
    List<String> items,
  ) async {
    return await showDialog(
      context: context,
      builder: (context) => DeleteConfirmDialog(deleteItems: items),
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

enum FileColumnSide { left, right }

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
