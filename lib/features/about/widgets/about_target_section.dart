import 'package:flutter/material.dart';
import 'package:sickandflutter/features/about/about_content.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 系统总览页调控目标区块。
class AboutTargetSection extends StatelessWidget {
  /// 创建调控目标区块。
  const AboutTargetSection({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: '调控目标',
      subtitle: '把经验阈值沉淀为日常可执行的运营目标和处理顺序。',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 920;
          final metrics = const _MetricsPanel();
          final flow = const _FlowPanel();

          if (isCompact) {
            return Column(
              children: <Widget>[metrics, const SizedBox(height: 16), flow],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Expanded(flex: 7, child: _MetricsPanel()),
              const SizedBox(width: 18),
              const Expanded(flex: 6, child: _FlowPanel()),
            ],
          );
        },
      ),
    );
  }
}

class _MetricsPanel extends StatelessWidget {
  const _MetricsPanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ...AboutContent.goalMetrics.map(
          (item) => Padding(
            padding: EdgeInsets.only(
              bottom: item == AboutContent.goalMetrics.last ? 0 : 14,
            ),
            child: _MetricTile(item: item),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.secondaryContainer.withValues(alpha: 0.48),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            AboutContent.targetSummary,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.7),
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.item});

  final AboutGoalMetric item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                item.label,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                item.target,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: item.progress,
              minHeight: 10,
              backgroundColor: colorScheme.surfaceContainerHigh,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.note,
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

class _FlowPanel extends StatelessWidget {
  const _FlowPanel();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.24),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '执行闭环',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          ...AboutContent.flowSteps.map(
            (item) => Padding(
              padding: EdgeInsets.only(
                bottom: item == AboutContent.flowSteps.last ? 0 : 14,
              ),
              child: _FlowStepTile(item: item),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowStepTile extends StatelessWidget {
  const _FlowStepTile({required this.item});

  final AboutFlowStep item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              item.index,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                item.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                item.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.65,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
