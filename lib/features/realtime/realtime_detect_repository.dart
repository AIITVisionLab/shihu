import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/network/api_client_factory.dart';
import 'package:sickandflutter/features/realtime/mock_realtime_detect_repository.dart';
import 'package:sickandflutter/features/realtime/real_realtime_detect_repository.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/app_settings.dart';
import 'package:sickandflutter/shared/models/detect_response.dart';

/// 实时识别仓储入口。
final realtimeDetectRepositoryProvider = Provider<RealtimeDetectRepository>((
  ref,
) {
  final envConfig = ref.watch(envConfigProvider);
  final useMock =
      envConfig.flavor != BuildFlavor.production ||
      const bool.fromEnvironment(
        'USE_MOCK_REALTIME_CHAIN',
        defaultValue: false,
      );

  if (useMock) {
    return const MockRealtimeDetectRepository();
  }

  final settings = _resolveSettings(ref, envConfig);
  final apiClientFactory = ref.watch(apiClientFactoryProvider);
  return RealRealtimeDetectRepository(
    apiClient: apiClientFactory.create(settings: settings),
  );
});

AppSettings _resolveSettings(Ref ref, EnvConfig envConfig) {
  final settingsState = ref.watch(settingsControllerProvider);
  return settingsState.asData?.value ??
      AppSettings.defaults(
        buildFlavor: envConfig.flavor,
        baseUrl: envConfig.baseUrl,
        enableLog: envConfig.enableLog,
      );
}

/// 单次实时识别请求所需的帧上下文。
class RealtimeFrameRequest {
  /// 创建实时识别帧请求。
  const RealtimeFrameRequest({
    required this.sessionId,
    required this.frameIndex,
    required this.capturedAt,
    this.frameFile,
  });

  /// 当前会话 ID。
  final String sessionId;

  /// 当前帧序号。
  final int frameIndex;

  /// 当前帧采集时间。
  final DateTime capturedAt;

  /// 当前帧图片文件。
  final XFile? frameFile;
}

/// 实时识别服务统一入口。
abstract class RealtimeDetectRepository {
  /// 当前仓储是否支持无摄像头的测试帧链路。
  bool get supportsTestFeed;

  /// 根据当前帧上下文执行一次实时识别。
  Future<DetectResponse> detectFrame({required RealtimeFrameRequest request});
}
