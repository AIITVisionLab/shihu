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
    this.videoGatewayUrl = AppConstants.defaultVideoGatewayUrl,
    this.videoDefaultStreamId = AppConstants.defaultVideoStreamId,
    this.videoDisplayName = AppConstants.defaultVideoDisplayName,
    this.videoPreferredMode = AppConstants.defaultVideoPreferredMode,
    this.videoFallbackMode = AppConstants.defaultVideoFallbackMode,
    this.videoWebrtcPort = AppConstants.defaultVideoWebrtcPort,
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
      videoGatewayUrl: const String.fromEnvironment(
        'VIDEO_GATEWAY_URL',
        defaultValue: AppConstants.defaultVideoGatewayUrl,
      ),
      videoDefaultStreamId: const String.fromEnvironment(
        'VIDEO_DEFAULT_STREAM_ID',
        defaultValue: AppConstants.defaultVideoStreamId,
      ),
      videoDisplayName: const String.fromEnvironment(
        'VIDEO_DISPLAY_NAME',
        defaultValue: AppConstants.defaultVideoDisplayName,
      ),
      videoPreferredMode: const String.fromEnvironment(
        'VIDEO_PREFERRED_MODE',
        defaultValue: AppConstants.defaultVideoPreferredMode,
      ),
      videoFallbackMode: const String.fromEnvironment(
        'VIDEO_FALLBACK_MODE',
        defaultValue: AppConstants.defaultVideoFallbackMode,
      ),
      videoWebrtcPort: int.fromEnvironment(
        'VIDEO_WEBRTC_PORT',
        defaultValue: AppConstants.defaultVideoWebrtcPort,
      ),
    );
  }

  /// 当前构建环境。
  final BuildFlavor flavor;

  /// 默认服务基础地址。
  final String baseUrl;

  /// 是否开启日志输出。
  final bool enableLog;

  /// 当前视频网关地址。
  final String videoGatewayUrl;

  /// 当前默认视频流标识。
  final String videoDefaultStreamId;

  /// 当前默认视频流展示名称。
  final String videoDisplayName;

  /// 当前默认优先播放模式。
  final String videoPreferredMode;

  /// 当前默认回退播放模式。
  final String videoFallbackMode;

  /// 当前默认 WebRTC 端口。
  final int videoWebrtcPort;

  /// 仅开发和测试环境允许暴露高风险配置入口。
  bool get allowRiskySettings => !flavor.isProduction;
}
