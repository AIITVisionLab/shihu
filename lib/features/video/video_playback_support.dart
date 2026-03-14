import 'package:sickandflutter/shared/models/app_enums.dart';

/// 返回当前平台是否支持软件内嵌视频查看页。
bool supportsEmbeddedVideoPlaybackOnPlatform(PlatformType platform) {
  switch (platform) {
    case PlatformType.android:
    case PlatformType.ios:
    case PlatformType.macos:
    case PlatformType.web:
      return true;
    case PlatformType.windows:
    case PlatformType.linux:
    case PlatformType.ohos:
      return false;
  }
}
