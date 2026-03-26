import 'dart:io' as io;

import 'package:fvp/fvp.dart' as fvp;

/// 初始化桌面端视频后端，让 Linux / Windows 可以在软件内播放网络流。
Future<void> configureDesktopVideoBackend() async {
  if (!io.Platform.isLinux && !io.Platform.isWindows) {
    return;
  }

  fvp.registerWith(
    options: <String, dynamic>{
      'platforms': <String>['linux', 'windows'],
      'lowLatency': 1,
    },
  );
}
