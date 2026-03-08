import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/core/network/api_client.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/core/utils/platform_utils.dart';
import 'package:sickandflutter/features/auth/auth_repository.dart';
import 'package:sickandflutter/features/auth/auth_session.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/model_utils.dart';

/// 真实认证接口实现。
class RealAuthRepository implements AuthRepository {
  /// 创建真实认证仓储。
  const RealAuthRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  bool get isMockMode => false;

  @override
  String get loginModeLabel => AppCopy.authLoginModeReal;

  @override
  Future<AuthSession> login({
    required String account,
    required String password,
  }) async {
    final response = await _apiClient.postResponse<Map<String, dynamic>>(
      '/api/v1/auth/login',
      data: <String, dynamic>{
        'account': account.trim(),
        'password': password,
        'platform': currentPlatformType().value,
      },
      dataParser: asStringMap,
    );

    if (!response.isSuccess) {
      throw ApiException(
        message: response.message.trim().isEmpty
            ? AppCopy.authLoginFailedRetry
            : response.message,
        businessCode: response.code,
      );
    }

    final payload = response.data;
    if (payload == null) {
      throw ApiException(
        message: AppCopy.authLoginMissingData,
        businessCode: response.code,
      );
    }

    return AuthSession.fromJson(<String, dynamic>{
      ...payload,
      'loginModeLabel': loginModeLabel,
    });
  }

  @override
  Future<AuthSession> refreshSession({required AuthSession session}) async {
    if (!session.hasRefreshToken) {
      throw const ApiException(message: AppCopy.authRefreshTokenMissing);
    }

    final response = await _apiClient.postResponse<Map<String, dynamic>>(
      '/api/v1/auth/refresh',
      data: <String, dynamic>{
        'refreshToken': session.refreshToken,
        'platform': currentPlatformType().value,
      },
      dataParser: asStringMap,
    );

    if (!response.isSuccess) {
      throw ApiException(
        message: response.message.trim().isEmpty
            ? AppCopy.authRefreshRetry
            : response.message,
        businessCode: response.code,
      );
    }

    final payload = response.data;
    if (payload == null) {
      throw ApiException(
        message: AppCopy.authRefreshMissingData,
        businessCode: response.code,
      );
    }

    return AuthSession.fromJson(<String, dynamic>{
      ...payload,
      'loginModeLabel': loginModeLabel,
    });
  }

  @override
  Future<void> logout({required AuthSession session}) async {
    final response = await _apiClient.postResponse<Map<String, dynamic>>(
      '/api/v1/auth/logout',
      data: <String, dynamic>{
        'refreshToken': session.refreshToken,
        'platform': currentPlatformType().value,
      },
      dataParser: asStringMap,
    );

    if (!response.isSuccess) {
      throw ApiException(
        message: response.message.trim().isEmpty
            ? AppCopy.authLogoutFailed
            : response.message,
        businessCode: response.code,
      );
    }
  }
}
