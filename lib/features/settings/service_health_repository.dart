import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/network/api_client.dart';
import 'package:sickandflutter/core/network/api_client_factory.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';
import 'package:sickandflutter/shared/models/model_utils.dart';
import 'package:sickandflutter/shared/models/service_health_info.dart';

/// 服务健康检查数据源。
class ServiceHealthRepository {
  /// 创建服务健康检查仓储。
  const ServiceHealthRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// 拉取当前服务健康状态。
  Future<ServiceHealthInfo> fetchHealth() async {
    final response = await _apiClient.getResponse<Map<String, dynamic>>(
      '/api/v1/health',
      dataParser: asStringMap,
    );

    if (!response.isSuccess) {
      throw ApiException(
        message: response.message.trim().isEmpty
            ? '服务健康检查失败。'
            : response.message,
        businessCode: response.code,
      );
    }

    final payload = response.data;
    if (payload == null) {
      throw ApiException(
        message: '健康检查返回成功，但缺少 data 数据体。',
        businessCode: response.code,
      );
    }

    return ServiceHealthInfo.fromJson(payload);
  }
}

/// 设置页中的服务健康检查状态。
final serviceHealthProvider = FutureProvider.autoDispose<ServiceHealthInfo>((
  ref,
) async {
  ref.watch(envConfigProvider);
  final settings = await ref.watch(settingsControllerProvider.future);
  final apiClientFactory = ref.watch(apiClientFactoryProvider);
  final repository = ServiceHealthRepository(
    apiClient: apiClientFactory.create(settings: settings),
  );
  return repository.fetchHealth();
});
