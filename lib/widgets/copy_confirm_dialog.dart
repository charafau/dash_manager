import 'package:flutter/material.dart';

class CopyConfirmDialog extends StatefulWidget {
  final String copyItem;
  final String copyDestination;

  const CopyConfirmDialog(
      {super.key, required this.copyItem, required this.copyDestination});

  @override
  State<CopyConfirmDialog> createState() => _CopyConfirmDialogState();
}

class _CopyConfirmDialogState extends State<CopyConfirmDialog> {
  late TextEditingController pathTextController;
  final Key _formKey = const ValueKey('copy-form');

  @override
  void initState() {
    super.initState();
    pathTextController = TextEditingController();
    pathTextController.text = widget.copyDestination;
  }

  @override
  void dispose() {
    pathTextController.dispose();
    super.dispose();
  }

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
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Copy "${widget.copyItem}" to:',
                textAlign: TextAlign.left,
              ),
            ),
            Form(
              key: _formKey,
              child: TextField(
                autofocus: true,
                controller: pathTextController,
                onSubmitted: (value) => Navigator.pop(context, true),
              ),
            ),
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
          child: const Text("Copy"),
        ),
      ],
    );
  }
}
