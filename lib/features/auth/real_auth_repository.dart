import 'package:dio/dio.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/core/network/api_client.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/core/utils/platform_utils.dart';
import 'package:sickandflutter/features/auth/auth_repository.dart';
import 'package:sickandflutter/features/auth/auth_session.dart';
import 'package:sickandflutter/features/auth/auth_user.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/app_settings.dart';
import 'package:sickandflutter/shared/models/model_utils.dart';

/// 真实认证接口实现。
class RealAuthRepository implements AuthRepository {
  /// 创建真实认证仓储。
  const RealAuthRepository({
    this.apiClient,
    this.envConfig,
    this.currentSettingsBuilder,
  }) : assert(
         apiClient != null ||
             (envConfig != null && currentSettingsBuilder != null),
         '真实认证仓储必须提供 apiClient，或同时提供 envConfig 和 currentSettingsBuilder。',
       );

  /// 用于测试替身或固定地址场景的直接客户端。
  final ApiClient? apiClient;

  /// 当前环境配置。
  final EnvConfig? envConfig;

  /// 当前运行时生效设置读取器。
  final AppSettings Function()? currentSettingsBuilder;

  @override
  bool get isMockMode => false;

  @override
  AuthLoginMode get loginMode => AuthLoginMode.real;

  @override
  Future<AuthSession> login({
    required String username,
    required String password,
  }) async {
    final normalizedUsername = username.trim();
    final response = await _createClient().postJsonDetailed(
      '/api/login',
      data: <String, dynamic>{
        'username': normalizedUsername,
        'password': password,
      },
    );
    final payload = _requirePayload(
      response.data,
      fallbackMessage: AppCopy.authLoginFailedRetry,
    );
    _throwWhenRequestFailed(
      payload,
      fallbackFailureMessage: AppCopy.authCredentialInvalid,
    );

    return AuthSession(
      accessToken: 'session:${DateTime.now().millisecondsSinceEpoch}',
      sessionCookie: _extractSessionCookie(response.headers),
      tokenType: 'Session',
      loginMode: loginMode,
      user: AuthUser(
        userId: normalizedUsername,
        account: normalizedUsername,
        displayName: normalizedUsername,
      ),
    );
  }

  @override
  Future<String> register({
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    final normalizedUsername = username.trim();
    final payload = await _createClient().postJson(
      '/api/register',
      data: <String, dynamic>{
        'username': normalizedUsername,
        'password': password,
        'confirmPassword': confirmPassword,
      },
    );
    _throwWhenRequestFailed(
      payload,
      fallbackFailureMessage: AppCopy.authRegisterFailedRetry,
    );
    return _resolveMessage(
      payload['message'],
      fallbackMessage: AppCopy.authRegisterSuccessDefault,
    );
  }

  @override
  Future<AuthSession> refreshSession({required AuthSession session}) async {
    final response = await _createClient(
      sessionCookie: session.hasSessionCookie ? session.sessionCookie : null,
    ).getJson('/api/check-login');
    if (response['loggedIn'] == true) {
      final refreshedAccount = asString(
        response['username'],
        fallback: session.user.account,
      ).trim();
      final effectiveAccount = refreshedAccount.isEmpty
          ? session.user.account
          : refreshedAccount;

      return session.copyWith(
        user: AuthUser(
          userId: effectiveAccount,
          account: effectiveAccount,
          displayName: effectiveAccount,
          roles: session.user.roles,
        ),
      );
    }
    throw const ApiException(message: AppCopy.authSessionExpired);
  }

  @override
  Future<void> logout({required AuthSession session}) async {
    final raw = await _createClient(
      sessionCookie: session.hasSessionCookie ? session.sessionCookie : null,
    ).postJson('/api/logout', data: <String, dynamic>{});
    _throwWhenRequestFailed(
      raw,
      fallbackFailureMessage: AppCopy.authLogoutFailed,
    );
  }

  Map<String, dynamic> _requirePayload(
    Map<String, dynamic>? payload, {
    required String fallbackMessage,
  }) {
    if (payload == null) {
      throw ApiException(message: fallbackMessage);
    }
    return payload;
  }

  void _throwWhenRequestFailed(
    Map<String, dynamic> payload, {
    required String fallbackFailureMessage,
  }) {
    final success = payload['success'] == true;
    if (success) {
      return;
    }

    throw ApiException(
      message: _resolveMessage(
        payload['message'],
        fallbackMessage: fallbackFailureMessage,
      ),
    );
  }

  String _resolveMessage(
    Object? rawMessage, {
    required String fallbackMessage,
  }) {
    final message = asString(rawMessage).trim();
    if (message.isEmpty) {
      return fallbackMessage;
    }
    return message;
  }

  String? _extractSessionCookie(Headers headers) {
    if (currentPlatformType() == PlatformType.web) {
      return null;
    }

    final rawCookies = headers['set-cookie'];
    if (rawCookies == null || rawCookies.isEmpty) {
      return null;
    }

    for (final rawCookie in rawCookies) {
      final cookiePair = rawCookie.split(';').first.trim();
      if (cookiePair.startsWith('JSESSIONID=')) {
        return cookiePair;
      }
    }

    return null;
  }

  ApiClient _createClient({String? sessionCookie}) {
    final fixedApiClient = apiClient;
    if (fixedApiClient != null) {
      return fixedApiClient;
    }

    return ApiClient(
      settings: currentSettingsBuilder!(),
      envConfig: envConfig!,
      cookieHeader: sessionCookie,
      includeBrowserCredentials: true,
    );
  }
}
