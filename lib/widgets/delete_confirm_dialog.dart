import 'package:flutter/material.dart';

class DeleteConfirmDialog extends StatefulWidget {
  final List<String> deleteItems;

  const DeleteConfirmDialog({super.key, required this.deleteItems});

  @override
  State<DeleteConfirmDialog> createState() => _DeleteConfirmDialogState();
}

class _DeleteConfirmDialogState extends State<DeleteConfirmDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: 600,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Delete',
                textAlign: TextAlign.left,
              ),
            ),
            Text(
                'Would you like to remove ${widget.deleteItems.length} items?'),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () => Navigator.pop(context, false),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          autofocus: true,
          child: const Text("Confirm"),
        ),
      ],
    );
  }
}
