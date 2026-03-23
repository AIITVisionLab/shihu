import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/shared/widgets/feature_surface.dart';

/// 项目内统一卡片容器，约束圆角、留白和标题区样式。
class CommonCard extends StatelessWidget {
  /// 创建通用卡片。
  const CommonCard({
    required this.child,
    this.title,
    this.subtitle,
    this.padding = const EdgeInsets.all(20),
    this.accentColor = AppPalette.pineGreen,
    this.headerIcon,
    this.headerTag,
    this.stretchContent = false,
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

  /// 卡片强调色。
  final Color accentColor;

  /// 标题区可选图标。
  final IconData? headerIcon;

  /// 标题区可选标签。
  final String? headerTag;

  /// 是否让主体内容填满标题区以下的剩余高度。
  final bool stretchContent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasHeader = title != null;

    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                AppPalette.blendOnPaper(
                  accentColor,
                  opacity: 0.04,
                  base: colorScheme.surfaceBright,
                ).withValues(alpha: 0.985),
                AppPalette.blendOnPaper(
                  accentColor,
                  opacity: 0.018,
                  base: colorScheme.surfaceContainerLowest,
                ).withValues(alpha: 0.975),
                AppPalette.blendOnPaper(
                  accentColor,
                  opacity: 0.01,
                  base: colorScheme.surfaceContainerLow,
                ).withValues(alpha: 0.94),
              ],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.84),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppPalette.pineShadow.withValues(alpha: 0.045),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(-0.84, -0.92),
                        radius: 1.08,
                        colors: <Color>[
                          accentColor.withValues(alpha: 0.05),
                          accentColor.withValues(alpha: 0.012),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SurfaceHighlightLine(color: accentColor, opacity: 0.24),
              ),
              Positioned(
                top: -44,
                right: -18,
                child: IgnorePointer(
                  child: Container(
                    width: 156,
                    height: 124,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: <Color>[
                          accentColor.withValues(alpha: 0.08),
                          accentColor.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: stretchContent
                      ? MainAxisSize.max
                      : MainAxisSize.min,
                  children: <Widget>[
                    if (hasHeader) ...<Widget>[
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final headerLabel = Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  title!,
                                  style: textTheme.titleLarge?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                if (subtitle != null) ...<Widget>[
                                  const SizedBox(height: 8),
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
                          );

                          final leading = headerIcon == null
                              ? Container(
                                  width: 4,
                                  height: subtitle == null ? 22 : 40,
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.78),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                )
                              : Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: <Color>[
                                        AppPalette.blendOnPaper(
                                          accentColor,
                                          opacity: 0.22,
                                          base: colorScheme.surfaceContainerLow,
                                        ),
                                        AppPalette.blendOnPaper(
                                          accentColor,
                                          opacity: 0.08,
                                          base: colorScheme
                                              .surfaceContainerLowest,
                                        ),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    headerIcon,
                                    color: colorScheme.onSurface,
                                  ),
                                );

                          final showStackedTag =
                              headerTag != null && constraints.maxWidth < 620;

                          if (showStackedTag) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    leading,
                                    SizedBox(
                                      width: headerIcon == null ? 12 : 14,
                                    ),
                                    headerLabel,
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _CommonCardTag(
                                  label: headerTag!,
                                  accentColor: accentColor,
                                ),
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              leading,
                              SizedBox(width: headerIcon == null ? 12 : 14),
                              headerLabel,
                              if (headerTag != null) ...<Widget>[
                                const SizedBox(width: 12),
                                _CommonCardTag(
                                  label: headerTag!,
                                  accentColor: accentColor,
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                      if (subtitle != null) ...<Widget>[
                        const SizedBox(height: 20),
                      ] else
                        const SizedBox(height: 16),
                    ],
                    if (stretchContent) Expanded(child: child) else child,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommonCardTag extends StatelessWidget {
  const _CommonCardTag({required this.label, required this.accentColor});

  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppPalette.blendOnPaper(
          accentColor,
          opacity: 0.14,
          base: colorScheme.surfaceContainerLowest,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accentColor.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
