import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/auth/auth_session.dart';
import 'package:sickandflutter/features/auth/auth_user.dart';
import 'package:sickandflutter/features/auth/remembered_account_repository.dart';
import 'package:sickandflutter/features/settings/device_state_repository.dart';
import 'package:sickandflutter/features/settings/service_health_repository.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';
import 'package:sickandflutter/features/settings/settings_page.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/app_settings.dart';
import 'package:sickandflutter/shared/models/device_state_info.dart';
import 'package:sickandflutter/shared/models/service_health_info.dart';

void main() {
  testWidgets('SettingsPage renders environment, health and session info', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1400, 2800)
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
            displayName: '联调账号',
            roles: <String>['app_user'],
          ),
        ),
      ),
    );
    final rememberedAccountController = _TestRememberedAccountController(
      initialRememberedAccount: 'ops_admin',
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
            (ref) async => ServiceHealthInfo(
              status: 'up',
              responseText: 'ok',
              checkedAt: DateTime.parse(
                '2026-03-08T10:00:00+08:00',
              ).toIso8601String(),
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
          authControllerProvider.overrideWith(() => authController),
          rememberedAccountControllerProvider.overrideWith(
            () => rememberedAccountController,
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
    expect(find.text('ok'), findsOneWidget);
    expect(find.text('2026-03-08 10:00:00'), findsOneWidget);
    expect(find.text('demo'), findsOneWidget);
    expect(find.text('联调登录'), findsOneWidget);
    expect(find.text('记住的账号'), findsOneWidget);
    expect(find.text('ops_admin'), findsOneWidget);
  });

  testWidgets('SettingsPage updates base url and resets settings', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1400, 2800)
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
    final rememberedAccountController = _TestRememberedAccountController(
      initialRememberedAccount: null,
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
            (ref) async => ServiceHealthInfo(
              status: 'up',
              responseText: 'ok',
              checkedAt: DateTime.parse(
                '2026-03-08T10:00:00+08:00',
              ).toIso8601String(),
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
          authControllerProvider.overrideWith(
            () => _TestAuthController(initialState: const AuthState()),
          ),
          rememberedAccountControllerProvider.overrideWith(
            () => rememberedAccountController,
          ),
        ],
        child: const MaterialApp(home: SettingsPage()),
      ),
    );
    await tester.pumpAndSettle();

    final editButtons = find.widgetWithText(TextButton, '修改');
    await tester.ensureVisible(editButtons.first);
    await tester.tap(editButtons.first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'http://192.168.1.10:8080');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(settingsController.updatedBaseUrls, <String>[
      'http://192.168.1.10:8080',
    ]);
    expect(find.text('http://192.168.1.10:8080'), findsOneWidget);

    final resetButton = find.widgetWithText(OutlinedButton, '恢复默认设置');
    await tester.tap(resetButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认'));
    await tester.pumpAndSettle();

    expect(settingsController.resetCount, 1);
    expect(find.text(envConfig.baseUrl), findsOneWidget);
  });

  testWidgets('SettingsPage clears remembered account after confirmation', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1400, 2800)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final rememberedAccountController = _TestRememberedAccountController(
      initialRememberedAccount: 'ops_admin',
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
              appName: '斛生',
              packageName: 'com.example.sickandflutter',
              version: '2.3.4',
              buildNumber: '56',
            ),
          ),
          settingsControllerProvider.overrideWith(
            () => _TestSettingsController(
              initialSettings: AppSettings.defaults(
                buildFlavor: BuildFlavor.development,
                baseUrl: 'http://127.0.0.1:8080',
                enableLog: true,
              ),
            ),
          ),
          serviceHealthProvider.overrideWith(
            (ref) async => ServiceHealthInfo(
              status: 'up',
              responseText: 'ok',
              checkedAt: DateTime.parse(
                '2026-03-08T10:00:00+08:00',
              ).toIso8601String(),
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
          authControllerProvider.overrideWith(
            () => _TestAuthController(initialState: const AuthState()),
          ),
          rememberedAccountControllerProvider.overrideWith(
            () => rememberedAccountController,
          ),
        ],
        child: const MaterialApp(home: SettingsPage()),
      ),
    );
    await tester.pumpAndSettle();

    final clearRememberedButton = find.widgetWithText(FilledButton, '清除记住账号');
    await tester.ensureVisible(clearRememberedButton);
    await tester.tap(clearRememberedButton);
    await tester.pumpAndSettle();

    expect(find.text('清除记住的账号'), findsOneWidget);

    await tester.tap(find.text('确认'));
    await tester.pumpAndSettle();

    expect(rememberedAccountController.clearCount, 1);
    expect(find.text('当前未保存'), findsOneWidget);
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

class _TestRememberedAccountController extends RememberedAccountController {
  _TestRememberedAccountController({required this.initialRememberedAccount});

  final String? initialRememberedAccount;
  int clearCount = 0;

  @override
  Future<String?> build() async => initialRememberedAccount;

  @override
  Future<void> clear() async {
    clearCount += 1;
    state = const AsyncData(null);
  }
}
