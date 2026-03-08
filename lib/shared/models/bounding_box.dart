import 'package:json_annotation/json_annotation.dart';
import 'package:sickandflutter/shared/models/json_value_parsers.dart';

part 'bounding_box.g.dart';

/// 归一化检测框坐标模型。
@JsonSerializable()
class BoundingBox {
  /// 创建归一化检测框。
  const BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  /// 从 JSON 构建检测框对象。
  factory BoundingBox.fromJson(Map<String, dynamic> json) =>
      _$BoundingBoxFromJson(json);

  /// 左上角横向比例值。
  @JsonKey(fromJson: parseDoubleValue)
  final double x;

  /// 左上角纵向比例值。
  @JsonKey(fromJson: parseDoubleValue)
  final double y;

  /// 宽度比例值。
  @JsonKey(fromJson: parseDoubleValue)
  final double width;

  /// 高度比例值。
  @JsonKey(fromJson: parseDoubleValue)
  final double height;

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => _$BoundingBoxToJson(this);
}
