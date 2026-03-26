import 'package:sickandflutter/core/network/api_client.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/features/ai/domain/ai_detection_summary.dart';
import 'package:sickandflutter/shared/models/model_utils.dart';

/// AI 检测查询仓储。
class AiDetectionRepository {
  /// 创建 AI 检测查询仓储。
  const AiDetectionRepository({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// 拉取最新一条 AI 检测结果。
  Future<AiDetectionSummary?> fetchLatest() async {
    final payload = await _apiClient.getJson('/api/edge/ai-detections/latest');
    final data = _resolveEnvelopeData(payload, fallbackMessage: 'AI 检测结果获取失败。');
    final json = asStringMap(data);
    if (json == null) {
      return null;
    }
    return AiDetectionSummary.fromJson(json);
  }

  /// 拉取最近几条 AI 检测历史。
  Future<List<AiDetectionSummary>> fetchHistory({int limit = 6}) async {
    final payload = await _apiClient.getJson(
      '/api/edge/ai-detections/history',
      queryParameters: <String, dynamic>{'limit': limit},
    );
    final data = _resolveEnvelopeData(payload, fallbackMessage: 'AI 检测历史获取失败。');
    if (data is! List) {
      return const <AiDetectionSummary>[];
    }

    return data
        .map((item) => asStringMap(item))
        .whereType<Map<String, dynamic>>()
        .map(AiDetectionSummary.fromJson)
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
