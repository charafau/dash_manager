import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeDirectoryProvider = Provider<String>((ref) {
  String home = "";
  Map<String, String> envVars = Platform.environment;
  if (Platform.isMacOS || Platform.isLinux) {
    home = envVars['HOME']!;
  } else if (Platform.isWindows) {
    home = envVars['UserProfile']!;
  }

  return home;
});
