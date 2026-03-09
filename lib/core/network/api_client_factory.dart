import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/network/api_client.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/app_settings.dart';

/// 统一创建带认证能力的 API 客户端。
final apiClientFactoryProvider = Provider<ApiClientFactory>((ref) {
  final envConfig = ref.watch(envConfigProvider);
  final authState = ref.watch(authControllerProvider);
  final authController = ref.read(authControllerProvider.notifier);
  final session = authState.session;

  return ApiClientFactory(
    envConfig: envConfig,
    authorizationValue:
        session != null &&
            session.loginMode != AuthLoginMode.real &&
            !session.hasSessionCookie
        ? session.authorizationValue
        : null,
    cookieHeader: session?.sessionCookie,
    onUnauthorized: authController.handleUnauthorized,
  );
});

/// 基于当前环境和登录态创建 API 客户端。
class ApiClientFactory {
  /// 创建 API 客户端工厂。
  const ApiClientFactory({
    required EnvConfig envConfig,
    required this.authorizationValue,
    required this.cookieHeader,
    required this.onUnauthorized,
  }) : _envConfig = envConfig;

  final EnvConfig _envConfig;

  /// 当前登录态对应的认证头值。
  final String? authorizationValue;

  /// 当前登录态对应的会话 Cookie。
  final String? cookieHeader;

  /// 网络层发现未授权后的统一处理回调。
  final void Function({String? message}) onUnauthorized;

  /// 生成新的 API 客户端实例。
  ///
  /// `includeBrowserCredentials` 仅在 Web 端生效，用于按接口链路决定是否让
  /// 浏览器自动附带 Cookie，避免公共跨域接口被浏览器按“携带凭据请求”拦截。
  ApiClient create({
    required AppSettings settings,
    bool includeBrowserCredentials = false,
  }) {
    return ApiClient(
      settings: settings,
      envConfig: _envConfig,
      authorizationValue: authorizationValue,
      cookieHeader: cookieHeader,
      includeBrowserCredentials: includeBrowserCredentials,
      onUnauthorized: onUnauthorized,
    );
  }
}
