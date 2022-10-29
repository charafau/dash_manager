import 'package:flutter/material.dart';

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
          TextButton(onPressed: () {}, child: const Text('F5 Copy')),
          TextButton(onPressed: () {}, child: const Text('F6 Move')),
          TextButton(onPressed: () {}, child: const Text('F7 New Folder')),
          TextButton(onPressed: () {}, child: const Text('F8 Delete')),
          TextButton(onPressed: () {}, child: const Text('ALT+F4 Exit')),
        ],
      ),
    );
  }
}
