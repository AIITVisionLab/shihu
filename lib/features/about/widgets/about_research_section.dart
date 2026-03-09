import 'package:flutter/material.dart';
import 'package:sickandflutter/features/about/about_content.dart';
import 'package:sickandflutter/shared/widgets/adaptive_wrap_grid.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';
import 'package:sickandflutter/shared/widgets/responsive_info_row.dart';

/// 系统总览页栽培背景区块。
class AboutResearchSection extends StatelessWidget {
  /// 创建栽培背景区块。
  const AboutResearchSection({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: '栽培背景',
      subtitle: '幼苗阶段对微环境波动高度敏感，稳定性往往比单次高值更重要。',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 920;
          final narrative = const _NarrativePanel();
          final riskGrid = AdaptiveWrapGrid(
            minItemWidth: 220,
            spacing: 16,
            runSpacing: 16,
            children: AboutContent.risks
                .map((item) => _RiskPanel(item: item))
                .toList(),
          );

          if (isCompact) {
            return Column(
              children: <Widget>[
                narrative,
                const SizedBox(height: 16),
                riskGrid,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Expanded(flex: 7, child: _NarrativePanel()),
              const SizedBox(width: 18),
              Expanded(flex: 6, child: riskGrid),
            ],
          );
        },
      ),
    );
  }
}

class _NarrativePanel extends StatelessWidget {
  const _NarrativePanel();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(26),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(AboutContent.researchIntro, style: TextStyle(height: 1.72)),
          SizedBox(height: 16),
          Text(AboutContent.researchSummary, style: TextStyle(height: 1.72)),
          SizedBox(height: 20),
          ResponsiveInfoRow(label: '阶段特点', value: '连续波动比单次极值更容易积累风险。'),
          SizedBox(height: 10),
          ResponsiveInfoRow(label: '运营诉求', value: '在同一工作台完成查看、判断、处置和结果确认。'),
        ],
      ),
    );
  }
}

class _RiskPanel extends StatelessWidget {
  const _RiskPanel({required this.item});

  final AboutRiskItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.36),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              item.tag,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colorScheme.onTertiaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            item.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.7,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
