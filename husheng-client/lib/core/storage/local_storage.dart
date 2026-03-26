import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sickandflutter/shared/models/model_utils.dart';

/// 暴露底层 `SharedPreferences` 实例。
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return SharedPreferences.getInstance();
});

/// 暴露经过轻量封装的本地存储服务。
final localStorageProvider = FutureProvider<LocalStorage>((ref) async {
  final sharedPreferences = await ref.watch(sharedPreferencesProvider.future);
  return LocalStorage(sharedPreferences);
});

/// 统一封装字符串和 JSON 读写，减少页面直接依赖存储细节。
class LocalStorage {
  /// 基于 `SharedPreferences` 创建本地存储服务。
  const LocalStorage(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;

  /// 读取字符串值。
  String? readString(String key) => _sharedPreferences.getString(key);

  /// 写入字符串值。
  Future<void> writeString(String key, String value) async {
    await _sharedPreferences.setString(key, value);
  }

  /// 将 JSON 对象编码后写入本地存储。
  Future<void> writeJson(String key, Map<String, dynamic> value) async {
    await writeString(key, jsonEncode(value));
  }

  /// 读取并解码 JSON 对象。
  Map<String, dynamic>? readJson(String key) {
    final rawValue = readString(key);
    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    try {
      return asStringMap(jsonDecode(rawValue));
    } on FormatException {
      return null;
    }
  }

  /// 删除指定键对应的值。
  Future<void> remove(String key) async {
    await _sharedPreferences.remove(key);
  }
}
