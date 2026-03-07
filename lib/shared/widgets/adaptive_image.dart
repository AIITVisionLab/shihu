import 'package:flutter/widgets.dart';
import 'package:sickandflutter/shared/widgets/adaptive_image_renderer.dart';

/// 按平台选择合适图片渲染实现的轻量封装。
class AdaptiveImage extends StatelessWidget {
  /// 根据路径创建跨平台图片组件。
  const AdaptiveImage(
    this.path, {
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.errorBuilder,
    super.key,
  });

  /// 图片路径或网络地址。
  final String path;

  /// 图片填充方式。
  final BoxFit fit;

  /// 组件宽度。
  final double? width;

  /// 组件高度。
  final double? height;

  /// 图片加载失败时的兜底构建器。
  final WidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    return buildAdaptiveImage(
      context,
      path,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: errorBuilder,
    );
  }
}
