import 'package:flutter/cupertino.dart';
import 'package:macos_ui/macos_ui.dart';

class TopToolbar extends StatelessWidget {
  const TopToolbar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ToolBar(
        title: const Text('Home'),
        titleWidth: 200.0,
        leading: const SizedBox(width: 28),
        actions: [
          ToolBarIconButton(
            label: "Add",
            icon: const MacosIcon(
              CupertinoIcons.add_circled,
            ),
            onPressed: () => debugPrint("Add..."),
            showLabel: true,
          ),
          const ToolBarSpacer(),
          ToolBarIconButton(
            label: "Delete",
            icon: const MacosIcon(
              CupertinoIcons.trash,
            ),
            onPressed: () => debugPrint("Delete"),
            showLabel: false,
          ),
          ToolBarPullDownButton(
            label: "Actions",
            icon: CupertinoIcons.ellipsis_circle,
            items: [
              MacosPulldownMenuItem(
                label: "New Folder",
                title: const Text("New Folder"),
                onTap: () => debugPrint("Creating new folder..."),
              ),
              MacosPulldownMenuItem(
                label: "Open",
                title: const Text("Open"),
                onTap: () => debugPrint("Opening..."),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
