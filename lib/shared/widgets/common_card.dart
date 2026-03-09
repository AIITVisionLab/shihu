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

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Colors.white.withValues(alpha: 0.92),
            colorScheme.surfaceContainerLowest.withValues(alpha: 0.88),
          ],
        ),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.42),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0x120E1C12),
            blurRadius: 36,
            offset: const Offset(0, 18),
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.62),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  title!,
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  subtitle!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 18),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
