import 'dart:io';

import 'package:dash_manager/models/file_system_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class DeleteDialog extends StatefulWidget {
  final List<FileSystemItem> itemsToDelete;

  const DeleteDialog({
    super.key,
    required this.itemsToDelete,
  });

  @override
  State<DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {
  @override
  void initState() {
    super.initState();
    _deleteFiles();
  }

  double percentage = 0.0;

  Future<void> _deleteFiles() async {
    int itemCount = 1;
    for (var item in widget.itemsToDelete) {
      await item.fileSystemEntity?.delete();
      percentage = clampDouble(
          (itemCount * 100) / widget.itemsToDelete.length, 0.0, 1.0);
    }

    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Copy"),
      content: SizedBox(
        width: 600,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Coping file: bigfile.img"),
            const SizedBox(height: 16),
            LinearPercentIndicator(
              width: 560,
              lineHeight: 18.0,
              percent: percentage,
              center: Text("${(percentage * 100).toStringAsFixed(1)}%"),
              backgroundColor: Colors.grey,
              progressColor: Colors.blue,
              alignment: MainAxisAlignment.center,
            ),
          ],
        ),
      ),
      actions: [
        // TextButton(
        //   onPressed: () {
        //     _getChunkStream();
        //   },
        //   child: const Text("Copy"),
        //   // onPressed: () => Navigator.pop(context),
        // ),
        TextButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        // FlatButton(
        //   child: Text("OK"),
        //   onPressed: () => print('OK'),
        // ),
      ],
    );
  }
}
