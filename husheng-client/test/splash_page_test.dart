import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';
import 'package:sickandflutter/features/splash/splash_page.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/app_settings.dart';

void main() {
  testWidgets('SplashPage renders mobile layout without overflow', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final router = GoRouter(
      initialLocation: AppRoutes.splashPath,
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.splashPath,
          name: AppRoutes.splash,
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: AppRoutes.loginPath,
          name: AppRoutes.login,
          builder: (context, state) => const Scaffold(body: Text('login-page')),
        ),
        GoRoute(
          path: AppRoutes.realtimeDetectPath,
          name: AppRoutes.realtimeDetect,
          builder: (context, state) =>
              const Scaffold(body: Text('realtime-page')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsControllerProvider.overrideWith(
            () => _TestSettingsController(
              initialSettings: AppSettings.defaults(
                buildFlavor: BuildFlavor.development,
                baseUrl: 'http://127.0.0.1:8080',
                enableLog: true,
              ),
            ),
          ),
          packageInfoProvider.overrideWith(
            (ref) async => PackageInfo(
              appName: '斛生',
              packageName: 'com.example.sickandflutter',
              version: '1.2.3',
              buildNumber: '45',
            ),
          ),
          authControllerProvider.overrideWith(
            () => _TestAuthController(initialState: const AuthState()),
          ),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();

    expect(find.text('斛生'), findsOneWidget);
    expect(find.text(AppCopy.splashBootstrapping), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    expect(find.text('login-page'), findsOneWidget);
  });
}

class _TestAuthController extends AuthController {
  _TestAuthController({required this.initialState});

  final AuthState initialState;

  @override
  AuthState build() => initialState;

  @override
  Future<void> ensureInitialized() async {}
}

class _TestSettingsController extends SettingsController {
  _TestSettingsController({required this.initialSettings});

  final AppSettings initialSettings;

  @override
  Future<AppSettings> build() async => initialSettings;
}
