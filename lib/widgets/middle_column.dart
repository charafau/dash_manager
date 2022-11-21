import 'package:dash_manager/notifiers/side_panel_focus_notifier.dart';
import 'package:dash_manager/widgets/file_column.dart';
import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:multi_split_view/multi_split_view.dart';

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
    // return Flexible(
    //   child: Row(
    //     children: [
    //       FileColumn(
    //         // color: Colors.amber,
    //         columnSide: SidePanelFocus.left,
    //         panelFocusNode: leftPanelKeyboardFocusNode,
    //         opposidePanelFocusNode: rightPanelKeyboardFocusNode,
    //       ),
    //       FileColumn(
    //         // color: Colors.purple,
    //         columnSide: SidePanelFocus.right,
    //         panelFocusNode: rightPanelKeyboardFocusNode,
    //         opposidePanelFocusNode: leftPanelKeyboardFocusNode,
    //       ),
    //     ],
    //   ),
    // );

    return Flexible(
      child: MultiSplitViewTheme(
        data: MultiSplitViewThemeData(
          dividerPainter: DividerPainters.grooved2(
            color: Colors.grey[400]!,
            highlightedColor: MacosColors.controlAccentColor,
          ),
        ),
        child: MultiSplitView(
          children: [
            FileColumn(
              // color: Colors.amber,
              columnSide: SidePanelFocus.left,
              panelFocusNode: leftPanelKeyboardFocusNode,
              opposidePanelFocusNode: rightPanelKeyboardFocusNode,
            ),
            FileColumn(
              // color: Colors.purple,
              columnSide: SidePanelFocus.right,
              panelFocusNode: rightPanelKeyboardFocusNode,
              opposidePanelFocusNode: leftPanelKeyboardFocusNode,
            ),
          ],
        ),
      ),
    );
  }
}
