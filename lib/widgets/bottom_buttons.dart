import 'dart:io';

import 'package:dash_manager/widgets/copy_confirm_dialog.dart';
import 'package:dash_manager/widgets/copy_dialog.dart';
import 'package:flutter/material.dart';

const maxChunkSize = 1024;

class BottomButtons extends StatelessWidget {
  const BottomButtons({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      width: double.infinity,
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton(onPressed: () {}, child: const Text('F3 View')),
          TextButton(onPressed: () {}, child: const Text('F4 Edit')),
          TextButton(
              onPressed: () {
                _getChunkStream();
              },
              child: const Text('F5 Copy')),
          TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return const CopyDialog();
                  },
                );
              },
              child: const Text('F6 Move')),
          TextButton(
              onPressed: () async {
                final shouldCopy = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return const CopyConfirmDialog(
                      copyDestination: '',
                      copyItem: 'bigfile.img',
                    );
                  },
                );

                print('should copy ? $shouldCopy');

                // get which is selected column
                // start copying and show copy dialog
              },
              child: const Text('F7 New Folder')),
          TextButton(onPressed: () {}, child: const Text('F8 Delete')),
          TextButton(onPressed: () {}, child: const Text('ALT+F4 Exit')),
        ],
      ),
    );
  }

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
      },
      onDone: () {
        // print('got all chunks: $chunks');
        print('copied whole file');
      },
    );
  }
}
