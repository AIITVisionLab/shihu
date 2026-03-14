import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/app/widgets/workspace/workspace_bottom_navigation.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/storage/sensitive_storage.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/auth/auth_session.dart';
import 'package:sickandflutter/features/auth/auth_user.dart';
import 'package:sickandflutter/features/auth/remembered_account_repository.dart';
import 'package:sickandflutter/features/device/application/device_runtime_providers.dart';
import 'package:sickandflutter/features/device/domain/device_status.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';
import 'package:sickandflutter/features/settings/settings_page.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/app_settings.dart';

void main() {
  testWidgets('SettingsPage renders device, account and local info', (
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
          settingsControllerProvider.overrideWith(() => settingsController),
          deviceStatusProvider.overrideWith(
            (ref) async => const DeviceStatus(
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

    expect(find.text('当前使用'), findsWidgets);
    expect(find.text('石斛培育柜'), findsWidgets);
    expect(find.text('系统运行正常'), findsNWidgets(2));
    expect(find.text('2025-03-08 10:00'), findsOneWidget);
    expect(find.textContaining('数据已滞后'), findsOneWidget);
    expect(find.text('已开启'), findsOneWidget);
    expect(find.text('demo'), findsWidgets);
    expect(find.text('当前已登录，可以直接继续使用。'), findsOneWidget);
    expect(find.text('记住的账号'), findsOneWidget);
    expect(find.text('ops_admin'), findsOneWidget);
    expect(find.text('使用帮助'), findsWidgets);
  });

  testWidgets(
    'SettingsPage shows session persistence warning when unsupported',
    (tester) async {
      tester.view
        ..physicalSize = const Size(1400, 2800)
        ..devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supportsPersistentSensitiveStorageProvider.overrideWith(
              (ref) => false,
            ),
            envConfigProvider.overrideWith(
              (ref) => const EnvConfig(
                flavor: BuildFlavor.development,
                baseUrl: 'http://127.0.0.1:8080',
                enableLog: true,
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
            deviceStatusProvider.overrideWith(
              (ref) async => const DeviceStatus(
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
            rememberedAccountControllerProvider.overrideWith(
              () => _TestRememberedAccountController(
                initialRememberedAccount: null,
              ),
            ),
          ],
          child: const MaterialApp(home: SettingsPage()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('本机不会长期保留登录状态'), findsOneWidget);
      expect(find.textContaining('关闭应用、清理后台或系统回收进程后，需要重新登录'), findsOneWidget);
    },
  );

  testWidgets('SettingsPage resets defaults', (tester) async {
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
          settingsControllerProvider.overrideWith(() => settingsController),
          deviceStatusProvider.overrideWith(
            (ref) async => const DeviceStatus(
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

    final resetButton = find.widgetWithText(OutlinedButton, '恢复默认');
    await tester.tap(resetButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('确认'));
    await tester.pumpAndSettle();

    expect(settingsController.resetCount, 1);
    expect(find.text('已恢复默认。'), findsOneWidget);
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
          settingsControllerProvider.overrideWith(
            () => _TestSettingsController(
              initialSettings: AppSettings.defaults(
                buildFlavor: BuildFlavor.development,
                baseUrl: 'http://127.0.0.1:8080',
                enableLog: true,
              ),
            ),
          ),
          deviceStatusProvider.overrideWith(
            (ref) async => const DeviceStatus(
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

  testWidgets('SettingsPage renders mobile layout without overflow', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(390, 844)
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
          settingsControllerProvider.overrideWith(() => settingsController),
          deviceStatusProvider.overrideWith(
            (ref) async => const DeviceStatus(
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
            () => _TestAuthController(
              initialState: const AuthState(
                session: AuthSession(
                  accessToken: 'token_demo',
                  loginMode: AuthLoginMode.mock,
                  user: AuthUser(
                    userId: 'user_demo',
                    account: 'demo',
                    displayName: '联调账号',
                  ),
                ),
              ),
            ),
          ),
          rememberedAccountControllerProvider.overrideWith(
            () => _TestRememberedAccountController(
              initialRememberedAccount: 'ops_admin',
            ),
          ),
        ],
        child: const MaterialApp(home: SettingsPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(WorkspaceBottomNavigation), findsOneWidget);
    expect(find.text('当前使用'), findsWidgets);
    expect(find.text('记住的账号'), findsOneWidget);
    expect(tester.takeException(), isNull);
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
