// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthUser _$AuthUserFromJson(Map<String, dynamic> json) => AuthUser(
  userId: parseStringValue(json['userId']),
  account: parseStringValue(json['account']),
  displayName: parseStringValue(json['displayName']),
  roles: json['roles'] == null
      ? const <String>[]
      : parseStringListValue(json['roles']),
);

Map<String, dynamic> _$AuthUserToJson(AuthUser instance) => <String, dynamic>{
  'userId': instance.userId,
  'account': instance.account,
  'displayName': instance.displayName,
  'roles': stringListToJson(instance.roles),
};
