import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/features/auth/auth_repository.dart';
import 'package:sickandflutter/features/auth/auth_session.dart';
import 'package:sickandflutter/features/auth/auth_user.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';

/// 开发和测试环境使用的受控登录替身实现。
class MockAuthRepository implements AuthRepository {
  /// 创建替身认证仓储。
  const MockAuthRepository({
    this.responseDelay = const Duration(milliseconds: 650),
  });

  /// 模拟请求耗时。
  final Duration responseDelay;

  /// 演示登录账号。
  static const String demoAccount = 'demo';

  /// 演示登录密码。
  static const String demoPassword = 'demo123456';

  @override
  bool get isMockMode => true;

  @override
  AuthLoginMode get loginMode => AuthLoginMode.mock;

  @override
  Future<AuthSession> login({
    required String account,
    required String password,
  }) async {
    await Future<void>.delayed(responseDelay);

    final normalizedAccount = account.trim();
    final normalizedPassword = password.trim();
    final isDemoAccount =
        normalizedAccount == demoAccount && normalizedPassword == demoPassword;
    final isAllowedCustomAccount =
        normalizedAccount.length >= 3 && normalizedPassword.length >= 6;

    if (!isDemoAccount && !isAllowedCustomAccount) {
      throw const ApiException(
        businessCode: 40101,
        message: AppCopy.authCredentialInvalid,
      );
    }

    final now = DateTime.now();
    final expiresAt = now.add(const Duration(hours: 8)).toIso8601String();
    final displayName = normalizedAccount == demoAccount
        ? AppCopy.authMockDisplayName
        : AppCopy.authAdminDisplayName(normalizedAccount);

    return AuthSession(
      accessToken: 'mock_access_${now.microsecondsSinceEpoch}',
      refreshToken: 'mock_refresh_${now.microsecondsSinceEpoch}',
      tokenType: 'Bearer',
      expiresAt: expiresAt,
      loginMode: loginMode,
      user: AuthUser(
        userId: 'user_$normalizedAccount',
        account: normalizedAccount,
        displayName: displayName,
        roles: const <String>['app_user'],
      ),
    );
  }

  @override
  Future<AuthSession> refreshSession({required AuthSession session}) async {
    await Future<void>.delayed(const Duration(milliseconds: 220));

    return session.copyWith(
      accessToken: 'mock_access_${DateTime.now().microsecondsSinceEpoch}',
      expiresAt: DateTime.now().add(const Duration(hours: 8)).toIso8601String(),
      loginMode: loginMode,
    );
  }

  @override
  Future<void> logout({required AuthSession session}) async {
    await Future<void>.delayed(const Duration(milliseconds: 160));
  }
}
