import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/features/auth/auth_session.dart';
import 'package:sickandflutter/features/auth/mock_auth_repository.dart';
import 'package:sickandflutter/features/auth/real_auth_repository.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';

/// 登录仓储入口。
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final envConfig = ref.watch(envConfigProvider);
  final useMock =
      envConfig.flavor != BuildFlavor.production &&
      const bool.fromEnvironment('USE_MOCK_AUTH', defaultValue: false);

  if (useMock) {
    return const MockAuthRepository();
  }

  return RealAuthRepository(
    envConfig: envConfig,
    currentSettingsBuilder: () {
      final settings = ref.read(effectiveAppSettingsProvider);
      final serviceEndpoints = ref.read(resolvedServiceEndpointsProvider);
      return settings.copyWith(baseUrl: serviceEndpoints.deviceBaseUrl);
    },
  );
});

/// 认证仓储统一入口。
abstract class AuthRepository {
  /// 当前仓储是否为联调模式。
  bool get isMockMode;

  /// 当前登录模式。
  AuthLoginMode get loginMode;

  /// 使用用户名密码执行登录。
  Future<AuthSession> login({
    required String username,
    required String password,
  });

  /// 使用用户名、密码和确认密码执行注册。
  Future<String> register({
    required String username,
    required String password,
    required String confirmPassword,
  });

  /// 根据当前会话尝试刷新登录态。
  Future<AuthSession> refreshSession({required AuthSession session});

  /// 通知后端当前会话已退出。
  Future<void> logout({required AuthSession session});
}

/// 提供认证仓储的派生展示属性。
extension AuthRepositoryX on AuthRepository {
  /// 当前登录模式说明。
  String get loginModeLabel => loginMode.label;
}
