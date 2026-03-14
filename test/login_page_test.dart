import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/storage/auth_storage.dart';
import 'package:sickandflutter/core/storage/sensitive_storage.dart';
import 'package:sickandflutter/features/auth/auth_repository.dart';
import 'package:sickandflutter/features/auth/auth_session.dart';
import 'package:sickandflutter/features/auth/auth_user.dart';
import 'package:sickandflutter/features/auth/login_page.dart';
import 'package:sickandflutter/features/auth/mock_auth_repository.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/app_settings.dart';

void main() {
  testWidgets('LoginPage shows register mode in real auth mode', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1200, 1600)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(
      _buildPage(authRepository: _FakeRealAuthRepository()),
    );
    await tester.pump();

    expect(find.text('注册'), findsOneWidget);
    expect(find.text('先看界面'), findsNothing);

    await tester.tap(find.text('注册'));
    await tester.pumpAndSettle();

    expect(find.text('确认密码'), findsOneWidget);
    expect(find.text('账号需为 3-32 位字母、数字或下划线；密码需为 6-32 位。'), findsOneWidget);
  });

  testWidgets('LoginPage hides register mode in mock auth mode', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1200, 1600)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(
      _buildPage(
        authRepository: const MockAuthRepository(responseDelay: Duration.zero),
      ),
    );
    await tester.pump();

    expect(find.text('注册'), findsNothing);
    expect(find.text('填入演示账号'), findsNothing);
  });

  testWidgets('LoginPage can restore custom service config before login', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1200, 1600)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues(<String, Object>{});
    const envConfig = EnvConfig(
      flavor: BuildFlavor.development,
      baseUrl: 'http://127.0.0.1:8080',
      enableLog: true,
    );
    final settingsController = _TestSettingsController(
      initialSettings: AppSettings.defaults(
        buildFlavor: BuildFlavor.development,
        baseUrl: 'http://192.168.1.20:8080',
        enableLog: true,
      ),
    );

    await tester.pumpWidget(
      _buildPage(
        authRepository: _FakeRealAuthRepository(),
        envConfig: envConfig,
        settingsController: settingsController,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('已切换到其他服务'), findsOneWidget);
    expect(find.text('恢复默认服务地址'), findsOneWidget);

    await tester.tap(find.text('恢复默认服务地址'));
    await tester.pumpAndSettle();

    expect(settingsController.resetCount, 1);
    expect(find.text('已恢复默认服务地址，请重新尝试登录。'), findsOneWidget);
  });

  testWidgets('LoginPage renders mobile layout without overflow', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(
      _buildPage(authRepository: _FakeRealAuthRepository()),
    );
    await tester.pumpAndSettle();

    expect(find.text('默认进入值守台'), findsOneWidget);
    expect(find.text('欢迎回来'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Widget _buildPage({
  required AuthRepository authRepository,
  EnvConfig? envConfig,
  SettingsController? settingsController,
}) {
  return ProviderScope(
    overrides: [
      authStorageProvider.overrideWith(
        (ref) =>
            AuthStorage(VolatileSensitiveStorage(values: <String, String>{})),
      ),
      authRepositoryProvider.overrideWith((ref) => authRepository),
      if (envConfig != null) envConfigProvider.overrideWith((ref) => envConfig),
      if (settingsController != null)
        settingsControllerProvider.overrideWith(() => settingsController),
    ],
    child: const MaterialApp(home: LoginPage()),
  );
}

class _FakeRealAuthRepository implements AuthRepository {
  @override
  bool get isMockMode => false;

  @override
  AuthLoginMode get loginMode => AuthLoginMode.real;

  @override
  Future<AuthSession> login({
    required String username,
    required String password,
  }) async {
    return const AuthSession(
      accessToken: 'session:1',
      user: AuthUser(userId: 'demo', account: 'demo', displayName: 'demo'),
    );
  }

  @override
  Future<void> logout({required AuthSession session}) async {}

  @override
  Future<String> register({
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    return '注册成功，请使用新账号登录。';
  }

  @override
  Future<AuthSession> refreshSession({required AuthSession session}) async {
    return session;
  }
}

class _TestSettingsController extends SettingsController {
  _TestSettingsController({required this.initialSettings});

  final AppSettings initialSettings;
  int resetCount = 0;

  @override
  Future<AppSettings> build() async => initialSettings;

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
