import 'package:flutter_riverpod/flutter_riverpod.dart';

final sidePanelFocusNotifierProvider =
    StateNotifierProvider<SidePanelFocusNotifier, SidePanelFocus>(
        (ref) => SidePanelFocusNotifier());

class SidePanelFocusNotifier extends StateNotifier<SidePanelFocus> {
  SidePanelFocusNotifier() : super(SidePanelFocus.left);
}

enum SidePanelFocus { left, right }
