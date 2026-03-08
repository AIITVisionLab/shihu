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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 520 && trailing != null;
        final titleWidget = Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        );
        final valueWidget = SelectableText(value);

        if (isCompact) {
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
    );
  }
}
