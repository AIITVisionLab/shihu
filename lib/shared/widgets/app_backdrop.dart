import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';

/// 应用级氛围背景。
///
/// 统一为首页、认证页和主控台提供稳定的纸感底层。
class AppBackdrop extends StatelessWidget {
  /// 创建背景层。
  const AppBackdrop({
    this.baseGradient,
    this.orbs = const <BackdropOrbData>[],
    this.showGrid = false,
    super.key,
  });

  /// 基础渐变。
  final Gradient? baseGradient;

  /// 发光装饰配置。
  final List<BackdropOrbData> orbs;

  /// 是否绘制细网格纹理。
  final bool showGrid;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient:
            baseGradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                AppPalette.paperSnow,
                AppPalette.frost,
                AppPalette.paper,
              ],
            ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.9, -1.0),
                  radius: 0.9,
                  colors: <Color>[
                    AppPalette.softPine.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.98, -0.86),
                  radius: 0.82,
                  colors: <Color>[
                    AppPalette.mistMint.withValues(alpha: 0.07),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.8, 0.92),
                  radius: 0.86,
                  colors: <Color>[
                    AppPalette.softLavender.withValues(alpha: 0.035),
                    Colors.transparent,
                  ],
                ),
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
                    Colors.white.withValues(alpha: 0.14),
                    AppPalette.mistMint.withValues(alpha: 0.04),
                    AppPalette.linenOlive.withValues(alpha: 0.02),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          ...orbs.map(
            (orb) => Align(
              alignment: orb.alignment,
              child: IgnorePointer(
                child: Container(
                  width: orb.size,
                  height: orb.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: <Color>[
                        orb.color,
                        orb.color.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (showGrid)
            Positioned.fill(
              child: CustomPaint(
                painter: _BackdropGridPainter(
                  lineColor: colorScheme.outlineVariant.withValues(
                    alpha: 0.032,
                  ),
                  emphasisColor: AppPalette.softPine.withValues(alpha: 0.04),
                ),
              ),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.white.withValues(alpha: 0.04),
                    Colors.transparent,
                    colorScheme.surface.withValues(alpha: 0.08),
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

/// 单个背景光斑配置。
class BackdropOrbData {
  /// 创建背景光斑配置。
  const BackdropOrbData({
    required this.alignment,
    required this.size,
    required this.color,
  });

  /// 光斑所在对齐位置。
  final Alignment alignment;

  /// 光斑尺寸。
  final double size;

  /// 光斑颜色。
  final Color color;
}

class _BackdropGridPainter extends CustomPainter {
  const _BackdropGridPainter({
    required this.lineColor,
    required this.emphasisColor,
  });

  final Color lineColor;
  final Color emphasisColor;

  @override
  void paint(Canvas canvas, Size size) {
    final minorPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.7;
    final majorPaint = Paint()
      ..color = emphasisColor
      ..strokeWidth = 1;
    const step = 52.0;

    int index = 0;
    for (double x = 0; x <= size.width; x += step, index++) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        index % 4 == 0 ? majorPaint : minorPaint,
      );
    }

    index = 0;
    for (double y = 0; y <= size.height; y += step, index++) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        index % 4 == 0 ? majorPaint : minorPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BackdropGridPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.emphasisColor != emphasisColor;
  }
}
