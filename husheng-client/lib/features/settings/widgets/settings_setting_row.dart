import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/shared/widgets/feature_surface.dart';

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

    return FeatureInsetPanel(
      padding: const EdgeInsets.all(14),
      borderRadius: 18,
      accentColor: AppPalette.softPine,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 520 && trailing != null;
          final titleWidget = Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          );
          final valueWidget = SelectableText(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              height: 1.45,
            ),
          );

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                titleWidget,
                const SizedBox(height: 6),
                valueWidget,
                const SizedBox(height: 10),
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
                    const SizedBox(height: 6),
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
