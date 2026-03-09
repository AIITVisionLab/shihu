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
        alignment: Alignment(-1.1, -1.0),
        size: 320,
        color: Color(0x2B83C88C),
      ),
      BackdropOrbData(
        alignment: Alignment(1.05, -0.3),
        size: 260,
        color: Color(0x2AB98A50),
      ),
      BackdropOrbData(
        alignment: Alignment(0.75, 1.1),
        size: 220,
        color: Color(0x1E4E7E6A),
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
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                colorScheme.surface,
                colorScheme.surfaceContainerLowest,
                colorScheme.surfaceContainerLow,
              ],
            ),
      ),
      child: Stack(
        children: <Widget>[
          if (showGrid)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _BackdropGridPainter(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.12),
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
                        blurRadius: orb.size * 0.34,
                        spreadRadius: 12,
                      ),
                    ],
                  ),
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
  const _BackdropGridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const step = 28.0;

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
