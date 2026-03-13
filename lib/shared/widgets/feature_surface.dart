import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';

/// 工作台重点区块的统一外壳。
class FeatureHeroCard extends StatelessWidget {
  /// 创建重点区块外壳。
  const FeatureHeroCard({
    required this.child,
    this.padding = const EdgeInsets.all(26),
    this.borderRadius = 34,
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
    final effectiveAccent = accentColor ?? AppPalette.pineGreen;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.hasBoundedWidth && constraints.maxWidth < 760;

        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                colorScheme.surfaceBright.withValues(alpha: 0.996),
                colorScheme.surfaceContainerLow.withValues(alpha: 0.978),
                AppPalette.paperMist.withValues(alpha: 0.94),
              ],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.84),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: effectiveAccent.withValues(alpha: 0.06),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
              const BoxShadow(
                color: Color(0x0E111813),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.36),
                      ),
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          Colors.white.withValues(alpha: 0.22),
                          effectiveAccent.withValues(alpha: 0.06),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: compact ? 14 : 18,
                  right: compact ? 18 : 22,
                  child: IgnorePointer(
                    child: Container(
                      width: compact ? 44 : 52,
                      height: 4,
                      decoration: BoxDecoration(
                        color: effectiveAccent.withValues(alpha: 0.36),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 24,
                  right: 24,
                  child: IgnorePointer(
                    child: Container(
                      height: 1.2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[
                            Colors.transparent,
                            effectiveAccent.withValues(alpha: 0.24),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 22,
                  bottom: 22,
                  left: 18,
                  child: IgnorePointer(
                    child: Container(
                      width: 1.5,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: effectiveAccent.withValues(alpha: 0.18),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -72,
                  right: compact ? -72 : -56,
                  child: IgnorePointer(
                    child: Container(
                      width: compact ? 180 : 220,
                      height: compact ? 180 : 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: <Color>[
                            effectiveAccent.withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (showPaletteBands)
                  Positioned(
                    right: compact ? -14 : -4,
                    bottom: compact ? -14 : 14,
                    child: IgnorePointer(
                      child: _PaletteBands(
                        primaryColor: effectiveAccent,
                        compact: compact,
                      ),
                    ),
                  ),
                Padding(padding: padding, child: child),
              ],
            ),
          ),
        );
      },
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
    this.showHighlightLine = true,
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
    final effectiveAccent = accentColor ?? colorScheme.primary;
    final leadingColor =
        backgroundColor ?? effectiveAccent.withValues(alpha: 0.12);
    final trailingColor = colorScheme.surfaceContainerLowest.withValues(
      alpha: 0.96,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[leadingColor, trailingColor, trailingColor],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.72),
        ),
        boxShadow: shadow
            ? <BoxShadow>[
                BoxShadow(
                  color: effectiveAccent.withValues(alpha: 0.06),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ]
            : const <BoxShadow>[],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Colors.white.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            if (showHighlightLine)
              Positioned(
                top: 0,
                left: 18,
                right: 18,
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        Colors.transparent,
                        effectiveAccent.withValues(alpha: 0.24),
                        Colors.transparent,
                      ],
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

class _PaletteBands extends StatelessWidget {
  const _PaletteBands({required this.primaryColor, required this.compact});

  final Color primaryColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = <Color>[
      primaryColor.withValues(alpha: 0.28),
      AppPalette.softPine.withValues(alpha: 0.24),
      AppPalette.mistMint.withValues(alpha: 0.22),
      AppPalette.linenOlive.withValues(alpha: 0.2),
      AppPalette.softLavender.withValues(alpha: 0.22),
    ];
    final width = compact ? 164.0 : 222.0;
    final height = compact ? 124.0 : 148.0;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: <Widget>[
          for (int index = 0; index < colors.length; index++)
            Positioned(
              right: index * (compact ? 16 : 18),
              bottom: index * (compact ? 2.5 : 3),
              child: Transform.rotate(
                angle: index.isEven ? -0.02 : 0.024,
                child: Container(
                  width: compact ? 48 : 60,
                  height: height - (index * (compact ? 8 : 10)),
                  decoration: BoxDecoration(
                    color: colors[index],
                    borderRadius: BorderRadius.circular(compact ? 22 : 28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.28),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: const Color(
                          0x0F131815,
                        ).withValues(alpha: compact ? 0.84 : 1),
                        blurRadius: compact ? 8 : 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
