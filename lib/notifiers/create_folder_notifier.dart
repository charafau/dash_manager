import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final createFolderNotiferProvider =
    Provider.autoDispose((ref) => CreateFolderNotifer());

class CreateFolderNotifer {
  final TextEditingController pathTextController = TextEditingController();

  Future<bool> crateFolder(String path) async {
    if (path.isNotEmpty && pathTextController.text.isNotEmpty) {
      var directory = Directory('$path/${pathTextController.text}');

      if (!directory.existsSync()) {
        await directory.create();
      }
      return true;
    }

    return false;
  }
}
