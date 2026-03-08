import 'package:json_annotation/json_annotation.dart';
import 'package:sickandflutter/shared/models/json_value_parsers.dart';

part 'model_info.g.dart';

/// 模型推理信息模型。
@JsonSerializable()
class ModelInfo {
  /// 创建模型信息对象。
  const ModelInfo({
    required this.modelName,
    required this.modelVersion,
    required this.inferenceMs,
  });

  /// 从 JSON 构建模型信息对象。
  factory ModelInfo.fromJson(Map<String, dynamic> json) =>
      _$ModelInfoFromJson(json);

  /// 模型名称。
  @JsonKey(fromJson: parseStringValue)
  final String modelName;

  /// 模型版本。
  @JsonKey(fromJson: parseStringValue)
  final String modelVersion;

  /// 推理耗时，单位毫秒。
  @JsonKey(fromJson: parseIntValue)
  final int inferenceMs;

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => _$ModelInfoToJson(this);
}
