import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';

const String _brandAssetPath = 'assets/branding/app_icon.png';

/// 应用品牌标记容器。
class AppBrandBadge extends StatelessWidget {
  /// 创建品牌标记容器。
  const AppBrandBadge({
    this.size = 60,
    this.padding,
    this.backgroundColor,
    this.strokeColor,
    this.showShadow = true,
    super.key,
  });

  /// 容器尺寸。
  final double size;

  /// 内边距。
  final double? padding;

  /// 背景色。
  final Color? backgroundColor;

  /// 线条颜色。
  final Color? strokeColor;

  /// 是否展示阴影。
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveBackground =
        backgroundColor ?? colorScheme.surfaceBright.withValues(alpha: 0.82);

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(padding ?? size * 0.12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            effectiveBackground,
            AppPalette.paperSnow.withValues(alpha: 0.94),
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.36),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.78),
        ),
        boxShadow: showShadow
            ? <BoxShadow>[
                BoxShadow(
                  color: const Color(0x102B241B),
                  blurRadius: size * 0.22,
                  offset: Offset(0, size * 0.1),
                ),
              ]
            : const <BoxShadow>[],
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.26),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppPalette.pineInk.withValues(alpha: 0.03),
              blurRadius: size * 0.08,
              offset: Offset(0, size * 0.02),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.26),
          child: AppBrandMark(strokeColor: strokeColor),
        ),
      ),
    );
  }
}

/// 应用品牌标记。
class AppBrandMark extends StatelessWidget {
  /// 创建品牌标记。
  const AppBrandMark({this.strokeColor, super.key});

  /// 线条颜色。
  final Color? strokeColor;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _brandAssetPath,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppPalette.pineGreen.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            Icons.local_florist_rounded,
            color: strokeColor ?? AppPalette.pineInk,
          ),
        );
      },
    );
  }
}
