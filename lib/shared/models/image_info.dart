import 'package:json_annotation/json_annotation.dart';
import 'package:sickandflutter/shared/models/json_value_parsers.dart';

part 'image_info.g.dart';

/// 图像尺寸和结果图地址信息模型。
@JsonSerializable()
class ImageInfo {
  /// 创建图像信息对象。
  const ImageInfo({
    required this.width,
    required this.height,
    this.originalUrl,
    this.annotatedUrl,
  });

  /// 从 JSON 构建图像信息对象。
  factory ImageInfo.fromJson(Map<String, dynamic> json) =>
      _$ImageInfoFromJson(json);

  /// 图片宽度。
  @JsonKey(fromJson: parseIntValue)
  final int width;

  /// 图片高度。
  @JsonKey(fromJson: parseIntValue)
  final int height;

  /// 原图地址。
  @JsonKey(fromJson: parseNullableStringValue, toJson: _nullableStringToJson)
  final String? originalUrl;

  /// 标注结果图地址。
  @JsonKey(fromJson: parseNullableStringValue, toJson: _nullableStringToJson)
  final String? annotatedUrl;

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() => _$ImageInfoToJson(this);
}

String? _nullableStringToJson(String? value) => value;
