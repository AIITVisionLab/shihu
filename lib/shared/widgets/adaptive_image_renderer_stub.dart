import 'package:flutter/material.dart';

/// 在不支持的平台上返回兜底图片组件。
Widget buildAdaptiveImage(
  BuildContext context,
  String path, {
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
  WidgetBuilder? errorBuilder,
}) {
  return _FallbackImage(
    width: width,
    height: height,
    errorBuilder: errorBuilder,
  );
}

class _FallbackImage extends StatelessWidget {
  const _FallbackImage({
    required this.width,
    required this.height,
    required this.errorBuilder,
  });

  final double? width;
  final double? height;
  final WidgetBuilder? errorBuilder;

  @override
  Widget build(BuildContext context) {
    if (errorBuilder != null) {
      return errorBuilder!(context);
    }

    return SizedBox(
      width: width,
      height: height,
      child: const ColoredBox(color: Color(0xFFE8EFE6)),
    );
  }
}
