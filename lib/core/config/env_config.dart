import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';

/// 从编译期环境变量读取运行环境配置。
final envConfigProvider = Provider<EnvConfig>((ref) {
  return EnvConfig.fromEnvironment();
});

/// 当前构建环境的只读配置。
class EnvConfig {
  /// 创建环境配置对象。
  const EnvConfig({
    required this.flavor,
    required this.baseUrl,
    required this.enableLog,
  });

  /// 根据 `--dart-define` 构建运行环境配置。
  factory EnvConfig.fromEnvironment() {
    final flavor = buildFlavorFromValue(
      const String.fromEnvironment('APP_FLAVOR', defaultValue: 'development'),
    );

    return EnvConfig(
      flavor: flavor,
      baseUrl: const String.fromEnvironment(
        'BASE_URL',
        defaultValue: AppConstants.defaultBaseUrl,
      ),
      enableLog: const bool.fromEnvironment('ENABLE_LOG', defaultValue: true),
    );
  }

  /// 当前构建环境。
  final BuildFlavor flavor;

  /// 默认服务基础地址。
  final String baseUrl;

  /// 是否开启日志输出。
  final bool enableLog;

  /// 仅开发和测试环境允许暴露高风险配置入口。
  bool get allowRiskySettings => !flavor.isProduction;
}
