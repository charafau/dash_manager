import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class CopyDialog extends StatefulWidget {
  const CopyDialog({super.key});

  @override
  State<CopyDialog> createState() => _CopyDialogState();
}

class _CopyDialogState extends State<CopyDialog> {
  @override
  void initState() {
    super.initState();
  }

  double percentage = 0.0;

  Future<void> _getChunkStream() async {
    // print("reading from $start to $end");
    File file = File('\$HOME/cop/source/bigfile.img');
    final stat = await file.stat();
    // File file = File('/home/charafau/cop/source/lorem.txt');
    final Stream<List<int>> read = file.openRead();
    // final blob = file.slice(start, end);
    // reader.readAsArrayBuffer(blob);
    // await reader.onLoad.first;
    int chunkSize = 64 * 1024;
    int chunks = 0;
    read.listen(
      (List<int> event) {
        // print('got chunk of data $event');
        // print('got chunk of data');
        chunks++;
        print('Copied percentage: ${(chunkSize * chunks) / stat.size}');

        percentage = clampDouble((chunkSize * chunks) / stat.size, 0.0, 1.0);
        setState(() {});
      },
      onDone: () {
        // print('got all chunks: $chunks');
        print('copied whole file');
      },
    );
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
        TextButton(
          onPressed: () {
            _getChunkStream();
          },
          child: const Text("Copy"),
          // onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: const Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
        // FlatButton(
        //   child: Text("OK"),
        //   onPressed: () => print('OK'),
        // ),
      ],
    );
  }
}
