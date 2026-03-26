import 'package:sickandflutter/core/network/api_client.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/features/platform_logs/domain/platform_log_entry.dart';
import 'package:sickandflutter/shared/models/model_utils.dart';

/// 平台日志查询仓储。
class PlatformLogRepository {
  /// 创建平台日志查询仓储。
  const PlatformLogRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// 拉取平台日志摘要。
  Future<PlatformLogSummary> fetchSummary() async {
    final payload = await _apiClient.getJson('/api/logs/summary');
    final data = _resolveEnvelopeData(payload, fallbackMessage: '平台日志摘要获取失败。');
    final json = asStringMap(data);
    if (json == null) {
      throw const ApiException(message: '平台日志摘要返回为空。');
    }
    return PlatformLogSummary.fromJson(json);
  }

  /// 拉取最近平台日志。
  Future<List<PlatformLogEntry>> fetchRecent({
    String? type,
    String? keyword,
    int limit = 6,
  }) async {
    final payload = await _apiClient.getJson(
      '/api/logs',
      queryParameters: <String, dynamic>{
        if (type != null && type.trim().isNotEmpty) 'type': type.trim(),
        if (keyword != null && keyword.trim().isNotEmpty)
          'keyword': keyword.trim(),
        'limit': limit,
      },
    );
    final data = _resolveEnvelopeData(payload, fallbackMessage: '平台日志列表获取失败。');
    if (data is! List) {
      return const <PlatformLogEntry>[];
    }

    return data
        .map((item) => asStringMap(item))
        .whereType<Map<String, dynamic>>()
        .map(PlatformLogEntry.fromJson)
        .toList(growable: false);
  }

  Object? _resolveEnvelopeData(
    Map<String, dynamic> payload, {
    required String fallbackMessage,
  }) {
    final code = asInt(payload['code'], fallback: 0);
    if (code == 0 || code == 200) {
      return payload['data'];
    }

    final message = asString(payload['msg']).trim();
    throw ApiException(
      message: message.isEmpty ? fallbackMessage : message,
      statusCode: code,
    );
  }
}
