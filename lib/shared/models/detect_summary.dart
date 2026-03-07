import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/model_utils.dart';

/// 识别结果摘要模型。
class DetectSummary {
  /// 创建识别摘要对象。
  const DetectSummary({
    required this.primaryLabelCode,
    required this.primaryLabelName,
    required this.category,
    required this.confidence,
    required this.severityLevel,
    required this.healthStatus,
    this.severityScore,
  });

  /// 从 JSON 构建识别摘要对象。
  factory DetectSummary.fromJson(Map<String, dynamic> json) {
    return DetectSummary(
      primaryLabelCode: asString(json['primaryLabelCode']),
      primaryLabelName: asString(json['primaryLabelName']),
      category: detectionCategoryFromValue(asString(json['category'])),
      confidence: asDouble(json['confidence']),
      severityLevel: severityLevelFromValue(asString(json['severityLevel'])),
      healthStatus: healthStatusFromValue(asString(json['healthStatus'])),
      severityScore: json['severityScore'] == null
          ? null
          : asDouble(json['severityScore']),
    );
  }

  /// 主标签编码。
  final String primaryLabelCode;

  /// 主标签名称。
  final String primaryLabelName;

  /// 识别类别。
  final DetectionCategory category;

  /// 置信度。
  final double confidence;

  /// 严重程度。
  final SeverityLevel severityLevel;

  /// 严重度分数。
  final double? severityScore;

  /// 健康状态。
  final HealthStatus healthStatus;

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'primaryLabelCode': primaryLabelCode,
      'primaryLabelName': primaryLabelName,
      'category': category.value,
      'confidence': confidence,
      'severityLevel': severityLevel.value,
      'severityScore': severityScore,
      'healthStatus': healthStatus.value,
    };
  }
}
