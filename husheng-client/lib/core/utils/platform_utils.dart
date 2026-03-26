import 'package:flutter/foundation.dart';
import 'package:sickandflutter/core/utils/platform_runtime_stub.dart'
    if (dart.library.io) 'package:sickandflutter/core/utils/platform_runtime_io.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';

const String _platformOverrideKey = 'APP_PLATFORM_OVERRIDE';

/// 推断当前运行平台的标准枚举值。
PlatformType currentPlatformType() {
  final overridePlatform = tryPlatformTypeFromValue(
    const String.fromEnvironment(_platformOverrideKey),
  );
  if (overridePlatform != null) {
    return overridePlatform;
  }

  if (kIsWeb) {
    return PlatformType.web;
  }

  if (isOhosRuntime()) {
    return PlatformType.ohos;
  }

  final platform = defaultTargetPlatform;
  if (platform == TargetPlatform.android) {
    return PlatformType.android;
  }
  if (platform == TargetPlatform.iOS) {
    return PlatformType.ios;
  }
  if (platform == TargetPlatform.macOS) {
    return PlatformType.macos;
  }
  if (platform == TargetPlatform.windows) {
    return PlatformType.windows;
  }
  if (platform == TargetPlatform.linux) {
    return PlatformType.linux;
  }
  if (platform == TargetPlatform.fuchsia) {
    return PlatformType.android;
  }

  // 兼容 SDK 扩展出来的平台枚举，例如 `TargetPlatform.ohos`。
  return PlatformType.android;
}

/// 返回当前运行平台的展示文案。
String currentPlatformLabel() => currentPlatformType().label;
