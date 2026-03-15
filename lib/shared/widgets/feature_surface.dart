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
                colorScheme.surfaceContainerLowest.withValues(alpha: 0.995),
                AppPalette.frost.withValues(alpha: 0.99),
                AppPalette.paperMist.withValues(alpha: 0.96),
              ],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.84),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppPalette.pineShadow.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: effectiveAccent.withValues(alpha: 0.08),
                blurRadius: 34,
                offset: const Offset(0, 16),
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
                        color: Colors.white.withValues(alpha: 0.5),
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
                          Colors.white.withValues(alpha: 0.24),
                          effectiveAccent.withValues(alpha: 0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: compact ? 16 : 18,
                  right: compact ? 18 : 24,
                  child: IgnorePointer(
                    child: Container(
                      width: compact ? 52 : 72,
                      height: 5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[
                            effectiveAccent.withValues(alpha: 0.72),
                            AppPalette.mistMint.withValues(alpha: 0.64),
                            AppPalette.softLavender.withValues(alpha: 0.52),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 26,
                  right: 26,
                  child: IgnorePointer(
                    child: Container(
                      height: 1.3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.7),
                            effectiveAccent.withValues(alpha: 0.28),
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
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            effectiveAccent.withValues(alpha: 0.7),
                            AppPalette.mistMint.withValues(alpha: 0.42),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: const SizedBox(width: 2.2),
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
        backgroundColor ?? effectiveAccent.withValues(alpha: 0.16);
    final trailingColor = colorScheme.surfaceContainerLowest.withValues(
      alpha: 0.98,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            leadingColor,
            AppPalette.frost.withValues(alpha: 0.96),
            trailingColor,
          ],
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.78),
        ),
        boxShadow: shadow
            ? <BoxShadow>[
                BoxShadow(
                  color: effectiveAccent.withValues(alpha: 0.1),
                  blurRadius: 26,
                  offset: const Offset(0, 12),
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
                        Colors.white.withValues(alpha: 0.55),
                        effectiveAccent.withValues(alpha: 0.28),
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
      primaryColor.withValues(alpha: 0.32),
      AppPalette.softPine.withValues(alpha: 0.28),
      AppPalette.mistMint.withValues(alpha: 0.26),
      AppPalette.linenOlive.withValues(alpha: 0.24),
      AppPalette.softLavender.withValues(alpha: 0.28),
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
