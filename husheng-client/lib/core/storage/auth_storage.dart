import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/core/storage/sensitive_storage.dart';
import 'package:sickandflutter/features/auth/auth_session.dart';
import 'package:sickandflutter/shared/models/model_utils.dart';

/// 登录会话存储入口。
final authStorageProvider = Provider<AuthStorage>((ref) {
  final storage = ref.watch(sensitiveStorageProvider);
  return AuthStorage(storage);
});

/// 统一封装登录会话的本地读写。
class AuthStorage {
  /// 基于本地存储创建认证存储服务。
  const AuthStorage(this._storage);

  final SensitiveStorage _storage;

  /// 读取当前登录会话。
  Future<AuthSession?> readSession() async {
    final rawValue = await _storage.readString(
      AppConstants.authSessionStorageKey,
    );
    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    try {
      final sessionJson = asStringMap(jsonDecode(rawValue));
      if (sessionJson == null) {
        return null;
      }

      final session = AuthSession.fromJson(sessionJson);
      if (session.accessToken.trim().isEmpty || session.user.userId.isEmpty) {
        return null;
      }
      return session;
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  /// 写入当前登录会话。
  Future<void> writeSession(AuthSession session) async {
    await _storage.writeString(
      AppConstants.authSessionStorageKey,
      jsonEncode(session.toJson()),
    );
  }

  /// 清除当前登录会话。
  Future<void> clearSession() async {
    await _storage.remove(AppConstants.authSessionStorageKey);
  }
}
