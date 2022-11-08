// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;

import 'package:dash_manager/models/file_system_entity.dart';
import 'package:dash_manager/providers/home_directory_provider.dart';

final leftCommanderNotifierProvider =
    StateNotifierProvider<CommanderNotifier, CommanderNotifierState>(
  (ref) => CommanderNotifier(
    startDir: ref.read(homeDirectoryProvider),
  ),
);

final rightCommanderNotifierProvider =
    StateNotifierProvider<CommanderNotifier, CommanderNotifierState>(
  (ref) => CommanderNotifier(
    startDir: ref.read(homeDirectoryProvider),
  ),
);

class CommanderNotifier extends StateNotifier<CommanderNotifierState> {
  final String startDir;

  CommanderNotifier({required this.startDir})
      : super(CommanderNotifierState.empty()) {
    loadFiles(startDir);
  }

  Future<void> loadFiles(String path, {bool filterHiddenFiles = true}) async {
    Directory dir = Directory(path);

    final List<FileSystemEntity> entities =
        await dir.list(recursive: false).toList();

    var fsi = <FileSystemItem>[];

    entities.sort(((a, b) => a.path.compareTo(b.path)));

    fsi.add(FileSystemItem(
        entityType: FileSystemItemType.parent, name: '..', isHidden: false));

    entities.whereType<Directory>().forEach((element) {
      final name = p.basename(element.path);
      fsi.add(
        FileSystemItem(
            entityType: FileSystemItemType.directory,
            fileSystemEntity: element,
            name: name,
            isHidden: name.startsWith('.')),
      );
    });

    entities.whereType<File>().forEach((element) {
      final name = p.basename(element.path);
      fsi.add(
        FileSystemItem(
            entityType: FileSystemItemType.file,
            fileSystemEntity: element,
            name: name,
            isHidden: name.startsWith('.')),
      );
    });

    if (filterHiddenFiles) {
      fsi = fsi.where((f) => !f.isHidden).toList();
    }

    final globals = fsi.map((f) => GlobalKey(debugLabel: f.name)).toList();

    state = CommanderNotifierState(
      currentPath: path,
      pathItems: fsi,
      pathItemsKeys: globals,
      currentlySelectedItemIndex: -1,
    );
  }

  void openCurrentItem() {
    if (state.currentlySelectedItemIndex > -1) {
      var pathItem = state.pathItems[state.currentlySelectedItemIndex];
      if (pathItem.fileSystemEntity == null) {
        var parentOf = FileSystemEntity.parentOf(state.currentPath);
        loadFiles(parentOf, filterHiddenFiles: true);
      } else {
        if (pathItem.entityType == FileSystemItemType.directory) {
          loadFiles(pathItem.fileSystemEntity!.path, filterHiddenFiles: true);
        } else {
          OpenFile.open(pathItem.fileSystemEntity!.path);
        }
      }
    }
  }

  void setCurrentlySelectedIndex(int index) {
    state = state.copyWith(currentlySelectedItemIndex: index);
  }

  void goToNextItem() {
    if (state.currentlySelectedItemIndex < state.pathItems.length - 1) {
      setCurrentlySelectedIndex(state.currentlySelectedItemIndex + 1);
    }
  }

  void goToPreviousItem() {
    if (state.currentlySelectedItemIndex > 0) {
      setCurrentlySelectedIndex(state.currentlySelectedItemIndex - 1);
    } else {
      setCurrentlySelectedIndex(0);
    }
  }

  void goToFirstItem() {
    setCurrentlySelectedIndex(0);
  }

  void goToLastItem() {
    setCurrentlySelectedIndex(state.pathItems.length - 1);
  }
}

class CommanderNotifierState {
  final String currentPath;
  final List<FileSystemItem> pathItems;
  final List<GlobalKey> pathItemsKeys;
  final int currentlySelectedItemIndex;

  CommanderNotifierState({
    required this.currentPath,
    required this.pathItems,
    required this.pathItemsKeys,
    this.currentlySelectedItemIndex = -1,
  });

  int get numberOfHiddenFiles => pathItems.where((f) => !f.isHidden).length;

  List<FileSystemItem> get nonHiddenFiles =>
      pathItems.where((f) => !f.isHidden).toList();

  factory CommanderNotifierState.empty() => CommanderNotifierState(
        currentPath: '',
        pathItems: [],
        pathItemsKeys: [],
      );

  CommanderNotifierState copyWith({
    String? currentPath,
    List<FileSystemItem>? pathItems,
    List<GlobalKey>? pathItemsKeys,
    int? currentlySelectedItemIndex,
  }) {
    return CommanderNotifierState(
      currentPath: currentPath ?? this.currentPath,
      pathItems: pathItems ?? this.pathItems,
      currentlySelectedItemIndex:
          currentlySelectedItemIndex ?? this.currentlySelectedItemIndex,
      pathItemsKeys: pathItemsKeys ?? this.pathItemsKeys,
    );
  }

  BuildContext getItemContext(int index) =>
      pathItemsKeys[index].currentContext!;

  FileSystemItem? get currentFileSystemItem => currentlySelectedItemIndex > -1
      ? pathItems[currentlySelectedItemIndex]
      : null;

  @override
  String toString() =>
      'CommanderNotifierState(currentPath: $currentPath, files: $pathItems, currentlySelectedItemIndex: $currentlySelectedItemIndex)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CommanderNotifierState &&
        other.currentPath == currentPath &&
        listEquals(other.pathItems, pathItems) &&
        other.currentlySelectedItemIndex == currentlySelectedItemIndex;
  }

  @override
  int get hashCode =>
      currentPath.hashCode ^
      pathItems.hashCode ^
      currentlySelectedItemIndex.hashCode;
}
