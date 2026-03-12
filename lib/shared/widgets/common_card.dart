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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact =
            constraints.maxWidth > 0 && constraints.maxWidth < 560;
        final effectivePadding = padding == const EdgeInsets.all(20)
            ? EdgeInsets.all(isCompact ? 16 : 20)
            : padding;

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: colorScheme.surfaceContainerLow.withValues(alpha: 0.98),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.92),
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x38000000),
                blurRadius: 22,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: <Widget>[
              Positioned(
                left: 18,
                right: 18,
                top: 0,
                child: IgnorePointer(
                  child: Container(
                    height: 1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: <Color>[
                          colorScheme.primary.withValues(alpha: 0.0),
                          colorScheme.primary.withValues(alpha: 0.62),
                          colorScheme.tertiary.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: effectivePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    if (title != null) ...<Widget>[
                      Text(
                        title!,
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (subtitle != null) ...<Widget>[
                        const SizedBox(height: 6),
                        Text(
                          subtitle!,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.54,
                          ),
                        ),
                      ],
                      SizedBox(height: subtitle != null ? 16 : 14),
                    ],
                    child,
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
