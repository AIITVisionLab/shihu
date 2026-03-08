import 'package:json_annotation/json_annotation.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/bounding_box.dart';
import 'package:sickandflutter/shared/models/json_value_parsers.dart';

part 'detection_item.g.dart';

/// 单个检测结果项模型。
@JsonSerializable(explicitToJson: true)
class DetectionItem {
  /// 创建单个检测结果项。
  const DetectionItem({
    required this.detectionId,
    required this.labelCode,
    required this.labelName,
    required this.category,
    required this.confidence,
    required this.severityLevel,
    required this.bbox,
  });

  /// 从 JSON 构建检测结果项。
  factory DetectionItem.fromJson(Map<String, dynamic> json) =>
      _$DetectionItemFromJson(json);

  /// 检测框 ID。
  @JsonKey(fromJson: parseStringValue)
  final String detectionId;

  /// 标签编码。
  @JsonKey(fromJson: parseStringValue)
  final String labelCode;

  /// 标签名称。
  @JsonKey(fromJson: parseStringValue)
  final String labelName;

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

  /// 检测框坐标。
  @JsonKey(fromJson: _boundingBoxFromJson, toJson: _boundingBoxToJson)
  final BoundingBox bbox;

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => _$DetectionItemToJson(this);
}

DetectionCategory _detectionCategoryFromJson(Object? value) {
  return detectionCategoryFromValue(parseNullableStringValue(value));
}

String _detectionCategoryToJson(DetectionCategory value) => value.value;

SeverityLevel _severityLevelFromJson(Object? value) {
  return severityLevelFromValue(parseNullableStringValue(value));
}

String _severityLevelToJson(SeverityLevel value) => value.value;

BoundingBox _boundingBoxFromJson(Object? value) {
  return BoundingBox.fromJson(parseStringMapValue(value));
}

Map<String, dynamic> _boundingBoxToJson(BoundingBox value) => value.toJson();
