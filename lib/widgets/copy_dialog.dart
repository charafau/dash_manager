import 'dart:io';

import 'package:dash_manager/models/file_system_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class CopyDialog extends StatefulWidget {
  final FileSystemItem copyItem;
  final String copyDestination;

  const CopyDialog({
    super.key,
    required this.copyDestination,
    required this.copyItem,
  });

  @override
  State<CopyDialog> createState() => _CopyDialogState();
}

class _CopyDialogState extends State<CopyDialog> {
  @override
  void initState() {
    super.initState();
    _getChunkStream();
  }

  late Stream<List<int>> inputFileStream;
  late IOSink outputStream;
  double percentage = 0.0;

  Future<void> _getChunkStream() async {
    File file = File(widget.copyItem.fileSystemEntity!.path);
    final stat = await file.stat();

    outputStream =
        File('${widget.copyDestination}/${widget.copyItem.name}').openWrite();

    inputFileStream = file.openRead();
    int chunkSize = 64 * 1024;
    int chunks = 0;
    inputFileStream.listen(
      (List<int> event) {
        chunks++;
        outputStream.add(event);

        percentage = clampDouble((chunkSize * chunks) / stat.size, 0.0, 1.0);
        setState(() {});
      },
      onDone: () {
        outputStream.flush();

        if (context.mounted) {
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop();
        }
      },
    );
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
