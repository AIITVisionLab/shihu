import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/features/video/video_playback_support.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';

void main() {
  test('supportsEmbeddedVideoPlaybackOnPlatform marks supported platforms', () {
    expect(
      supportsEmbeddedVideoPlaybackOnPlatform(PlatformType.android),
      isTrue,
    );
    expect(supportsEmbeddedVideoPlaybackOnPlatform(PlatformType.ios), isTrue);
    expect(supportsEmbeddedVideoPlaybackOnPlatform(PlatformType.macos), isTrue);
    expect(supportsEmbeddedVideoPlaybackOnPlatform(PlatformType.web), isTrue);
  });

  test(
    'supportsEmbeddedVideoPlaybackOnPlatform rejects unsupported platforms',
    () {
      expect(
        supportsEmbeddedVideoPlaybackOnPlatform(PlatformType.windows),
        isFalse,
      );
      expect(
        supportsEmbeddedVideoPlaybackOnPlatform(PlatformType.linux),
        isFalse,
      );
      expect(
        supportsEmbeddedVideoPlaybackOnPlatform(PlatformType.ohos),
        isFalse,
      );
    },
  );

  test('supportsDirectVideoPlaybackOnPlatform marks desktop platforms', () {
    expect(supportsDirectVideoPlaybackOnPlatform(PlatformType.windows), isTrue);
    expect(supportsDirectVideoPlaybackOnPlatform(PlatformType.linux), isTrue);
    expect(supportsDirectVideoPlaybackOnPlatform(PlatformType.web), isFalse);
    expect(
      supportsDirectVideoPlaybackOnPlatform(PlatformType.android),
      isFalse,
    );
    expect(supportsDirectVideoPlaybackOnPlatform(PlatformType.ios), isFalse);
    expect(supportsDirectVideoPlaybackOnPlatform(PlatformType.macos), isFalse);
    expect(supportsDirectVideoPlaybackOnPlatform(PlatformType.ohos), isFalse);
  });
}
