import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/network/api_client.dart';
import 'package:sickandflutter/features/auth/auth_session.dart';
import 'package:sickandflutter/features/auth/mock_auth_repository.dart';
import 'package:sickandflutter/features/auth/real_auth_repository.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/app_settings.dart';

/// 登录仓储入口。
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final envConfig = ref.watch(envConfigProvider);
  final useMock =
      envConfig.flavor != BuildFlavor.production &&
      const bool.fromEnvironment('USE_MOCK_AUTH', defaultValue: true);

  if (useMock) {
    return const MockAuthRepository();
  }

  final settings = _resolveSettings(ref, envConfig);
  return RealAuthRepository(
    apiClient: ApiClient(settings: settings, envConfig: envConfig),
  );
});

AppSettings _resolveSettings(Ref ref, EnvConfig envConfig) {
  final settingsState = ref.watch(settingsControllerProvider);
  return settingsState.asData?.value ??
      AppSettings.defaults(
        buildFlavor: envConfig.flavor,
        baseUrl: envConfig.baseUrl,
        enableLog: envConfig.enableLog,
      );
}

/// 认证仓储统一入口。
abstract class AuthRepository {
  /// 当前仓储是否为 mock 模式。
  bool get isMockMode;

  /// 当前登录模式说明。
  String get loginModeLabel;

  /// 使用账号密码执行登录。
  Future<AuthSession> login({
    required String account,
    required String password,
  });

  /// 根据当前会话尝试刷新登录态。
  Future<AuthSession> refreshSession({required AuthSession session});

  /// 通知后端当前会话已退出。
  Future<void> logout({required AuthSession session});
}
