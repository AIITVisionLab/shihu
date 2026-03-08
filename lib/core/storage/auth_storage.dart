import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/core/storage/local_storage.dart';
import 'package:sickandflutter/features/auth/auth_session.dart';

/// 登录会话存储入口。
final authStorageProvider = FutureProvider<AuthStorage>((ref) async {
  final storage = await ref.watch(localStorageProvider.future);
  return AuthStorage(storage);
});

/// 统一封装登录会话的本地读写。
class AuthStorage {
  /// 基于本地存储创建认证存储服务。
  const AuthStorage(this._storage);

  final LocalStorage _storage;

  /// 读取当前登录会话。
  AuthSession? readSession() {
    final sessionJson = _storage.readJson(AppConstants.authSessionStorageKey);
    if (sessionJson == null) {
      return null;
    }

    try {
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
    await _storage.writeJson(
      AppConstants.authSessionStorageKey,
      session.toJson(),
    );
  }

  /// 清除当前登录会话。
  Future<void> clearSession() async {
    await _storage.remove(AppConstants.authSessionStorageKey);
  }
}
