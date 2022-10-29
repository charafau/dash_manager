import 'dart:io';

class FileSystemItem {
  final FileSystemItemType entityType;
  final FileSystemEntity? fileSystemEntity;
  final String name;
  final bool isHidden;

  FileSystemItem({
    required this.entityType,
    this.fileSystemEntity,
    required this.name,
    required this.isHidden,
  });
}

enum FileSystemItemType { file, directory, parent }
