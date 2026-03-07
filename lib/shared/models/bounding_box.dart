import 'package:sickandflutter/shared/models/model_utils.dart';

/// 归一化检测框坐标模型。
class BoundingBox {
  /// 创建归一化检测框。
  const BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  /// 从 JSON 构建检测框对象。
  factory BoundingBox.fromJson(Map<String, dynamic> json) {
    return BoundingBox(
      x: asDouble(json['x']),
      y: asDouble(json['y']),
      width: asDouble(json['width']),
      height: asDouble(json['height']),
    );
  }

  /// 左上角横向比例值。
  final double x;

  /// 左上角纵向比例值。
  final double y;

  /// 宽度比例值。
  final double width;

  /// 高度比例值。
  final double height;

  /// 序列化为 JSON。
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'x': x, 'y': y, 'width': width, 'height': height};
  }
}
