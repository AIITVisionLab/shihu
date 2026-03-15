import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';

/// 应用级氛围背景。
///
/// 统一为首页、认证页和主控台提供稳定的纸感底层。
class AppBackdrop extends StatelessWidget {
  /// 创建背景层。
  const AppBackdrop({
    this.baseGradient,
    this.orbs = const <BackdropOrbData>[
      BackdropOrbData(
        alignment: Alignment(-1.02, -0.96),
        size: 320,
        color: Color(0x16518463),
      ),
      BackdropOrbData(
        alignment: Alignment(1.06, -0.18),
        size: 300,
        color: Color(0x14CBF2E0),
      ),
      BackdropOrbData(
        alignment: Alignment(0.96, 1.04),
        size: 260,
        color: Color(0x14CEBBD8),
      ),
      BackdropOrbData(
        alignment: Alignment(-0.88, 1.08),
        size: 240,
        color: Color(0x12D2C8AC),
      ),
    ],
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
                  center: const Alignment(-0.76, -0.92),
                  radius: 1.08,
                  colors: <Color>[
                    AppPalette.softPine.withValues(alpha: 0.1),
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
                    Colors.white.withValues(alpha: 0.22),
                    AppPalette.mistMint.withValues(alpha: 0.08),
                    AppPalette.linenOlive.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _BackdropPaperTexturePainter(
                fiberColor: AppPalette.fogMint.withValues(alpha: 0.18),
                fleckColor: AppPalette.outlineSoft.withValues(alpha: 0.14),
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
                    Colors.white.withValues(alpha: 0.08),
                    Colors.transparent,
                    colorScheme.surface.withValues(alpha: 0.16),
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

class _BackdropPaperTexturePainter extends CustomPainter {
  const _BackdropPaperTexturePainter({
    required this.fiberColor,
    required this.fleckColor,
  });

  final Color fiberColor;
  final Color fleckColor;

  @override
  void paint(Canvas canvas, Size size) {
    final fiberPaint = Paint()
      ..color = fiberColor
      ..strokeWidth = 0.7
      ..strokeCap = StrokeCap.round;
    final fleckPaint = Paint()..color = fleckColor;

    for (double x = 14; x < size.width; x += 36) {
      final offsetSeed = (x * 0.37) % 28;
      for (double y = offsetSeed + 8; y < size.height; y += 94) {
        final drift = ((x + y) % 11) - 5;
        final length = 16 + ((x + y) % 22);
        final endY = (y + length).clamp(0.0, size.height).toDouble();
        canvas.drawLine(
          Offset(x, y),
          Offset(x + drift * 0.2, endY),
          fiberPaint,
        );
      }
    }

    for (double x = 20; x < size.width; x += 58) {
      final offsetSeed = (x * 0.19) % 32;
      for (double y = offsetSeed + 10; y < size.height; y += 110) {
        canvas.drawCircle(
          Offset(x, y),
          0.7 + (((x + y) % 4) * 0.12),
          fleckPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BackdropPaperTexturePainter oldDelegate) {
    return oldDelegate.fiberColor != fiberColor ||
        oldDelegate.fleckColor != fleckColor;
  }
}
