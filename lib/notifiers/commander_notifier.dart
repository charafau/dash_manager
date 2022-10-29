// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;

import 'package:dash_manager/models/file_system_entity.dart';
import 'package:dash_manager/providers/home_directory_provider.dart';

final commanderControllerProvider = Provider<CommanderController>(
  (ref) => CommanderController(
    startDir: ref.read(homeDirectoryProvider),
  ),
);

class CommanderController {
  final String startDir;

  CommanderController({required this.startDir}) {
    loadFiles(startDir);
  }

  Future<List<FileSystemItem>> loadFiles(String path) async {
    Directory dir = Directory(path);

    final List<FileSystemEntity> entities =
        await dir.list(recursive: false).toList();

    final fsi = <FileSystemItem>[];

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

    return fsi;
  }

  void open(FileSystemItem item) {
    if (item.entityType == FileSystemItemType.directory) {
      if (item.fileSystemEntity != null) {
        loadFiles(item.fileSystemEntity!.path);
      } else {
        // go to parent
      }
    } else {
      OpenFile.open(item.fileSystemEntity!.path);
    }
  }
}

class CommanderNotifierState {
  final String currentPath;
  final List<FileSystemItem> files;
  final int? currentlySelectedItemIndex;

  CommanderNotifierState({
    required this.currentPath,
    required this.files,
    this.currentlySelectedItemIndex,
  });

  int get numberOfHiddenFiles => files.where((f) => !f.isHidden).length;

  List<FileSystemItem> get nonHiddenFiles =>
      files.where((f) => !f.isHidden).toList();

  factory CommanderNotifierState.empty() => CommanderNotifierState(
        currentPath: '',
        files: [],
      );

  CommanderNotifierState copyWith({
    String? currentPath,
    List<FileSystemItem>? files,
    int? currentlySelectedItemIndex,
  }) {
    return CommanderNotifierState(
      currentPath: currentPath ?? this.currentPath,
      files: files ?? this.files,
      currentlySelectedItemIndex:
          currentlySelectedItemIndex ?? this.currentlySelectedItemIndex,
    );
  }

  @override
  String toString() =>
      'CommanderNotifierState(currentPath: $currentPath, files: $files, currentlySelectedItemIndex: $currentlySelectedItemIndex)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CommanderNotifierState &&
        other.currentPath == currentPath &&
        listEquals(other.files, files) &&
        other.currentlySelectedItemIndex == currentlySelectedItemIndex;
  }

  @override
  int get hashCode =>
      currentPath.hashCode ^
      files.hashCode ^
      currentlySelectedItemIndex.hashCode;
}
