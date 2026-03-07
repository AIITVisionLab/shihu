import 'package:sickandflutter/shared/models/model_utils.dart';

/// 图像尺寸和结果图地址信息模型。
class ImageInfo {
  /// 创建图像信息对象。
  const ImageInfo({
    required this.width,
    required this.height,
    this.originalUrl,
    this.annotatedUrl,
  });

  /// 从 JSON 构建图像信息对象。
  factory ImageInfo.fromJson(Map<String, dynamic> json) {
    return ImageInfo(
      width: asInt(json['width']),
      height: asInt(json['height']),
      originalUrl: asNullableString(json['originalUrl']),
      annotatedUrl: asNullableString(json['annotatedUrl']),
    );
  }

  /// 图片宽度。
  final int width;

  /// 图片高度。
  final int height;

  /// 原图地址。
  final String? originalUrl;

  /// 标注结果图地址。
  final String? annotatedUrl;

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'width': width,
      'height': height,
      'originalUrl': originalUrl,
      'annotatedUrl': annotatedUrl,
    };
  }
}
