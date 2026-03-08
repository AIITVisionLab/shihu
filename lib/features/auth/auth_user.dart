import 'package:sickandflutter/shared/models/model_utils.dart';

/// 当前登录用户信息。
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
    return AuthUser(
      userId: asString(json['userId']),
      account: asString(json['account']),
      displayName: asString(
        json['displayName'],
        fallback: asString(json['name']),
      ),
      roles: asStringList(json['roles']),
    );
  }

  /// 用户 ID。
  final String userId;

  /// 登录账号。
  final String account;

  /// 展示名称。
  final String displayName;

  /// 当前角色列表。
  final List<String> roles;

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'userId': userId,
      'account': account,
      'displayName': displayName,
      'roles': roles,
    };
  }
}
