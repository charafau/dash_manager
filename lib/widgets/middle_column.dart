import 'package:dash_manager/notifiers/side_panel_focus_notifier.dart';
import 'package:dash_manager/widgets/file_column.dart';
import 'package:flutter/material.dart';

class MiddleColumns extends StatefulWidget {
  const MiddleColumns({
    Key? key,
  }) : super(key: key);

  @override
  State<MiddleColumns> createState() => _MiddleColumnsState();
}

class _MiddleColumnsState extends State<MiddleColumns> {
  late FocusNode leftPanelKeyboardFocusNode;
  late FocusNode rightPanelKeyboardFocusNode;

  @override
  void initState() {
    super.initState();

    leftPanelKeyboardFocusNode = FocusNode(debugLabel: 'file column left');
    rightPanelKeyboardFocusNode = FocusNode(debugLabel: 'file column right');
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Row(
        children: [
          FileColumn(
            color: Colors.amber,
            columnSide: SidePanelFocus.left,
            panelFocusNode: leftPanelKeyboardFocusNode,
            opposidePanelFocusNode: rightPanelKeyboardFocusNode,
          ),
          FileColumn(
            color: Colors.purple,
            columnSide: SidePanelFocus.right,
            panelFocusNode: rightPanelKeyboardFocusNode,
            opposidePanelFocusNode: leftPanelKeyboardFocusNode,
          ),
        ],
      ),
    );
  }
}
