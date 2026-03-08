import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sickandflutter/core/utils/platform_utils.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';

final bool _isFlutterTestEnvironment = const bool.fromEnvironment(
  'FLUTTER_TEST',
);

/// 暴露敏感信息存储入口。
///
/// 生产环境默认走系统安全存储；当前 `OpenHarmony / 鸿蒙`
/// 在仓库内没有稳定的安全存储实现时，退回进程内会话缓存，
/// 避免把令牌落入普通本地持久化。
final sensitiveStorageProvider = Provider<SensitiveStorage>((ref) {
  if (_isFlutterTestEnvironment || currentPlatformType() == PlatformType.ohos) {
    return VolatileSensitiveStorage();
  }

  return const SecureSensitiveStorage();
});

/// 敏感数据存储抽象。
abstract class SensitiveStorage {
  /// 创建敏感数据存储抽象。
  const SensitiveStorage();

  /// 当前存储是否具备进程外持久化能力。
  bool get supportsPersistence;

  /// 读取敏感字符串。
  Future<String?> readString(String key);

  /// 写入敏感字符串。
  Future<void> writeString(String key, String value);

  /// 删除指定敏感值。
  Future<void> remove(String key);
}

/// 基于系统安全能力封装敏感数据存储。
class SecureSensitiveStorage extends SensitiveStorage {
  /// 创建系统安全存储适配器。
  const SecureSensitiveStorage({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  final FlutterSecureStorage _storage;

  @override
  bool get supportsPersistence => true;

  @override
  Future<String?> readString(String key) => _storage.read(key: key);

  @override
  Future<void> writeString(String key, String value) {
    return _storage.write(key: key, value: value);
  }

  @override
  Future<void> remove(String key) => _storage.delete(key: key);
}

/// 仅保留进程内会话的敏感存储兜底实现。
class VolatileSensitiveStorage extends SensitiveStorage {
  /// 创建进程内敏感存储。
  const VolatileSensitiveStorage({Map<String, String>? values})
    : _values = values;

  final Map<String, String>? _values;

  static final Map<String, String> _sharedValues = <String, String>{};

  Map<String, String> get _store => _values ?? _sharedValues;

  @override
  bool get supportsPersistence => false;

  @override
  Future<String?> readString(String key) async => _store[key];

  @override
  Future<void> writeString(String key, String value) async {
    _store[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _store.remove(key);
  }
}
