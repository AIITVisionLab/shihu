import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/auth/auth_session.dart';
import 'package:sickandflutter/features/auth/auth_user.dart';
import 'package:sickandflutter/features/home/home_page.dart';
import 'package:sickandflutter/features/settings/device_state_repository.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/device_state_info.dart';

void main() {
  testWidgets('HomePage renders entry cards and version info', (tester) async {
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
              appName: '石斛幼苗智能培育管理平台',
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
          deviceStateProvider.overrideWith(
            (ref) async => const DeviceStateInfo(
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
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('监控主控台'), findsOneWidget);
    expect(find.text('公开预览'), findsOneWidget);
    expect(find.text('后续扩展能力'), findsOneWidget);
    expect(find.text('单图识别'), findsOneWidget);
    expect(find.text('识别历史'), findsOneWidget);
    expect(find.text('运维设置'), findsOneWidget);
    expect(find.text('待独立识别服务接入'), findsNWidgets(2));
    expect(find.text('版本 1.2.3'), findsOneWidget);
    expect(find.text('石斛培育柜'), findsOneWidget);
  });

  testWidgets('HomePage entry cards navigate to named routes', (tester) async {
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
              appName: '石斛幼苗智能培育管理平台',
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
          deviceStateProvider.overrideWith(
            (ref) async => const DeviceStateInfo(
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
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('监控主控台'));
    await tester.pumpAndSettle();
    expect(find.text('realtime-page'), findsOneWidget);

    router.goNamed(AppRoutes.home);
    await tester.pumpAndSettle();

    await tester.tap(find.text('公开预览'));
    await tester.pumpAndSettle();
    expect(find.text('about-page'), findsOneWidget);

    router.goNamed(AppRoutes.home);
    await tester.pumpAndSettle();

    await tester.tap(find.text('运维设置'));
    await tester.pumpAndSettle();
    expect(find.text('settings-page'), findsOneWidget);
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
        path: AppRoutes.historyPath,
        name: AppRoutes.history,
        builder: (context, state) => const Scaffold(body: Text('history-page')),
      ),
      GoRoute(
        path: AppRoutes.aboutPath,
        name: AppRoutes.about,
        builder: (context, state) => const Scaffold(body: Text('about-page')),
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
