import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/network/api_client.dart';
import 'package:sickandflutter/features/detect/mock_detect_repository.dart';
import 'package:sickandflutter/features/detect/real_detect_repository.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/app_settings.dart';
import 'package:sickandflutter/shared/models/detect_response.dart';

/// 单图识别仓储入口。
final detectRepositoryProvider = Provider<DetectRepository>((ref) {
  final envConfig = ref.watch(envConfigProvider);
  final useMock =
      envConfig.flavor != BuildFlavor.production &&
      const bool.fromEnvironment('USE_MOCK_DETECT', defaultValue: false);

  if (useMock) {
    return const MockDetectRepository();
  }

  final settings = _resolveSettings(ref, envConfig);
  return RealDetectRepository(
    apiClient: ApiClient(settings: settings, envConfig: envConfig),
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

/// 单图识别服务统一入口。
///
/// 开发和测试环境可以切换到受控替身实现，
/// 正式环境应固定到真实接口实现。
abstract class DetectRepository {
  /// 根据图片文件执行一次识别并返回标准结果。
  Future<DetectResponse> detectImage({required XFile imageFile});
}
