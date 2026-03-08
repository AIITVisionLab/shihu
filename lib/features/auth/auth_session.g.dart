// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthSession _$AuthSessionFromJson(Map<String, dynamic> json) => AuthSession(
  accessToken: parseStringValue(json['accessToken']),
  user: _authUserFromJson(json['user']),
  refreshToken: parseNullableStringValue(json['refreshToken']),
  sessionCookie: parseNullableStringValue(json['sessionCookie']),
  tokenType: json['tokenType'] == null
      ? 'Bearer'
      : _tokenTypeFromJson(json['tokenType']),
  expiresAt: parseNullableStringValue(json['expiresAt']),
  loginMode: json['loginMode'] == null
      ? AuthLoginMode.real
      : _authLoginModeFromJson(json['loginMode']),
);

Map<String, dynamic> _$AuthSessionToJson(AuthSession instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': _nullableStringToJson(instance.refreshToken),
      'sessionCookie': _nullableStringToJson(instance.sessionCookie),
      'tokenType': instance.tokenType,
      'expiresAt': _nullableStringToJson(instance.expiresAt),
      'loginMode': _authLoginModeToJson(instance.loginMode),
      'user': _authUserToJson(instance.user),
    };
