import 'package:json_annotation/json_annotation.dart';
import 'package:sickandflutter/shared/models/json_value_parsers.dart';

part 'advice_info.g.dart';

/// 防治建议信息模型。
@JsonSerializable()
class AdviceInfo {
  /// 创建防治建议对象。
  const AdviceInfo({
    required this.title,
    required this.summary,
    required this.preventionSteps,
  });

  /// 从 JSON 构建防治建议对象。
  factory AdviceInfo.fromJson(Map<String, dynamic> json) =>
      _$AdviceInfoFromJson(json);

  /// 建议标题。
  @JsonKey(fromJson: parseStringValue)
  final String title;

  /// 建议摘要。
  @JsonKey(fromJson: parseStringValue)
  final String summary;

  /// 具体防治步骤。
  @JsonKey(fromJson: parseStringListValue, toJson: stringListToJson)
  final List<String> preventionSteps;

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => _$AdviceInfoToJson(this);
}
