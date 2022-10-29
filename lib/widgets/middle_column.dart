import 'package:dash_manager/notifiers/side_panel_focus_notifier.dart';
import 'package:dash_manager/widgets/file_column.dart';
import 'package:flutter/material.dart';

class MiddleColumns extends StatelessWidget {
  const MiddleColumns({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Row(
        children: const [
          FileColumn(
            color: Colors.amber,
            columnSide: SidePanelFocus.left,
          ),
          FileColumn(
            color: Colors.purple,
            columnSide: SidePanelFocus.right,
          ),
        ],
      ),
    );
  }
}
