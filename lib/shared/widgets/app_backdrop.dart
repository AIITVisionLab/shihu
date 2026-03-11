import 'package:flutter/material.dart';

/// 应用级氛围背景。
///
/// 统一为首页、认证页和主控台提供更像正式软件的层次感背景，
/// 同时避免页面各自重复堆叠渐变和发光块实现。
class AppBackdrop extends StatelessWidget {
  /// 创建背景层。
  const AppBackdrop({
    this.baseGradient,
    this.orbs = const <BackdropOrbData>[
      BackdropOrbData(
        alignment: Alignment(-1.05, -0.95),
        size: 260,
        color: Color(0x0E26A497),
      ),
      BackdropOrbData(
        alignment: Alignment(1.08, -0.18),
        size: 220,
        color: Color(0x0DB68B63),
      ),
      BackdropOrbData(
        alignment: Alignment(0.78, 1.02),
        size: 200,
        color: Color(0x0C5D7E92),
      ),
    ],
    this.showGrid = true,
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
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                colorScheme.surface,
                colorScheme.surfaceContainerLowest,
                colorScheme.surface,
              ],
            ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      colorScheme.surface.withValues(alpha: 0.01),
                      colorScheme.primaryContainer.withValues(alpha: 0.02),
                      colorScheme.secondaryContainer.withValues(alpha: 0.03),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (showGrid)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _BackdropGridPainter(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.03),
                  ),
                ),
              ),
            ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _BackdropContourPainter(
                  lineColor: colorScheme.primary.withValues(alpha: 0.018),
                  accentColor: colorScheme.tertiary.withValues(alpha: 0.022),
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
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: orb.color,
                        blurRadius: orb.size * 0.22,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: -120,
            top: -80,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.08,
                      ),
                      blurRadius: 84,
                      spreadRadius: 24,
                    ),
                  ],
                ),
                child: const SizedBox(width: 220, height: 220),
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
  const _BackdropGridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.7;
    const step = 64.0;

    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BackdropGridPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _BackdropContourPainter extends CustomPainter {
  const _BackdropContourPainter({
    required this.lineColor,
    required this.accentColor,
  });

  final Color lineColor;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final mainPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final accentPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (var index = 0; index < 3; index += 1) {
      final progress = index / 3;
      final startY = size.height * (0.16 + progress * 0.2);
      final path = Path()
        ..moveTo(-40, startY)
        ..cubicTo(
          size.width * 0.24,
          startY - 16 - (index * 3),
          size.width * 0.58,
          startY + 18 + (index * 6),
          size.width + 60,
          startY - 4 + (index * 8),
        );
      canvas.drawPath(path, mainPaint);
    }

    final verticalPath = Path()
      ..moveTo(size.width * 0.76, -20)
      ..cubicTo(
        size.width * 0.84,
        size.height * 0.18,
        size.width * 0.7,
        size.height * 0.56,
        size.width * 0.8,
        size.height + 40,
      );
    canvas.drawPath(verticalPath, accentPaint);
  }

  @override
  bool shouldRepaint(covariant _BackdropContourPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.accentColor != accentColor;
  }
}
