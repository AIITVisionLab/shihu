import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/core/storage/local_storage.dart';
import 'package:sickandflutter/core/utils/platform_utils.dart';
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

/// 管理本地设置的加载、更新和恢复默认值。
class SettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final envConfig = ref.read(envConfigProvider);
    final storage = await ref.watch(localStorageProvider.future);
    final storedJson = storage.readJson(AppConstants.settingsStorageKey);

    if (storedJson != null) {
      return AppSettings.fromJson(<String, dynamic>{
        ...storedJson,
        'buildFlavor': envConfig.flavor.value,
      });
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
    final updatedSettings = currentSettings.copyWith(baseUrl: baseUrl.trim());
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
}
