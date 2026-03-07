import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/model_utils.dart';

/// 历史记录列表展示模型。
class HistoryItem {
  /// 创建历史记录列表项。
  const HistoryItem({
    required this.historyId,
    required this.detectId,
    required this.primaryLabelCode,
    required this.primaryLabelName,
    required this.category,
    required this.severityLevel,
    required this.confidence,
    required this.capturedAt,
    this.coverUrl,
  });

  /// 从 JSON 构建历史记录列表项。
  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      historyId: asString(json['historyId']),
      detectId: asString(json['detectId']),
      coverUrl: asNullableString(json['coverUrl']),
      primaryLabelCode: asString(json['primaryLabelCode']),
      primaryLabelName: asString(json['primaryLabelName']),
      category: detectionCategoryFromValue(asString(json['category'])),
      severityLevel: severityLevelFromValue(asString(json['severityLevel'])),
      confidence: asDouble(json['confidence']),
      capturedAt: asString(json['capturedAt']),
    );
  }

  /// 历史记录 ID。
  final String historyId;

  /// 识别任务 ID。
  final String detectId;

  /// 缩略图地址或本地路径。
  final String? coverUrl;

  /// 主标签编码。
  final String primaryLabelCode;

  /// 主标签名称。
  final String primaryLabelName;

  /// 识别类别。
  final DetectionCategory category;

  /// 严重程度。
  final SeverityLevel severityLevel;

  /// 置信度。
  final double confidence;

  /// 采集时间。
  final String capturedAt;

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'historyId': historyId,
      'detectId': detectId,
      'coverUrl': coverUrl,
      'primaryLabelCode': primaryLabelCode,
      'primaryLabelName': primaryLabelName,
      'category': category.value,
      'severityLevel': severityLevel.value,
      'confidence': confidence,
      'capturedAt': capturedAt,
    };
  }
}
