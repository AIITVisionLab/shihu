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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.96),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.42),
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x0C172019),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (title != null) ...<Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          title!,
                          style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      if (subtitle != null) ...<Widget>[
                        const SizedBox(height: 14),
                        Text(
                          subtitle!,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.58,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
