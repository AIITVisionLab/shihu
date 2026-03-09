import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/core/storage/local_storage.dart';

/// 记住用户名仓储 Provider。
final rememberedAccountRepositoryProvider =
    FutureProvider<RememberedAccountRepository>((ref) async {
      final storage = await ref.watch(localStorageProvider.future);
      return RememberedAccountRepository(storage);
    });

/// 统一封装登录页“记住用户名”的本地读写。
class RememberedAccountRepository {
  /// 基于本地存储创建仓储。
  const RememberedAccountRepository(this._storage);

  final LocalStorage _storage;

  /// 读取已记住的账号。
  String? readRememberedAccount() {
    return _storage.readString(AppConstants.rememberedAccountStorageKey);
  }

  /// 写入已记住的账号。
  Future<void> saveRememberedAccount(String account) async {
    await _storage.writeString(
      AppConstants.rememberedAccountStorageKey,
      account.trim(),
    );
  }

  /// 清空已记住的账号。
  Future<void> clearRememberedAccount() async {
    await _storage.remove(AppConstants.rememberedAccountStorageKey);
  }
}
