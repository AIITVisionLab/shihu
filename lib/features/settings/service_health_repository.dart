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
    final raw = await _apiClient.getRaw('/api/health');

    if (raw is String) {
      final normalized = raw.trim().toLowerCase();
      if (normalized == 'ok') {
        return ServiceHealthInfo(
          status: 'up',
          serviceName: '设备运行服务',
          serviceVersion: '标准部署',
          modelStatus: 'ready',
          serverTime: DateTime.now().toIso8601String(),
        );
      }
      throw ApiException(message: '健康检查返回非预期字符串：$raw');
    }

    if (raw is Map<String, dynamic>) {
      if (raw.containsKey('data') && raw['data'] is Map<String, dynamic>) {
        final payload = asStringMap(raw['data']);
        if (payload != null) {
          return ServiceHealthInfo.fromJson(payload);
        }
      }
      return ServiceHealthInfo.fromJson(raw);
    }

    throw ApiException(message: '健康检查返回了无法识别的数据格式。');
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
