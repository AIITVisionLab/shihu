import 'package:flutter/material.dart';

/// 设置页通用键值行。
class SettingsSettingRow extends StatelessWidget {
  /// 创建设置键值行。
  const SettingsSettingRow({
    required this.title,
    required this.value,
    this.trailing,
    super.key,
  });

  /// 左侧字段标题。
  final String title;

  /// 右侧字段值。
  final String value;

  /// 可选尾部操作区。
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.82),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 520 && trailing != null;
          final titleWidget = Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          );
          final valueWidget = SelectableText(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                titleWidget,
                const SizedBox(height: 8),
                valueWidget,
                const SizedBox(height: 12),
                trailing!,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    titleWidget,
                    const SizedBox(height: 8),
                    valueWidget,
                  ],
                ),
              ),
              if (trailing != null) ...<Widget>[
                const SizedBox(width: 12),
                trailing!,
              ],
            ],
          );
        },
      ),
    );
  }
}
