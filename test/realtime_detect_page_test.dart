import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/network/api_client.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/auth/auth_session.dart';
import 'package:sickandflutter/features/auth/auth_user.dart';
import 'package:sickandflutter/features/realtime/realtime_detect_page.dart';
import 'package:sickandflutter/features/settings/device_state_repository.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/app_settings.dart';
import 'package:sickandflutter/shared/models/device_state_info.dart';

void main() {
  testWidgets('RealtimeDetectPage renders monitoring sections', (tester) async {
    final repository = _TestDeviceStateRepository(
      state: const DeviceStateInfo(
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
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
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
          deviceStateRepositoryProvider.overrideWith((ref) async => repository),
        ],
        child: const MaterialApp(home: RealtimeDetectPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('实时监控主控台'), findsOneWidget);
    expect(find.text('平台总览'), findsOneWidget);
    expect(find.text('运维设置'), findsOneWidget);
    expect(find.text('运行状态'), findsOneWidget);
    expect(find.text('系统运行正常'), findsWidgets);
    expect(find.text('石斛培育柜'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('温度'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('温度'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('运行明细与远程控制'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('运行明细与远程控制'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('状态说明'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('状态说明'), findsOneWidget);
  });
}

class _TestAuthController extends AuthController {
  _TestAuthController({required this.initialState});

  final AuthState initialState;

  @override
  AuthState build() => initialState;
}

class _TestDeviceStateRepository extends DeviceStateRepository {
  _TestDeviceStateRepository({required this.state})
    : super(
        apiClient: ApiClient(
          settings: AppSettings.defaults(buildFlavor: BuildFlavor.development),
          envConfig: const EnvConfig(
            flavor: BuildFlavor.development,
            baseUrl: 'http://127.0.0.1:8082',
            enableLog: true,
          ),
        ),
      );

  final DeviceStateInfo state;

  @override
  Future<DeviceStateInfo> fetchState() async => state;
}
