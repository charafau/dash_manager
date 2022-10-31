import 'dart:io';

import 'package:dash_manager/models/file_system_entity.dart';
import 'package:dash_manager/notifiers/commander_notifier.dart';
import 'package:dash_manager/notifiers/side_panel_focus_notifier.dart';
import 'package:dash_manager/providers/home_directory_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';

class FileColumn extends ConsumerStatefulWidget {
  final Color color;
  final SidePanelFocus columnSide;

  const FileColumn({
    Key? key,
    required this.color,
    required this.columnSide,
  }) : super(key: key);
  @override
  ConsumerState<FileColumn> createState() => _FileColumnState();
}

class _FileColumnState extends ConsumerState<FileColumn> {
  final double itemHeight = 28;

  List<FileSystemItem> pathItems = [];
  List<GlobalKey> pathItemsKeys = [];

  late CommanderController commanderNotifier;
  int currentlySelectedItemIndex = -1;
  late FocusNode keyboardListenerFocusNode;
  String currentPath = '';

  @override
  void initState() {
    super.initState();
    keyboardListenerFocusNode =
        FocusNode(debugLabel: 'file column ${widget.columnSide}');

    commanderNotifier = ref.read(commanderControllerProvider);
    final homePath = ref.read(homeDirectoryProvider);
    currentPath = homePath;

    _loadItemsForPath(homePath);
  }

  void _loadItemsForPath(String path) {
    commanderNotifier.loadFiles(path).then((value) {
      pathItems = value;
      for (var element in value) {
        pathItemsKeys.add(GlobalKey(debugLabel: element.name));
      }

      currentlySelectedItemIndex = -1;
      currentPath = path;
      setState(() {});
    });
  }

  Future scrollToItem(int index) async {
    final context = pathItemsKeys[index].currentContext!;

    await Scrollable.ensureVisible(context,
        alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
        alignment: 0.5);
  }

  @override
  Widget build(BuildContext context) {
    final side = ref.watch(sidePanelFocusNotifierProvider);
    final sidePanelFocusNotifier =
        ref.watch(sidePanelFocusNotifierProvider.notifier);

    return Flexible(
      child: Focus(
        onKey: (focusNode, keyboard) {
          focusNode.requestFocus();

          if (side == widget.columnSide) {
            if (keyboard is RawKeyDownEvent) {
              print(keyboard.data.logicalKey);
              if (keyboard.data.logicalKey == LogicalKeyboardKey.arrowDown) {
                if (currentlySelectedItemIndex < pathItems.length - 1) {
                  setState(() {
                    currentlySelectedItemIndex++;
                  });
                }
              } else if (keyboard.data.logicalKey ==
                  LogicalKeyboardKey.arrowUp) {
                if (currentlySelectedItemIndex > 0) {
                  setState(() {
                    currentlySelectedItemIndex--;
                  });
                }
              } else if (keyboard.data.logicalKey == LogicalKeyboardKey.home) {
                setState(() {
                  currentlySelectedItemIndex = 0;
                });
              } else if (keyboard.data.logicalKey == LogicalKeyboardKey.end) {
                setState(() {
                  currentlySelectedItemIndex = pathItems.length - 1;
                });
              } else if (keyboard.data.logicalKey == LogicalKeyboardKey.space) {
                sidePanelFocusNotifier.changeSide();
              } else if (keyboard.data.logicalKey == LogicalKeyboardKey.enter) {
                if (currentlySelectedItemIndex > -1) {
                  var pathItem = pathItems[currentlySelectedItemIndex];
                  if (pathItem.fileSystemEntity == null) {
                    var parentOf = FileSystemEntity.parentOf(currentPath);
                    print('parent path $parentOf');
                    _loadItemsForPath(parentOf);
                  } else {
                    if (pathItem.entityType == FileSystemItemType.directory) {
                      _loadItemsForPath(pathItem.fileSystemEntity!.path);
                    } else {
                      OpenFile.open(pathItem.fileSystemEntity!.path);
                    }
                  }
                }
              }

              if (currentlySelectedItemIndex > -1) {
                scrollToItem(currentlySelectedItemIndex);
              }
            }
          }

          return KeyEventResult.handled;
        },
        descendantsAreFocusable: false,
        focusNode: keyboardListenerFocusNode,
        child: Container(
          color: widget.color,
          child: SingleChildScrollView(
            child: Column(
              children: pathItems
                  .asMap()
                  .entries
                  .map(
                    (item) => InkWell(
                      key: pathItemsKeys[item.key],
                      onTap: () {
                        setState(() {
                          currentlySelectedItemIndex = item.key;
                        });
                        scrollToItem(currentlySelectedItemIndex);
                        keyboardListenerFocusNode.requestFocus();
                        sidePanelFocusNotifier.changeSide(
                            side: widget.columnSide);
                      },
                      onDoubleTap: () => commanderNotifier.open(item.value),
                      child: Container(
                        height: 28,
                        color: currentlySelectedItemIndex == item.key
                            ? Colors.pink
                            : null,
                        child: Row(
                          children: [
                            Icon(
                                item.value.entityType == FileSystemItemType.file
                                    ? Icons.file_copy
                                    : Icons.folder),
                            Text(item.value.name),
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
}

enum FileColumnSide { left, right }

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
