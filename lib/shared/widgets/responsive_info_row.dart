import 'package:flutter/material.dart';

/// 响应式信息行。
///
/// 适用于“标签 + 值”一类的说明项，在宽度不足时自动改为上下布局，
/// 避免桌面窄窗和移动端出现强行压缩或文字溢出。
class ResponsiveInfoRow extends StatelessWidget {
  /// 创建响应式信息行。
  const ResponsiveInfoRow({
    required this.label,
    required this.value,
    this.icon,
    this.compactBreakpoint = 520,
    this.labelWidth = 84,
    this.emphasizeValue = false,
    this.gap = 12,
    this.labelTextStyle,
    this.valueTextStyle,
    super.key,
  });

  /// 标签文本。
  final String label;

  /// 值文本。
  final String value;

  /// 可选前置图标。
  final IconData? icon;

  /// 切换为上下布局的断点。
  final double compactBreakpoint;

  /// 横向布局时的标签宽度。
  final double labelWidth;

  /// 是否强调值文本。
  final bool emphasizeValue;

  /// 间距。
  final double gap;

  /// 标签文本样式。
  final TextStyle? labelTextStyle;

  /// 值文本样式。
  final TextStyle? valueTextStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveLabelStyle =
        labelTextStyle ??
        theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        );
    final effectiveValueStyle =
        valueTextStyle ??
        theme.textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: emphasizeValue ? FontWeight.w700 : FontWeight.w600,
        );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < compactBreakpoint;
        final valueWidget = Text(
          value,
          textAlign: isCompact ? TextAlign.start : TextAlign.end,
          style: effectiveValueStyle,
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (icon != null) ...<Widget>[
                    Icon(icon, size: 18, color: colorScheme.primary),
                    SizedBox(width: gap),
                  ],
                  Text(label, style: effectiveLabelStyle),
                ],
              ),
              SizedBox(height: gap),
              valueWidget,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: 18, color: colorScheme.primary),
              SizedBox(width: gap),
            ],
            SizedBox(
              width: labelWidth,
              child: Text(label, style: effectiveLabelStyle),
            ),
            SizedBox(width: gap),
            Expanded(child: valueWidget),
          ],
        );
      },
    );
  }
}
