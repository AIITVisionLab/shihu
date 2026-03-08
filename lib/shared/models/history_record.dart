import 'package:json_annotation/json_annotation.dart';
import 'package:sickandflutter/shared/models/detect_response.dart';
import 'package:sickandflutter/shared/models/history_item.dart';
import 'package:sickandflutter/shared/models/json_value_parsers.dart';

part 'history_record.g.dart';

/// 历史记录详情模型，组合列表项与完整识别结果。
@JsonSerializable(explicitToJson: true)
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
  factory HistoryRecord.fromJson(Map<String, dynamic> json) =>
      _$HistoryRecordFromJson(json);

  /// 列表展示信息。
  @JsonKey(fromJson: _historyItemFromJson, toJson: _historyItemToJson)
  final HistoryItem item;

  /// 完整识别结果。
  @JsonKey(fromJson: _detectResponseFromJson, toJson: _detectResponseToJson)
  final DetectResponse response;

  /// 保存时间。
  @JsonKey(fromJson: parseStringValue)
  final String savedAt;

  /// 源图片本地路径。
  @JsonKey(fromJson: parseNullableStringValue, toJson: _nullableStringToJson)
  final String? sourceImagePath;

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => _$HistoryRecordToJson(this);
}

HistoryItem _historyItemFromJson(Object? value) {
  return HistoryItem.fromJson(parseStringMapValue(value));
}

Map<String, dynamic> _historyItemToJson(HistoryItem value) => value.toJson();

DetectResponse _detectResponseFromJson(Object? value) {
  return DetectResponse.fromJson(parseStringMapValue(value));
}

Map<String, dynamic> _detectResponseToJson(DetectResponse value) =>
    value.toJson();

String? _nullableStringToJson(String? value) => value;
