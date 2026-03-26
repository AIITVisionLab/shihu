import 'package:json_annotation/json_annotation.dart';
import 'package:sickandflutter/shared/models/json_value_parsers.dart';

part 'auth_user.g.dart';

/// 当前登录用户信息。
@JsonSerializable()
class AuthUser {
  /// 创建登录用户对象。
  const AuthUser({
    required this.userId,
    required this.account,
    required this.displayName,
    this.roles = const <String>[],
  });

  /// 从 JSON 构建登录用户对象。
  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final normalizedJson = <String, dynamic>{...json};
    normalizedJson['displayName'] ??= normalizedJson['name'];
    return _$AuthUserFromJson(normalizedJson);
  }

  /// 用户 ID。
  @JsonKey(fromJson: parseStringValue)
  final String userId;

  /// 登录账号。
  @JsonKey(fromJson: parseStringValue)
  final String account;

  /// 展示名称。
  @JsonKey(fromJson: parseStringValue)
  final String displayName;

  /// 当前角色列表。
  @JsonKey(fromJson: parseStringListValue, toJson: stringListToJson)
  final List<String> roles;

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => _$AuthUserToJson(this);
}
