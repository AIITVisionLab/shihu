import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/auth/auth_session.dart';
import 'package:sickandflutter/features/auth/auth_user.dart';
import 'package:sickandflutter/features/history/history_repository.dart';
import 'package:sickandflutter/features/settings/service_health_repository.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';
import 'package:sickandflutter/features/settings/settings_page.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/app_settings.dart';
import 'package:sickandflutter/shared/models/history_record.dart';
import 'package:sickandflutter/shared/models/service_health_info.dart';

void main() {
  testWidgets('SettingsPage renders environment, health and session info', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1400, 1800)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final settingsController = _TestSettingsController(
      initialSettings: AppSettings.defaults(
        buildFlavor: BuildFlavor.development,
        baseUrl: 'http://10.0.2.2:8080',
        enableLog: true,
      ),
    );
    final authController = _TestAuthController(
      initialState: const AuthState(
        session: AuthSession(
          accessToken: 'token_demo',
          expiresAt: '2026-03-08T18:00:00+08:00',
          loginMode: AuthLoginMode.mock,
          user: AuthUser(
            userId: 'user_demo',
            account: 'demo',
            displayName: '演示账号',
            roles: <String>['app_user'],
          ),
        ),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          envConfigProvider.overrideWith(
            (ref) => const EnvConfig(
              flavor: BuildFlavor.development,
              baseUrl: 'http://127.0.0.1:8080',
              enableLog: true,
            ),
          ),
          packageInfoProvider.overrideWith(
            (ref) async => PackageInfo(
              appName: '石斛病虫害识别',
              packageName: 'com.example.sickandflutter',
              version: '2.3.4',
              buildNumber: '56',
            ),
          ),
          settingsControllerProvider.overrideWith(() => settingsController),
          serviceHealthProvider.overrideWith(
            (ref) async => const ServiceHealthInfo(
              status: 'up',
              serviceName: 'shihu-detect-service',
              serviceVersion: '1.0.0',
              modelStatus: 'ready',
              serverTime: '2026-03-08T10:00:00+08:00',
            ),
          ),
          authControllerProvider.overrideWith(() => authController),
          historyControllerProvider.overrideWith(
            () =>
                _TestHistoryController(initialRecords: const <HistoryRecord>[]),
          ),
        ],
        child: const MaterialApp(home: SettingsPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('开发环境'), findsOneWidget);
    expect(find.text('2.3.4+56'), findsOneWidget);
    expect(find.text('http://10.0.2.2:8080'), findsOneWidget);
    expect(find.text('服务正常'), findsOneWidget);
    expect(find.text('模型就绪'), findsOneWidget);
    expect(find.text('shihu-detect-service'), findsOneWidget);
    expect(find.text('demo'), findsOneWidget);
    expect(find.text('受控演示登录'), findsOneWidget);
  });

  testWidgets('SettingsPage updates base url and resets settings', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1400, 1800)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const envConfig = EnvConfig(
      flavor: BuildFlavor.development,
      baseUrl: 'http://127.0.0.1:8080',
      enableLog: true,
    );
    final settingsController = _TestSettingsController(
      initialSettings: AppSettings.defaults(
        buildFlavor: BuildFlavor.development,
        baseUrl: 'http://10.0.2.2:8080',
        enableLog: true,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          envConfigProvider.overrideWith((ref) => envConfig),
          packageInfoProvider.overrideWith(
            (ref) async => PackageInfo(
              appName: '石斛病虫害识别',
              packageName: 'com.example.sickandflutter',
              version: '2.3.4',
              buildNumber: '56',
            ),
          ),
          settingsControllerProvider.overrideWith(() => settingsController),
          serviceHealthProvider.overrideWith(
            (ref) async => const ServiceHealthInfo(
              status: 'up',
              serviceName: 'shihu-detect-service',
              serviceVersion: '1.0.0',
              modelStatus: 'ready',
              serverTime: '2026-03-08T10:00:00+08:00',
            ),
          ),
          authControllerProvider.overrideWith(
            () => _TestAuthController(initialState: const AuthState()),
          ),
          historyControllerProvider.overrideWith(
            () =>
                _TestHistoryController(initialRecords: const <HistoryRecord>[]),
          ),
        ],
        child: const MaterialApp(home: SettingsPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('修改'));
    await tester.tap(find.text('修改'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'http://192.168.1.10:8080');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(settingsController.updatedBaseUrls, <String>[
      'http://192.168.1.10:8080',
    ]);
    expect(find.text('http://192.168.1.10:8080'), findsOneWidget);

    await tester.ensureVisible(find.text('恢复默认设置'));
    await tester.tap(find.text('恢复默认设置'));
    await tester.pumpAndSettle();

    expect(settingsController.resetCount, 1);
    expect(find.text(envConfig.baseUrl), findsOneWidget);
  });
}

class _TestSettingsController extends SettingsController {
  _TestSettingsController({required this.initialSettings});

  final AppSettings initialSettings;
  final List<String> updatedBaseUrls = <String>[];
  int resetCount = 0;

  @override
  Future<AppSettings> build() async => initialSettings;

  @override
  Future<void> updateBaseUrl(String baseUrl) async {
    updatedBaseUrls.add(baseUrl);
    state = AsyncData(
      (state.asData?.value ?? initialSettings).copyWith(baseUrl: baseUrl),
    );
  }

  @override
  Future<void> reset() async {
    resetCount += 1;
    state = AsyncData(
      AppSettings.defaults(
        buildFlavor: initialSettings.buildFlavor,
        baseUrl: 'http://127.0.0.1:8080',
        enableLog: initialSettings.enableLog,
      ),
    );
  }
}

class _TestAuthController extends AuthController {
  _TestAuthController({required this.initialState});

  final AuthState initialState;
  int logoutCount = 0;

  @override
  AuthState build() => initialState;

  @override
  Future<void> logout({bool notifyServer = true}) async {
    logoutCount += 1;
    state = const AuthState();
  }
}

class _TestHistoryController extends HistoryController {
  _TestHistoryController({required this.initialRecords});

  final List<HistoryRecord> initialRecords;
  int clearAllCount = 0;

  @override
  Future<List<HistoryRecord>> build() async => initialRecords;

  @override
  Future<void> clearAll() async {
    clearAllCount += 1;
    state = const AsyncData(<HistoryRecord>[]);
  }
}
