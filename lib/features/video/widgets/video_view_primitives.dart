import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/shared/widgets/feature_surface.dart';

/// 视频页信息块。
class VideoInfoTile extends StatelessWidget {
  /// 创建视频页信息块。
  const VideoInfoTile({
    required this.label,
    required this.value,
    this.accentColor = AppPalette.mistMint,
    super.key,
  });

  /// 标题。
  final String label;

  /// 值文案。
  final String value;

  /// 强调色。
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return FeatureSummaryTile(
      label: label,
      value: value,
      accentColor: accentColor,
      padding: const EdgeInsets.all(14),
      borderRadius: 20,
      shadow: true,
    );
  }
}

/// 视频页状态标签色调。
enum VideoStatusChipTone {
  /// 强调在线状态。
  active,

  /// 强调可用信息。
  info,

  /// 强调补充信息。
  secondary,

  /// 弱化不可用信息。
  muted,
}

/// 视频页状态标签。
class VideoStatusChip extends StatelessWidget {
  /// 创建视频页状态标签。
  const VideoStatusChip({required this.label, required this.tone, super.key});

  /// 文案。
  final String label;

  /// 色调。
  final VideoStatusChipTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final (backgroundColor, foregroundColor) = switch (tone) {
      VideoStatusChipTone.active => (
        AppPalette.softPine.withValues(alpha: 0.88),
        AppPalette.deepPine,
      ),
      VideoStatusChipTone.info => (
        AppPalette.mistMint.withValues(alpha: 0.92),
        AppPalette.deepPine,
      ),
      VideoStatusChipTone.secondary => (
        AppPalette.linenOlive.withValues(alpha: 0.92),
        const Color(0xFF6C654E),
      ),
      VideoStatusChipTone.muted => (
        AppPalette.blendOnPaper(
          AppPalette.softLavender,
          opacity: 0.08,
          base: colorScheme.surfaceContainerHigh,
        ),
        colorScheme.onSurfaceVariant,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: foregroundColor.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// 视频页画面状态信号点。
class VideoSignalDot extends StatelessWidget {
  /// 创建视频页画面状态信号点。
  const VideoSignalDot({required this.active, super.key});

  /// 是否激活。
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = active ? colorScheme.secondary : colorScheme.outlineVariant;

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: active
            ? <BoxShadow>[
                BoxShadow(
                  color: color.withValues(alpha: 0.42),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : const <BoxShadow>[],
      ),
    );
  }
}

/// 视频页网格背景绘制器。
class VideoScreenGridPainter extends CustomPainter {
  /// 创建视频页网格背景绘制器。
  const VideoScreenGridPainter({
    required this.lineColor,
    required this.accentColor,
  });

  /// 常规线条颜色。
  final Color lineColor;

  /// 强调线颜色。
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 0.8;
    final accentPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 1.1;
    const step = 28.0;

    int index = 0;
    for (double x = 0; x <= size.width; x += step, index++) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        index % 4 == 0 ? accentPaint : linePaint,
      );
    }
    index = 0;
    for (double y = 0; y <= size.height; y += step, index++) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        index % 4 == 0 ? accentPaint : linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant VideoScreenGridPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.accentColor != accentColor;
  }
}
