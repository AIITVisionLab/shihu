import 'package:sickandflutter/core/network/api_client.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/shared/models/json_value_parsers.dart';
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
      final responseText = raw.trim();
      final normalized = responseText.toLowerCase();
      if (normalized == 'ok') {
        return ServiceHealthInfo(
          status: 'up',
          responseText: responseText,
          checkedAt: DateTime.now().toIso8601String(),
        );
      }
      throw ApiException(message: '健康检查返回非预期字符串：$raw');
    }

    if (raw is Map) {
      final payload = asStringMap(raw);
      if (payload != null) {
        return ServiceHealthInfo(
          status: asString(payload['status'], fallback: 'unknown'),
          responseText:
              parseNullableStringValue(payload['responseText']) ??
              parseNullableStringValue(payload['message']) ??
              payload.toString(),
          checkedAt:
              parseNullableStringValue(payload['checkedAt']) ??
              DateTime.now().toIso8601String(),
        );
      }
    }

    throw ApiException(message: '健康检查返回了无法识别的数据格式。');
  }
}
