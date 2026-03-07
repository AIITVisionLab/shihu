import 'package:sickandflutter/shared/models/detect_response.dart';
import 'package:sickandflutter/shared/models/history_item.dart';
import 'package:sickandflutter/shared/models/model_utils.dart';

/// 历史记录详情模型，组合列表项与完整识别结果。
class HistoryRecord {
  /// 创建历史记录详情对象。
  const HistoryRecord({
    required this.item,
    required this.response,
    required this.savedAt,
    this.sourceImagePath,
  });

  /// 根据一次识别结果构造历史记录。
  factory HistoryRecord.fromDetectResponse({
    required DetectResponse response,
    required String? sourceImagePath,
  }) {
    final now = DateTime.now();
    final historyId = 'his_${now.microsecondsSinceEpoch}';

    return HistoryRecord(
      item: HistoryItem(
        historyId: historyId,
        detectId: response.detectId,
        coverUrl: sourceImagePath ?? response.imageInfo?.annotatedUrl,
        primaryLabelCode: response.summary.primaryLabelCode,
        primaryLabelName: response.summary.primaryLabelName,
        category: response.summary.category,
        severityLevel: response.summary.severityLevel,
        confidence: response.summary.confidence,
        capturedAt: response.capturedAt,
      ),
      response: response,
      sourceImagePath: sourceImagePath,
      savedAt: now.toIso8601String(),
    );
  }

  /// 从 JSON 构建历史记录详情对象。
  factory HistoryRecord.fromJson(Map<String, dynamic> json) {
    return HistoryRecord(
      item: HistoryItem.fromJson(
        asStringMap(json['item']) ?? const <String, dynamic>{},
      ),
      response: DetectResponse.fromJson(
        asStringMap(json['response']) ?? const <String, dynamic>{},
      ),
      savedAt: json['savedAt'].toString(),
      sourceImagePath: asNullableString(json['sourceImagePath']),
    );
  }

  /// 列表展示信息。
  final HistoryItem item;

  /// 完整识别结果。
  final DetectResponse response;

  /// 保存时间。
  final String savedAt;

  /// 源图片本地路径。
  final String? sourceImagePath;

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'item': item.toJson(),
      'response': response.toJson(),
      'savedAt': savedAt,
      'sourceImagePath': sourceImagePath,
    };
  }
}
