import 'package:flutter/material.dart';

/// 项目内统一卡片容器，约束圆角、留白和标题区样式。
class CommonCard extends StatelessWidget {
  /// 创建通用卡片。
  const CommonCard({
    required this.child,
    this.title,
    this.subtitle,
    this.padding = const EdgeInsets.all(20),
    super.key,
  });

  /// 卡片主体内容。
  final Widget child;

  /// 可选标题。
  final String? title;

  /// 可选副标题。
  final String? subtitle;

  /// 卡片内边距。
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (title != null) ...<Widget>[
              Text(
                title!,
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: 6),
                Text(subtitle!, style: textTheme.bodyMedium),
              ],
              const SizedBox(height: 16),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
