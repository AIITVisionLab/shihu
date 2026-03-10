import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/auth/auth_session.dart';
import 'package:sickandflutter/features/auth/auth_user.dart';
import 'package:sickandflutter/features/video/video_hub_page.dart';
import 'package:sickandflutter/features/video/video_stream_repository.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/video_stream_info.dart';

void main() {
  testWidgets('VideoHubPage renders stream cards when service returns data', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1440, 2200)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(
            () => _TestAuthController(
              initialState: const AuthState(
                session: AuthSession(
                  accessToken: 'token_demo',
                  loginMode: AuthLoginMode.real,
                  user: AuthUser(
                    userId: 'user_1',
                    account: 'ops',
                    displayName: '值守人员',
                  ),
                ),
              ),
            ),
          ),
          videoServiceBaseUrlProvider.overrideWith(
            (ref) async => 'http://101.35.79.76:19081',
          ),
          videoStreamsProvider.overrideWith(
            (ref) async => const <VideoStreamInfo>[
              VideoStreamInfo(
                streamId: 'k230',
                deviceId: 'k230',
                displayName: 'K230 实时视频流',
                gatewayPageUrl: 'http://101.35.79.76:1984/',
                playerUrl:
                    'http://101.35.79.76:1984/stream.html?src=k230&mode=webrtc,mse',
                preferredMode: 'webrtc',
                fallbackMode: 'mse',
                publicHost: '101.35.79.76',
                webrtcPort: 8555,
                available: true,
                aiResultForwarded: false,
              ),
            ],
          ),
        ],
        child: const MaterialApp(home: VideoHubPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('视频中心'), findsAtLeastNWidgets(1));
    expect(find.text('K230 实时视频流'), findsOneWidget);
    expect(find.text('查看详情'), findsOneWidget);
    expect(find.text('打开播放页'), findsOneWidget);
  });

  testWidgets('VideoHubPage renders formal error state on service failure', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1440, 2200)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(
            () => _TestAuthController(initialState: const AuthState()),
          ),
          videoServiceBaseUrlProvider.overrideWith(
            (ref) async => 'http://101.35.79.76:19081',
          ),
          videoStreamsProvider.overrideWith(
            (ref) =>
                Future<List<VideoStreamInfo>>.error(Exception('empty reply')),
          ),
        ],
        child: const MaterialApp(home: VideoHubPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('视频服务暂未就绪'), findsOneWidget);
    expect(find.textContaining('empty reply'), findsOneWidget);
  });

  testWidgets('VideoHubPage supports filter and search interactions', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1440, 2400)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(
            () => _TestAuthController(initialState: const AuthState()),
          ),
          videoServiceBaseUrlProvider.overrideWith(
            (ref) async => 'http://101.35.79.76:19081',
          ),
          videoStreamsProvider.overrideWith(
            (ref) async => const <VideoStreamInfo>[
              VideoStreamInfo(
                streamId: 'k230',
                deviceId: 'cabinet_a',
                displayName: 'A 区主摄像头',
                gatewayPageUrl: 'http://101.35.79.76:1984/',
                playerUrl:
                    'http://101.35.79.76:1984/stream.html?src=k230&mode=webrtc,mse',
                preferredMode: 'webrtc',
                fallbackMode: 'mse',
                publicHost: '101.35.79.76',
                webrtcPort: 8555,
                available: true,
                aiResultForwarded: true,
              ),
              VideoStreamInfo(
                streamId: 'k230_backup',
                deviceId: 'cabinet_b',
                displayName: 'B 区备用摄像头',
                gatewayPageUrl: 'http://101.35.79.76:1984/',
                playerUrl:
                    'http://101.35.79.76:1984/stream.html?src=k230_backup&mode=mse',
                preferredMode: 'mse',
                fallbackMode: 'mse',
                publicHost: '101.35.79.76',
                webrtcPort: 8555,
                available: false,
                aiResultForwarded: false,
              ),
            ],
          ),
        ],
        child: const MaterialApp(home: VideoHubPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('A 区主摄像头'), findsOneWidget);
    expect(find.text('B 区备用摄像头'), findsOneWidget);

    await tester.tap(find.widgetWithText(ChoiceChip, '仅在线'));
    await tester.pumpAndSettle();

    expect(find.text('A 区主摄像头'), findsOneWidget);
    expect(find.text('B 区备用摄像头'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, '全部流'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'cabinet_b');
    await tester.pumpAndSettle();

    expect(find.text('A 区主摄像头'), findsNothing);
    expect(find.text('B 区备用摄像头'), findsOneWidget);
  });
}

class _TestAuthController extends AuthController {
  _TestAuthController({required this.initialState});

  final AuthState initialState;

  @override
  AuthState build() => initialState;
}
