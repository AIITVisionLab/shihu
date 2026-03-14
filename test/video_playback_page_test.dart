import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/features/video/video_playback_page.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';

void main() {
  testWidgets(
    'VideoPlaybackPage shows unsupported message when platform cannot embed video',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: VideoPlaybackPage(
            title: 'K230 实时视频流',
            initialUrl:
                'http://101.35.79.76:1984/stream.html?src=k230&mode=webrtc,mse',
            sourceLabel: '主画面',
            platformTypeOverride: PlatformType.linux,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('当前平台暂不支持软件内查看'), findsOneWidget);
      expect(find.textContaining('Android、iOS、macOS 或 Web'), findsOneWidget);
    },
  );
}
