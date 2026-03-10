import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sickandflutter/core/storage/auth_storage.dart';
import 'package:sickandflutter/core/storage/sensitive_storage.dart';
import 'package:sickandflutter/features/auth/auth_repository.dart';
import 'package:sickandflutter/features/auth/auth_session.dart';
import 'package:sickandflutter/features/auth/auth_user.dart';
import 'package:sickandflutter/features/auth/login_page.dart';
import 'package:sickandflutter/features/auth/mock_auth_repository.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';

void main() {
  testWidgets('LoginPage shows register mode in real auth mode', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(
      _buildPage(authRepository: _FakeRealAuthRepository()),
    );
    await tester.pump();

    expect(find.text('注册'), findsOneWidget);

    await tester.tap(find.text('注册'));
    await tester.pumpAndSettle();

    expect(find.text('确认密码'), findsOneWidget);
    expect(find.text('用户名需为 3-32 位字母、数字或下划线，密码需为 6-32 位。'), findsOneWidget);
  });

  testWidgets('LoginPage hides register mode in mock auth mode', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await tester.pumpWidget(
      _buildPage(
        authRepository: const MockAuthRepository(responseDelay: Duration.zero),
      ),
    );
    await tester.pump();

    expect(find.text('注册'), findsNothing);
    expect(find.text('填充联调账号'), findsOneWidget);
  });
}

Widget _buildPage({required AuthRepository authRepository}) {
  return ProviderScope(
    overrides: [
      authStorageProvider.overrideWith(
        (ref) =>
            AuthStorage(VolatileSensitiveStorage(values: <String, String>{})),
      ),
      authRepositoryProvider.overrideWith((ref) => authRepository),
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
    required String account,
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
    required String account,
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
