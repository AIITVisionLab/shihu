import 'package:flutter/material.dart';
import 'package:sickandflutter/features/about/about_content.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 系统总览页主路径轨道区块。
class AboutCapabilitySection extends StatelessWidget {
  /// 创建主路径轨道区块。
  const AboutCapabilitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: '主路径怎么走',
      subtitle: '把同类信息收进同一条轨道里，先看什么时候进，再看进去之后做什么。',
      child: Column(
        children: AboutContent.workflowTracks
            .map(
              (item) => Padding(
                padding: EdgeInsets.only(
                  bottom: item == AboutContent.workflowTracks.last ? 0 : 16,
                ),
                child: _WorkflowTrackCard(item: item),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _WorkflowTrackCard extends StatelessWidget {
  const _WorkflowTrackCard({required this.item});

  final AboutWorkflowTrack item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.82),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 820;
          final infoGrid = _WorkflowTrackDetails(item: item);
          final overview = _WorkflowTrackOverview(item: item);

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                overview,
                const SizedBox(height: 18),
                infoGrid,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(flex: 5, child: overview),
              const SizedBox(width: 18),
              Expanded(flex: 7, child: infoGrid),
            ],
          );
        },
      ),
    );
  }
}

class _WorkflowTrackOverview extends StatelessWidget {
  const _WorkflowTrackOverview({required this.item});

  final AboutWorkflowTrack item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[colorScheme.primary, colorScheme.tertiary],
                ),
              ),
              child: Icon(item.icon, color: colorScheme.onPrimary, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.step,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          item.summary,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
            height: 1.68,
          ),
        ),
      ],
    );
  }
}

class _WorkflowTrackDetails extends StatelessWidget {
  const _WorkflowTrackDetails({required this.item});

  final AboutWorkflowTrack item;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 640 ? 3 : 1;
        final itemWidth =
            (constraints.maxWidth - ((columns - 1) * 12)) / columns;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            SizedBox(
              width: itemWidth,
              child: _WorkflowDetailCell(label: '什么时候进', value: item.entryHint),
            ),
            SizedBox(
              width: itemWidth,
              child: _WorkflowDetailCell(label: '重点看什么', value: item.focusHint),
            ),
            SizedBox(
              width: itemWidth,
              child: _WorkflowDetailCell(
                label: '进去后做什么',
                value: item.actionHint,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WorkflowDetailCell extends StatelessWidget {
  const _WorkflowDetailCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.64,
            ),
          ),
        ],
      ),
    );
  }
}
