import 'package:flutter/material.dart';
import 'package:sickandflutter/features/about/about_content.dart';
import 'package:sickandflutter/shared/widgets/adaptive_wrap_grid.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';
import 'package:sickandflutter/shared/widgets/responsive_info_row.dart';

/// 系统总览页业务架构区块。
class AboutCapabilitySection extends StatelessWidget {
  /// 创建业务架构区块。
  const AboutCapabilitySection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CommonCard(
      title: '业务架构',
      subtitle: '围绕账号、监测、判断、执行和运维构建单一业务闭环。',
      child: Column(
        children: <Widget>[
          AdaptiveWrapGrid(
            minItemWidth: 220,
            spacing: 16,
            runSpacing: 16,
            children: AboutContent.capabilities
                .map((item) => _CapabilityPanel(item: item))
                .toList(),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.36),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ResponsiveInfoRow(label: '闭环重点', value: '采集 / 判断 / 执行 / 回写'),
                SizedBox(height: 10),
                ResponsiveInfoRow(
                  label: '核心收益',
                  value: '把分散值守动作收进统一工作台，降低巡检遗漏和沟通损耗。',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CapabilityPanel extends StatelessWidget {
  const _CapabilityPanel({required this.item});

  final AboutCapabilityItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.34),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(item.icon, color: colorScheme.secondary),
          ),
          const SizedBox(height: 16),
          Text(
            item.title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            item.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.65,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
