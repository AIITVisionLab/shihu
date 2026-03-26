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
import 'package:sickandflutter/features/platform_logs/application/platform_log_providers.dart';
import 'package:sickandflutter/features/platform_logs/domain/platform_log_entry.dart';
import 'package:sickandflutter/features/service_config/application/service_config_providers.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';
import 'package:sickandflutter/features/settings/settings_page.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/app_settings.dart';
import 'package:sickandflutter/shared/models/service_health_info.dart';

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
        baseUrl: 'http://127.0.0.1:8085',
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
          ..._buildBackendStatusOverrides(),
        ],
        child: const MaterialApp(home: SettingsPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('当前使用'), findsWidgets);
    expect(find.text('石斛培育柜'), findsWidgets);
    expect(find.textContaining('当前采集和控制链路处于正常区间'), findsOneWidget);
    expect(find.text('2025-03-08 10:00'), findsOneWidget);
    expect(find.textContaining('数据已滞后'), findsOneWidget);
    expect(find.text('已开启'), findsOneWidget);
    expect(find.text('demo'), findsWidgets);
    expect(find.text('当前已登录，可以直接继续使用。'), findsOneWidget);
    expect(find.text('当前为界面预览，设备状态、视频和服务结果使用本地样例数据，不依赖在线接口。'), findsOneWidget);
    expect(find.text('账号与本机'), findsOneWidget);
    expect(find.text('服务健康检查'), findsNothing);
    expect(find.text('平台日志'), findsOneWidget);
    expect(find.text('状态上报 / AI 巡检'), findsOneWidget);
    expect(find.text('/tmp/platform-events.log'), findsOneWidget);
    expect(find.text('补光指令已下发'), findsOneWidget);
    expect(find.text('结果 · 已下发'), findsOneWidget);
    expect(find.text('记住的账号'), findsOneWidget);
    expect(find.text('ops_admin'), findsOneWidget);
    expect(find.text('打开使用帮助'), findsOneWidget);
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
            ..._buildBackendStatusOverrides(),
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
        baseUrl: 'http://127.0.0.1:8085',
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
          ..._buildBackendStatusOverrides(),
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
          ..._buildBackendStatusOverrides(),
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

  testWidgets('SettingsPage applies platform log keyword filter', (
    tester,
  ) async {
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
          serviceHealthProvider.overrideWith(
            (ref) async => const ServiceHealthInfo(
              status: 'up',
              responseText: 'ok',
              checkedAt: '2025-03-17T10:12:00+08:00',
            ),
          ),
          platformLogOverviewProvider.overrideWith((ref) async {
            final query = ref.watch(platformLogQueryProvider);
            const entries = <PlatformLogEntry>[
              PlatformLogEntry(
                eventId: 'evt_ai',
                timestampMs: 1742193600000,
                type: 'AI_DETECTION',
                deviceId: 'dev_1',
                summary: '识别到蚜虫风险',
                details: <String, Object>{
                  'deviceName': '石斛培育柜',
                  'overallRiskLevel': 'HIGH',
                  'message': '检测到蚜虫',
                },
              ),
              PlatformLogEntry(
                eventId: 'evt_led',
                timestampMs: 1742193500000,
                type: 'ONENET_COMMAND',
                deviceId: 'dev_1',
                summary: 'Issued LED command for device dev_1, status=accepted',
                details: <String, Object>{
                  'deviceName': '石斛培育柜',
                  'led': true,
                  'status': 'accepted',
                },
              ),
            ];
            final keyword = query.normalizedKeyword.toLowerCase();
            final filteredEntries = entries
                .where((entry) {
                  if (keyword.isEmpty) {
                    return true;
                  }
                  return entry.summary.toLowerCase().contains(keyword) ||
                      entry.detailsPreview.toLowerCase().contains(keyword);
                })
                .take(query.limit)
                .toList(growable: false);

            return PlatformLogOverview(
              summary: const PlatformLogSummary(
                count: 2,
                file: '/tmp/platform-events.log',
                supportedTypes: <String>['AI_DETECTION', 'ONENET_COMMAND'],
              ),
              recentEntries: filteredEntries,
            );
          }),
        ],
        child: const MaterialApp(home: SettingsPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('补光指令已下发'), findsOneWidget);
    expect(find.text('收到新的 AI 巡检结果'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '蚜虫');
    await tester.tap(find.text('查询日志'));
    await tester.pumpAndSettle();

    expect(find.text('收到新的 AI 巡检结果'), findsOneWidget);
    expect(find.text('补光指令已下发'), findsNothing);
    expect(find.textContaining('关键字 蚜虫'), findsOneWidget);
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
        baseUrl: 'http://127.0.0.1:8085',
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
          ..._buildBackendStatusOverrides(),
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

List _buildBackendStatusOverrides() {
  return <Object>[
    serviceHealthProvider.overrideWith(
      (ref) async => const ServiceHealthInfo(
        status: 'up',
        responseText: 'ok',
        checkedAt: '2025-03-17T10:12:00+08:00',
      ),
    ),
    platformLogOverviewProvider.overrideWith(
      (ref) async => const PlatformLogOverview(
        summary: PlatformLogSummary(
          count: 12,
          file: '/tmp/platform-events.log',
          supportedTypes: <String>['ONENET_UPLINK', 'AI_DETECTION'],
        ),
        recentEntries: <PlatformLogEntry>[
          PlatformLogEntry(
            eventId: 'evt_1',
            timestampMs: 1742193600000,
            type: 'ONENET_COMMAND',
            deviceId: 'dev_1',
            summary: 'Issued LED command for device dev_1, status=accepted',
            details: <String, Object>{
              'deviceName': '石斛培育柜',
              'led': true,
              'status': 'accepted',
              'requestId': 'req_123',
              'message': 'LED command has been dispatched through OneNET',
            },
          ),
        ],
      ),
    ),
  ];
}
