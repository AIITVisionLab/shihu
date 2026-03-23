import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';

/// 卡片顶部统一高光线。
class SurfaceHighlightLine extends StatelessWidget {
  /// 创建卡片顶部统一高光线。
  const SurfaceHighlightLine({
    this.color = AppPalette.softPine,
    this.horizontalPadding = 20,
    this.opacity = 0.5,
    super.key,
  });

  /// 高光主色。
  final Color color;

  /// 与卡片左右边缘的距离。
  final double horizontalPadding;

  /// 高光透明度。
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Container(
          height: 2,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[
                color.withValues(alpha: 0),
                color.withValues(alpha: opacity * 0.28),
                color.withValues(alpha: opacity),
                color.withValues(alpha: opacity * 0.28),
                color.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 卡片左上角的短色线。
class SurfaceAccentStub extends StatelessWidget {
  /// 创建卡片左上角的短色线。
  const SurfaceAccentStub({
    required this.color,
    this.width = 36,
    this.height = 4,
    this.opacity = 0.78,
    super.key,
  });

  /// 强调色。
  final Color color;

  /// 宽度。
  final double width;

  /// 高度。
  final double height;

  /// 透明度。
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

/// 工作台重点区块的统一外壳。
class FeatureHeroCard extends StatelessWidget {
  /// 创建重点区块外壳。
  const FeatureHeroCard({
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.borderRadius = 30,
    this.accentColor,
    this.showPaletteBands = false,
    super.key,
  });

  /// 内容区。
  final Widget child;

  /// 内边距。
  final EdgeInsetsGeometry padding;

  /// 圆角。
  final double borderRadius;

  /// 主要强调色。
  final Color? accentColor;

  /// 是否展示参考配色叠片。
  final bool showPaletteBands;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final highlightColor = accentColor ?? colorScheme.primary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              AppPalette.blendOnPaper(
                highlightColor,
                opacity: 0.045,
                base: colorScheme.surfaceBright,
              ).withValues(alpha: 0.985),
              AppPalette.blendOnPaper(
                highlightColor,
                opacity: 0.018,
                base: colorScheme.surfaceContainerLowest,
              ).withValues(alpha: 0.975),
              AppPalette.blendOnPaper(
                highlightColor,
                opacity: 0.01,
                base: colorScheme.surfaceContainerLow,
              ).withValues(alpha: 0.94),
            ],
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.88),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppPalette.pineShadow.withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
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
                      center: const Alignment(-0.82, -0.9),
                      radius: 1.05,
                      colors: <Color>[
                        highlightColor.withValues(alpha: 0.055),
                        highlightColor.withValues(alpha: 0.012),
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
              child: SurfaceHighlightLine(color: highlightColor, opacity: 0.26),
            ),
            Positioned(
              top: -52,
              right: -16,
              child: IgnorePointer(
                child: Container(
                  width: 180,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: <Color>[
                        highlightColor.withValues(alpha: 0.085),
                        highlightColor.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}

/// 工作台中的二级信息面板。
class FeatureInsetPanel extends StatelessWidget {
  /// 创建二级信息面板。
  const FeatureInsetPanel({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 22,
    this.accentColor,
    this.backgroundColor,
    this.showHighlightLine = false,
    this.shadow = false,
    super.key,
  });

  /// 内容区。
  final Widget child;

  /// 内边距。
  final EdgeInsetsGeometry padding;

  /// 圆角。
  final double borderRadius;

  /// 强调色。
  final Color? accentColor;

  /// 自定义背景色。
  final Color? backgroundColor;

  /// 是否展示顶部高光线。
  final bool showHighlightLine;

  /// 是否展示轻投影。
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final highlightColor = accentColor ?? colorScheme.primary;
    final surfaceBase = backgroundColor ?? colorScheme.surfaceBright;
    final blendedStart = AppPalette.blendOnPaper(
      highlightColor,
      opacity: 0.085,
      base: surfaceBase,
    ).withValues(alpha: 0.965);
    final blendedEnd = AppPalette.blendOnPaper(
      highlightColor,
      opacity: 0.016,
      base: colorScheme.surfaceContainerLowest,
    ).withValues(alpha: 0.925);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[blendedStart, blendedEnd],
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.82),
          ),
          boxShadow: shadow
              ? <BoxShadow>[
                  BoxShadow(
                    color: AppPalette.pineShadow.withValues(alpha: 0.028),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : const <BoxShadow>[],
        ),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(-0.88, -0.92),
                      radius: 1.02,
                      colors: <Color>[
                        highlightColor.withValues(alpha: 0.045),
                        highlightColor.withValues(alpha: 0.01),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (showHighlightLine)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SurfaceHighlightLine(
                  color: highlightColor,
                  opacity: 0.34,
                ),
              ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}

/// 工作台中的色块信息卡。
///
/// 用于把“标签 + 值 + 辅助说明”收成统一的色块样式，
/// 让总览、值守、视频、设置里的二级信息保持同一视觉语言。
class FeatureSummaryTile extends StatelessWidget {
  /// 创建色块信息卡。
  const FeatureSummaryTile({
    required this.label,
    required this.value,
    required this.accentColor,
    this.icon,
    this.description,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
    this.shadow = true,
    super.key,
  });

  /// 标签。
  final String label;

  /// 主值文案。
  final String value;

  /// 强调色。
  final Color accentColor;

  /// 可选图标。
  final IconData? icon;

  /// 可选说明。
  final String? description;

  /// 内边距。
  final EdgeInsetsGeometry padding;

  /// 圆角。
  final double borderRadius;

  /// 是否展示阴影。
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final startColor = AppPalette.blendOnPaper(
      accentColor,
      opacity: 0.22,
      base: colorScheme.surfaceBright,
    ).withValues(alpha: 0.985);
    final endColor = AppPalette.blendOnPaper(
      accentColor,
      opacity: 0.085,
      base: colorScheme.surfaceContainerLowest,
    ).withValues(alpha: 0.96);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[startColor, endColor],
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: accentColor.withValues(alpha: 0.14)),
          boxShadow: shadow
              ? <BoxShadow>[
                  BoxShadow(
                    color: AppPalette.pineShadow.withValues(alpha: 0.024),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]
              : const <BoxShadow>[],
        ),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(-0.95, -0.92),
                      radius: 1.05,
                      colors: <Color>[
                        accentColor.withValues(alpha: 0.09),
                        accentColor.withValues(alpha: 0.025),
                        Colors.transparent,
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
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      SurfaceAccentStub(color: accentColor),
                      if (icon != null) ...<Widget>[
                        const Spacer(),
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppPalette.blendOnPaper(
                              accentColor,
                              opacity: 0.14,
                              base: colorScheme.surfaceContainerLowest,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: accentColor.withValues(alpha: 0.16),
                            ),
                          ),
                          child: Icon(icon, color: accentColor, size: 18),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (description != null) ...<Widget>[
                    const SizedBox(height: 8),
                    Text(
                      description!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.54,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
