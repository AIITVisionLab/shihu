import 'package:flutter/material.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 结果页信息卡片，统一展示标题、值和辅助说明。
class ResultInfoCard extends StatelessWidget {
  /// 创建结果信息卡片。
  const ResultInfoCard({
    required this.title,
    required this.value,
    this.subtitle,
    this.leading,
    this.valueColor,
    super.key,
  });

  /// 信息标题。
  final String title;

  /// 主要值。
  final String value;

  /// 辅助说明。
  final String? subtitle;

  /// 可选前置部件。
  final Widget? leading;

  /// 主要值颜色。
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return CommonCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: <Widget>[
          if (leading != null) ...<Widget>[leading!, const SizedBox(width: 14)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                  ),
                ),
                if (subtitle != null) ...<Widget>[
                  const SizedBox(height: 6),
                  Text(subtitle!, style: textTheme.bodyMedium),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
