import 'package:json_annotation/json_annotation.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/json_value_parsers.dart';

part 'history_item.g.dart';

/// 历史记录列表展示模型。
@JsonSerializable()
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
  factory HistoryItem.fromJson(Map<String, dynamic> json) =>
      _$HistoryItemFromJson(json);

  /// 历史记录 ID。
  @JsonKey(fromJson: parseStringValue)
  final String historyId;

  /// 识别任务 ID。
  @JsonKey(fromJson: parseStringValue)
  final String detectId;

  /// 缩略图地址或本地路径。
  @JsonKey(fromJson: parseNullableStringValue, toJson: _nullableStringToJson)
  final String? coverUrl;

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

  /// 严重程度。
  @JsonKey(fromJson: _severityLevelFromJson, toJson: _severityLevelToJson)
  final SeverityLevel severityLevel;

  /// 置信度。
  @JsonKey(fromJson: parseDoubleValue)
  final double confidence;

  /// 采集时间。
  @JsonKey(fromJson: parseStringValue)
  final String capturedAt;

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => _$HistoryItemToJson(this);
}

String? _nullableStringToJson(String? value) => value;

DetectionCategory _detectionCategoryFromJson(Object? value) {
  return detectionCategoryFromValue(parseNullableStringValue(value));
}

String _detectionCategoryToJson(DetectionCategory value) => value.value;

SeverityLevel _severityLevelFromJson(Object? value) {
  return severityLevelFromValue(parseNullableStringValue(value));
}

String _severityLevelToJson(SeverityLevel value) => value.value;
