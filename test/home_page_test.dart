import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/app/widgets/workspace/workspace_bottom_navigation.dart';
import 'package:sickandflutter/app/widgets/workspace/workspace_rail_pane.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/auth/auth_session.dart';
import 'package:sickandflutter/features/auth/auth_user.dart';
import 'package:sickandflutter/features/device/domain/device_status.dart';
import 'package:sickandflutter/features/home/application/home_overview_device_status_provider.dart';
import 'package:sickandflutter/features/home/home_page.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';

void main() {
  testWidgets('HomePage renders backend-driven summary and device status', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1400, 1600)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final router = _buildRouter();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          packageInfoProvider.overrideWith(
            (ref) async => PackageInfo(
              appName: '斛生',
              packageName: 'com.example.sickandflutter',
              version: '1.2.3',
              buildNumber: '45',
            ),
          ),
          authControllerProvider.overrideWith(
            () => _TestAuthController(
              initialState: const AuthState(
                session: AuthSession(
                  accessToken: 'session_demo',
                  loginMode: AuthLoginMode.real,
                  user: AuthUser(
                    userId: 'user_1',
                    account: 'tester',
                    displayName: '联调用户',
                    roles: <String>['admin'],
                  ),
                ),
              ),
            ),
          ),
          homeOverviewDeviceStatusProvider.overrideWith(
            (ref) => Stream.value(
              const DeviceStatus(
                deviceId: 'dev_1',
                deviceName: '石斛培育柜',
                temperature: 24.5,
                humidity: 82.0,
                light: 1500,
                mq2: 18,
                errorCode: 0,
                ledOn: true,
                updatedAt: 1741399200000,
              ),
            ),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(WorkspaceRailPane), findsOneWidget);
    expect(find.text('环境速览'), findsOneWidget);
    expect(find.text('石斛培育柜'), findsWidgets);
    expect(find.text('系统运行正常'), findsWidgets);
    expect(find.text('常用入口'), findsNothing);
  });

  testWidgets('HomePage uses workspace navigation to switch routes', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1400, 1600)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final router = _buildRouter();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          packageInfoProvider.overrideWith(
            (ref) async => PackageInfo(
              appName: '斛生',
              packageName: 'com.example.sickandflutter',
              version: '1.2.3',
              buildNumber: '45',
            ),
          ),
          authControllerProvider.overrideWith(
            () => _TestAuthController(
              initialState: const AuthState(
                session: AuthSession(
                  accessToken: 'session_demo',
                  loginMode: AuthLoginMode.real,
                  user: AuthUser(
                    userId: 'user_1',
                    account: 'tester',
                    displayName: '联调用户',
                    roles: <String>['admin'],
                  ),
                ),
              ),
            ),
          ),
          homeOverviewDeviceStatusProvider.overrideWith(
            (ref) => Stream.value(
              const DeviceStatus(
                deviceId: 'dev_1',
                deviceName: '石斛培育柜',
                temperature: 24.5,
                humidity: 82.0,
                light: 1500,
                mq2: 18,
                errorCode: 0,
                ledOn: true,
                updatedAt: 1741399200000,
              ),
            ),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.monitor_heart_outlined).first);
    await tester.pumpAndSettle();
    expect(find.text('realtime-page'), findsOneWidget);

    router.goNamed(AppRoutes.home);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.videocam_outlined).first);
    await tester.pumpAndSettle();
    expect(find.text('video-page'), findsOneWidget);

    router.goNamed(AppRoutes.home);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.settings_outlined).first);
    await tester.pumpAndSettle();
    expect(find.text('settings-page'), findsOneWidget);
  });

  testWidgets('HomePage renders mobile layout without overflow', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final router = _buildRouter();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          packageInfoProvider.overrideWith(
            (ref) async => PackageInfo(
              appName: '斛生',
              packageName: 'com.example.sickandflutter',
              version: '1.2.3',
              buildNumber: '45',
            ),
          ),
          authControllerProvider.overrideWith(
            () => _TestAuthController(
              initialState: const AuthState(
                session: AuthSession(
                  accessToken: 'session_demo',
                  loginMode: AuthLoginMode.real,
                  user: AuthUser(
                    userId: 'user_1',
                    account: 'tester',
                    displayName: '联调用户',
                    roles: <String>['admin'],
                  ),
                ),
              ),
            ),
          ),
          homeOverviewDeviceStatusProvider.overrideWith(
            (ref) => Stream.value(
              const DeviceStatus(
                deviceId: 'dev_1',
                deviceName: '石斛培育柜',
                temperature: 24.5,
                humidity: 82.0,
                light: 1500,
                mq2: 18,
                errorCode: 0,
                ledOn: true,
                updatedAt: 1741399200000,
              ),
            ),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(WorkspaceBottomNavigation), findsOneWidget);
    expect(find.text('环境速览'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _TestAuthController extends AuthController {
  _TestAuthController({required this.initialState});

  final AuthState initialState;

  @override
  AuthState build() => initialState;
}

GoRouter _buildRouter() {
  return GoRouter(
    initialLocation: AppRoutes.homePath,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.homePath,
        name: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.realtimeDetectPath,
        name: AppRoutes.realtimeDetect,
        builder: (context, state) =>
            const Scaffold(body: Text('realtime-page')),
      ),
      GoRoute(
        path: AppRoutes.videoPath,
        name: AppRoutes.video,
        builder: (context, state) => const Scaffold(body: Text('video-page')),
      ),
      GoRoute(
        path: AppRoutes.settingsPath,
        name: AppRoutes.settings,
        builder: (context, state) =>
            const Scaffold(body: Text('settings-page')),
      ),
    ],
  );
}
