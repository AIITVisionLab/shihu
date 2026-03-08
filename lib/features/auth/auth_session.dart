import 'package:json_annotation/json_annotation.dart';
import 'package:sickandflutter/features/auth/auth_user.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/json_value_parsers.dart';
import 'package:sickandflutter/shared/models/model_utils.dart';

part 'auth_session.g.dart';

/// 当前登录会话模型。
@JsonSerializable(explicitToJson: true)
class AuthSession {
  /// 创建登录会话对象。
  const AuthSession({
    required this.accessToken,
    required this.user,
    this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresAt,
    this.loginMode = AuthLoginMode.real,
  });

  /// 从 JSON 构建登录会话对象。
  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final normalizedJson = <String, dynamic>{...json};
    normalizedJson['loginMode'] ??= normalizedJson['loginModeLabel'];
    return _$AuthSessionFromJson(normalizedJson);
  }

  /// 当前访问令牌。
  @JsonKey(fromJson: parseStringValue)
  final String accessToken;

  /// 刷新令牌。
  @JsonKey(fromJson: parseNullableStringValue, toJson: _nullableStringToJson)
  final String? refreshToken;

  /// 认证头类型。
  @JsonKey(fromJson: _tokenTypeFromJson)
  final String tokenType;

  /// 会话到期时间。
  @JsonKey(fromJson: parseNullableStringValue, toJson: _nullableStringToJson)
  final String? expiresAt;

  /// 当前登录模式。
  @JsonKey(fromJson: _authLoginModeFromJson, toJson: _authLoginModeToJson)
  final AuthLoginMode loginMode;

  /// 当前登录用户。
  @JsonKey(fromJson: _authUserFromJson, toJson: _authUserToJson)
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
    AuthLoginMode? loginMode,
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
      loginMode: loginMode ?? this.loginMode,
      user: user ?? this.user,
    );
  }

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => _$AuthSessionToJson(this);
}

const Object _authSessionUnset = Object();

String _tokenTypeFromJson(Object? value) {
  return asString(value, fallback: 'Bearer');
}

String? _nullableStringToJson(String? value) => value;

AuthLoginMode _authLoginModeFromJson(Object? value) {
  return authLoginModeFromValue(asNullableString(value));
}

String _authLoginModeToJson(AuthLoginMode value) => value.value;

AuthUser _authUserFromJson(Object? value) {
  return AuthUser.fromJson(parseStringMapValue(value));
}

Map<String, dynamic> _authUserToJson(AuthUser value) => value.toJson();
