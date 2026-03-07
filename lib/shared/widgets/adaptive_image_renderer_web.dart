import 'package:flutter/material.dart';

/// 在网页平台通过网络地址渲染图片。
Widget buildAdaptiveImage(
  BuildContext context,
  String path, {
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
  WidgetBuilder? errorBuilder,
}) {
  return Image.network(
    path,
    fit: fit,
    width: width,
    height: height,
    errorBuilder: (context, error, stackTrace) {
      return errorBuilder?.call(context) ??
          SizedBox(
            width: width,
            height: height,
            child: const ColoredBox(color: Color(0xFFE8EFE6)),
          );
    },
  );
}
