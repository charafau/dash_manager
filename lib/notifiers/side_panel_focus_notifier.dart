import 'package:flutter_riverpod/flutter_riverpod.dart';

final sidePanelFocusNotifierProvider =
    StateNotifierProvider<SidePanelFocusNotifier, SidePanelFocus>(
        (ref) => SidePanelFocusNotifier());

class SidePanelFocusNotifier extends StateNotifier<SidePanelFocus> {
  SidePanelFocusNotifier() : super(SidePanelFocus.left);

  void changeSide({SidePanelFocus? side}) {
    if (side == null) {
      if (state == SidePanelFocus.left) {
        state = SidePanelFocus.right;
      } else {
        state = SidePanelFocus.right;
      }
    } else {
      state = side;
    }
  }
}

enum SidePanelFocus { left, right }
