import 'package:json_annotation/json_annotation.dart';
import 'package:sickandflutter/shared/models/advice_info.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/detect_summary.dart';
import 'package:sickandflutter/shared/models/detection_item.dart';
import 'package:sickandflutter/shared/models/image_info.dart';
import 'package:sickandflutter/shared/models/json_value_parsers.dart';
import 'package:sickandflutter/shared/models/model_info.dart';

part 'detect_response.g.dart';

/// 单图识别和实时识别共用的标准结果模型。
@JsonSerializable(explicitToJson: true)
class DetectResponse {
  /// 创建识别结果对象。
  const DetectResponse({
    required this.detectId,
    required this.sourceType,
    required this.capturedAt,
    required this.summary,
    required this.detections,
    this.imageInfo,
    this.advice,
    this.modelInfo,
  });

  /// 从 JSON 构建识别结果对象。
  factory DetectResponse.fromJson(Map<String, dynamic> json) =>
      _$DetectResponseFromJson(json);

  /// 识别任务 ID。
  @JsonKey(fromJson: parseStringValue)
  final String detectId;

  /// 结果来源类型。
  @JsonKey(fromJson: _sourceTypeFromJson, toJson: _sourceTypeToJson)
  final SourceType sourceType;

  /// 采集时间。
  @JsonKey(fromJson: parseStringValue)
  final String capturedAt;

  /// 识别摘要。
  @JsonKey(fromJson: _detectSummaryFromJson, toJson: _detectSummaryToJson)
  final DetectSummary summary;

  /// 图像信息。
  @JsonKey(fromJson: _imageInfoFromJson, toJson: _imageInfoToJson)
  final ImageInfo? imageInfo;

  /// 检测框列表。
  @JsonKey(
    fromJson: _detectionItemListFromJson,
    toJson: _detectionItemListToJson,
  )
  final List<DetectionItem> detections;

  /// 防治建议。
  @JsonKey(fromJson: _adviceInfoFromJson, toJson: _adviceInfoToJson)
  final AdviceInfo? advice;

  /// 模型推理信息。
  @JsonKey(fromJson: _modelInfoFromJson, toJson: _modelInfoToJson)
  final ModelInfo? modelInfo;

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => _$DetectResponseToJson(this);
}

SourceType _sourceTypeFromJson(Object? value) {
  return sourceTypeFromValue(parseNullableStringValue(value));
}

String _sourceTypeToJson(SourceType value) => value.value;

DetectSummary _detectSummaryFromJson(Object? value) {
  return DetectSummary.fromJson(parseStringMapValue(value));
}

Map<String, dynamic> _detectSummaryToJson(DetectSummary value) =>
    value.toJson();

ImageInfo? _imageInfoFromJson(Object? value) {
  if (value == null) {
    return null;
  }

  return ImageInfo.fromJson(parseStringMapValue(value));
}

Map<String, dynamic>? _imageInfoToJson(ImageInfo? value) => value?.toJson();

List<DetectionItem> _detectionItemListFromJson(Object? value) {
  return parseStringMapListValue(
    value,
  ).map(DetectionItem.fromJson).toList(growable: false);
}

List<Map<String, dynamic>> _detectionItemListToJson(List<DetectionItem> value) {
  return value.map((item) => item.toJson()).toList(growable: false);
}

AdviceInfo? _adviceInfoFromJson(Object? value) {
  if (value == null) {
    return null;
  }

  return AdviceInfo.fromJson(parseStringMapValue(value));
}

Map<String, dynamic>? _adviceInfoToJson(AdviceInfo? value) => value?.toJson();

ModelInfo? _modelInfoFromJson(Object? value) {
  if (value == null) {
    return null;
  }

  return ModelInfo.fromJson(parseStringMapValue(value));
}

Map<String, dynamic>? _modelInfoToJson(ModelInfo? value) => value?.toJson();
