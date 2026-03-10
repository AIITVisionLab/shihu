import 'package:flutter/material.dart';

/// 视频模块统一状态标签。
class VideoStreamStatusChip extends StatelessWidget {
  /// 创建状态标签。
  const VideoStreamStatusChip({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    this.icon,
    super.key,
  });

  /// 标签文案。
  final String label;

  /// 背景颜色。
  final Color backgroundColor;

  /// 前景颜色。
  final Color foregroundColor;

  /// 可选图标。
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 16, color: foregroundColor),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: foregroundColor),
          ),
        ],
      ),
    );
  }
}
