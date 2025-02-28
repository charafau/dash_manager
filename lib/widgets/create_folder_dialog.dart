import 'package:dash_manager/notifiers/create_folder_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateFolderDialog extends ConsumerWidget {
  final String currentPath;

  const CreateFolderDialog({super.key, required this.currentPath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(createFolderNotiferProvider);

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
              child: Text('Create folder', textAlign: TextAlign.left),
            ),
            Form(
              key: const ValueKey('create-folder-form'),
              child: TextField(
                autofocus: true,
                controller: notifier.pathTextController,
                onSubmitted: (value) async {
                  await _createFolder(notifier, context);
                },
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
          onPressed: () => _createFolder(notifier, context),
          child: const Text("Create"),
        ),
      ],
    );
  }

  Future<void> _createFolder(
    CreateFolderNotifer notifier,
    BuildContext context,
  ) async {
    final shouldClose = await notifier.crateFolder(currentPath);
    if (shouldClose) {
      //TODO: change this widget to stateful one
      if (context.mounted) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context, true);
      }
    }
  }
}
