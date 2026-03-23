import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/app/widgets/workspace/workspace_bottom_navigation.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/auth/auth_session.dart';
import 'package:sickandflutter/features/auth/auth_user.dart';
import 'package:sickandflutter/features/video/video_page.dart';
import 'package:sickandflutter/features/video/video_stream_info.dart';
import 'package:sickandflutter/features/video/video_stream_repository.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';

void main() {
  testWidgets('VideoPage renders user-facing video information', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1440, 2000)
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
                    account: 'tester',
                    displayName: '巡检员',
                  ),
                ),
              ),
            ),
          ),
          videoStreamListProvider.overrideWith(
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
        child: const MaterialApp(home: VideoPage(enableInlinePlayback: false)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('视频中心'), findsWidgets);
    expect(find.text('K230 实时视频流'), findsWidgets);
    expect(find.text('当前主画面'), findsOneWidget);
    expect(find.text('放大查看'), findsOneWidget);
    expect(find.text('在线'), findsWidgets);
  });

  testWidgets('VideoPage renders mobile layout without overflow', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(390, 844)
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
                    account: 'tester',
                    displayName: '巡检员',
                  ),
                ),
              ),
            ),
          ),
          videoStreamListProvider.overrideWith(
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
        child: const MaterialApp(home: VideoPage(enableInlinePlayback: false)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(WorkspaceBottomNavigation), findsOneWidget);
    expect(find.text('视频中心'), findsWidgets);
    expect(find.text('查看当前画面是否在线，必要时直接在软件内观看。'), findsOneWidget);
    expect(find.text('刷新画面'), findsOneWidget);
    expect(
      tester.getSize(find.widgetWithText(OutlinedButton, '刷新画面')).height,
      lessThanOrEqualTo(48),
    );
    expect(tester.takeException(), isNull);
  });
}

class _TestAuthController extends AuthController {
  _TestAuthController({required this.initialState});

  final AuthState initialState;

  @override
  AuthState build() => initialState;
}
