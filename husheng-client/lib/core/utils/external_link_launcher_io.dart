import 'dart:io' as io;

import 'package:sickandflutter/core/utils/platform_utils.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';

/// 在支持的平台上调用系统命令拉起外部浏览器。
Future<bool> openExternalUrl(String url) async {
  final normalizedUrl = url.trim();
  final uri = Uri.tryParse(normalizedUrl);
  if (normalizedUrl.isEmpty || uri == null || !uri.hasScheme) {
    return false;
  }

  try {
    switch (currentPlatformType()) {
      case PlatformType.windows:
        final result = await io.Process.run('cmd', <String>[
          '/c',
          'start',
          '',
          normalizedUrl,
        ]);
        return result.exitCode == 0;
      case PlatformType.macos:
        final result = await io.Process.run('open', <String>[normalizedUrl]);
        return result.exitCode == 0;
      case PlatformType.linux:
        final result = await io.Process.run('xdg-open', <String>[
          normalizedUrl,
        ]);
        return result.exitCode == 0;
      case PlatformType.web:
      case PlatformType.android:
      case PlatformType.ios:
      case PlatformType.ohos:
        return false;
    }
  } catch (_) {
    return false;
  }
}
