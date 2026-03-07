import 'dart:io';

import 'package:flutter/material.dart';

/// 在本地文件平台通过文件路径渲染图片。
Widget buildAdaptiveImage(
  BuildContext context,
  String path, {
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
  WidgetBuilder? errorBuilder,
}) {
  return Image.file(
    File(path),
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
