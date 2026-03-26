import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/core/storage/local_storage.dart';
import 'package:sickandflutter/core/utils/platform_utils.dart';
import 'package:sickandflutter/features/service_config/domain/service_endpoint_resolver.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/app_settings.dart';

/// 暴露当前运行平台的应用版本信息。
final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  if (currentPlatformType() == PlatformType.ohos) {
    return PackageInfo(
      appName: AppConstants.appName,
      packageName: AppConstants.defaultPackageName,
      version: AppConstants.appVersion,
      buildNumber: AppConstants.appBuildNumber,
    );
  }

  return PackageInfo.fromPlatform();
});

/// 设置页状态入口。
final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, AppSettings>(
      SettingsController.new,
    );

/// 当前仓库运行时实际生效的应用设置。
///
/// 当异步设置尚未读回时，先回退到当前环境默认值，避免各业务层重复写兜底逻辑。
final effectiveAppSettingsProvider = Provider<AppSettings>((ref) {
  final envConfig = ref.watch(envConfigProvider);
  final settingsState = ref.watch(settingsControllerProvider);
  return settingsState.asData?.value ??
      AppSettings.defaults(
        buildFlavor: envConfig.flavor,
        baseUrl: envConfig.baseUrl,
        enableLog: envConfig.enableLog,
      );
});

/// 管理本地设置的加载、更新和恢复默认值。
class SettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final envConfig = ref.read(envConfigProvider);
    final storage = await ref.watch(localStorageProvider.future);
    final storedJson = storage.readJson(AppConstants.settingsStorageKey);

    if (storedJson != null) {
      final storedSettings = AppSettings.fromJson(<String, dynamic>{
        ...storedJson,
        'buildFlavor': envConfig.flavor.value,
      });
      final migratedSettings = _migrateLegacySettings(
        storedSettings,
        envConfig: envConfig,
      );
      if (migratedSettings.baseUrl != storedSettings.baseUrl) {
        await storage.writeJson(
          AppConstants.settingsStorageKey,
          migratedSettings.toJson(),
        );
      }
      return migratedSettings;
    }

    return AppSettings.defaults(
      buildFlavor: envConfig.flavor,
      baseUrl: envConfig.baseUrl,
      enableLog: envConfig.enableLog,
    );
  }

  /// 更新服务基础地址并立即持久化。
  Future<void> updateBaseUrl(String baseUrl) async {
    final currentSettings = state.value ?? await future;
    final updatedSettings = currentSettings.copyWith(
      baseUrl: _normalizeBaseUrlOrThrow(baseUrl, fieldLabel: '设备服务地址'),
    );
    await _save(updatedSettings);
  }

  /// 按当前环境恢复默认设置。
  Future<void> reset() async {
    final envConfig = ref.read(envConfigProvider);
    final defaults = AppSettings.defaults(
      buildFlavor: envConfig.flavor,
      baseUrl: envConfig.baseUrl,
      enableLog: envConfig.enableLog,
    );
    await _save(defaults);
  }

  Future<void> _save(AppSettings settings) async {
    final storage = await ref.read(localStorageProvider.future);
    await storage.writeJson(AppConstants.settingsStorageKey, settings.toJson());
    state = AsyncData(settings);
  }

  String _normalizeBaseUrlOrThrow(
    String rawValue, {
    required String fieldLabel,
  }) {
    final normalized = ServiceEndpointResolver.normalizeBaseUrl(rawValue);
    if (normalized == null) {
      throw FormatException('$fieldLabel格式不正确，请输入 http://host:port 这类完整地址。');
    }
    return normalized;
  }

  AppSettings _migrateLegacySettings(
    AppSettings settings, {
    required EnvConfig envConfig,
  }) {
    final migratedBaseUrl = ServiceEndpointResolver.migrateLegacyBaseUrl(
      storedBaseUrl: settings.baseUrl,
      envBaseUrl: envConfig.baseUrl,
    );
    if (migratedBaseUrl == settings.baseUrl) {
      return settings;
    }
    return settings.copyWith(baseUrl: migratedBaseUrl);
  }
}
