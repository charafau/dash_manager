import 'package:dash_manager/widgets/bottom_buttons.dart';
import 'package:dash_manager/widgets/menu.dart';
import 'package:dash_manager/widgets/middle_column.dart';
import 'package:dash_manager/widgets/toolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommanderScreen extends ConsumerWidget {
  const CommanderScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Scaffold(
      body: Column(
        children: const [
          Menu(),
          Toolbar(),
          MiddleColumns(),
          BottomButtons(),
        ],
      ),
    );
  }
}
