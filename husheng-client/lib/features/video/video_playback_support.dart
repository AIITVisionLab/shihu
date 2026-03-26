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

/// 返回当前平台是否支持通过原生播放器在软件内直接播放视频流。
bool supportsDirectVideoPlaybackOnPlatform(PlatformType platform) {
  switch (platform) {
    case PlatformType.windows:
    case PlatformType.linux:
      return true;
    case PlatformType.android:
    case PlatformType.ios:
    case PlatformType.macos:
    case PlatformType.web:
    case PlatformType.ohos:
      return false;
  }
}
