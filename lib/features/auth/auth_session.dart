import 'package:sickandflutter/features/auth/auth_user.dart';
import 'package:sickandflutter/shared/models/model_utils.dart';

/// 当前登录会话模型。
class AuthSession {
  /// 创建登录会话对象。
  const AuthSession({
    required this.accessToken,
    required this.user,
    this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresAt,
    this.loginModeLabel = '真实接口登录',
  });

  /// 从 JSON 构建登录会话对象。
  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accessToken: asString(json['accessToken']),
      refreshToken: asNullableString(json['refreshToken']),
      tokenType: asString(json['tokenType'], fallback: 'Bearer'),
      expiresAt: asNullableString(json['expiresAt']),
      loginModeLabel: asString(json['loginModeLabel'], fallback: '真实接口登录'),
      user: AuthUser.fromJson(
        asStringMap(json['user']) ?? const <String, dynamic>{},
      ),
    );
  }

  /// 当前访问令牌。
  final String accessToken;

  /// 刷新令牌。
  final String? refreshToken;

  /// 认证头类型。
  final String tokenType;

  /// 会话到期时间。
  final String? expiresAt;

  /// 当前登录模式说明。
  final String loginModeLabel;

  /// 当前登录用户。
  final AuthUser user;

  /// 是否存在可用刷新令牌。
  bool get hasRefreshToken =>
      refreshToken != null && refreshToken!.trim().isNotEmpty;

  /// 是否已经过期。
  bool get isExpired {
    final rawValue = expiresAt?.trim();
    if (rawValue == null || rawValue.isEmpty) {
      return false;
    }

    final dateTime = DateTime.tryParse(rawValue);
    if (dateTime == null) {
      return false;
    }

    return DateTime.now().isAfter(dateTime.toLocal());
  }

  /// 返回用于 HTTP 头的认证值。
  String get authorizationValue {
    final normalizedType = tokenType.trim().isEmpty ? 'Bearer' : tokenType;
    return '$normalizedType $accessToken';
  }

  /// 返回带增量修改的新会话对象。
  AuthSession copyWith({
    String? accessToken,
    Object? refreshToken = _authSessionUnset,
    String? tokenType,
    Object? expiresAt = _authSessionUnset,
    String? loginModeLabel,
    AuthUser? user,
  }) {
    return AuthSession(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: identical(refreshToken, _authSessionUnset)
          ? this.refreshToken
          : refreshToken as String?,
      tokenType: tokenType ?? this.tokenType,
      expiresAt: identical(expiresAt, _authSessionUnset)
          ? this.expiresAt
          : expiresAt as String?,
      loginModeLabel: loginModeLabel ?? this.loginModeLabel,
      user: user ?? this.user,
    );
  }

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'tokenType': tokenType,
      'expiresAt': expiresAt,
      'loginModeLabel': loginModeLabel,
      'user': user.toJson(),
    };
  }
}

const Object _authSessionUnset = Object();
