import 'package:json_annotation/json_annotation.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/json_value_parsers.dart';

part 'detect_summary.g.dart';

/// 识别结果摘要模型。
@JsonSerializable()
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
  factory DetectSummary.fromJson(Map<String, dynamic> json) =>
      _$DetectSummaryFromJson(json);

  /// 主标签编码。
  @JsonKey(fromJson: parseStringValue)
  final String primaryLabelCode;

  /// 主标签名称。
  @JsonKey(fromJson: parseStringValue)
  final String primaryLabelName;

  /// 识别类别。
  @JsonKey(
    fromJson: _detectionCategoryFromJson,
    toJson: _detectionCategoryToJson,
  )
  final DetectionCategory category;

  /// 置信度。
  @JsonKey(fromJson: parseDoubleValue)
  final double confidence;

  /// 严重程度。
  @JsonKey(fromJson: _severityLevelFromJson, toJson: _severityLevelToJson)
  final SeverityLevel severityLevel;

  /// 严重度分数。
  @JsonKey(fromJson: _nullableDoubleFromJson, toJson: _nullableDoubleToJson)
  final double? severityScore;

  /// 健康状态。
  @JsonKey(fromJson: _healthStatusFromJson, toJson: _healthStatusToJson)
  final HealthStatus healthStatus;

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => _$DetectSummaryToJson(this);
}

DetectionCategory _detectionCategoryFromJson(Object? value) {
  return detectionCategoryFromValue(parseNullableStringValue(value));
}

String _detectionCategoryToJson(DetectionCategory value) => value.value;

SeverityLevel _severityLevelFromJson(Object? value) {
  return severityLevelFromValue(parseNullableStringValue(value));
}

String _severityLevelToJson(SeverityLevel value) => value.value;

HealthStatus _healthStatusFromJson(Object? value) {
  return healthStatusFromValue(parseNullableStringValue(value));
}

String _healthStatusToJson(HealthStatus value) => value.value;

double? _nullableDoubleFromJson(Object? value) {
  if (value == null) {
    return null;
  }

  return parseDoubleValue(value);
}

double? _nullableDoubleToJson(double? value) => value;
