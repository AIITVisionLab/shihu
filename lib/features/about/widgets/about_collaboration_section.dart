import 'package:flutter/material.dart';
import 'package:sickandflutter/features/about/about_content.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 系统总览页后端协作说明区块。
class AboutCollaborationSection extends StatelessWidget {
  /// 创建后端协作说明区块。
  const AboutCollaborationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CommonCard(
      title: '视频与 AI 协作边界',
      subtitle: '根据两份英文命名文档补齐接入逻辑，但不把未交付能力伪装成当前可用入口。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.44),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Text(
              AboutContent.collaborationSummary,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
                height: 1.66,
              ),
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 900;
              final topicCards = AboutContent.collaborationTopics
                  .map((item) => _CollaborationTopicCard(item: item))
                  .toList(growable: false);

              if (isCompact) {
                return Column(
                  children: topicCards
                      .map(
                        (item) => Padding(
                          padding: EdgeInsets.only(
                            bottom: item == topicCards.last ? 0 : 14,
                          ),
                          child: item,
                        ),
                      )
                      .toList(growable: false),
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: topicCards.first),
                  const SizedBox(width: 16),
                  Expanded(child: topicCards.last),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CollaborationTopicCard extends StatelessWidget {
  const _CollaborationTopicCard({required this.item});

  final AboutCollaborationTopic item;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              item.badge,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(item.icon, color: colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.summary,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.68,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _TopicDetailTile(label: '最小接口', value: item.interfaceValue),
          const SizedBox(height: 12),
          _TopicDetailTile(label: '前端怎么接', value: item.frontendAction),
          const SizedBox(height: 12),
          _TopicDetailTile(label: '关键边界', value: item.boundary),
        ],
      ),
    );
  }
}

class _TopicDetailTile extends StatelessWidget {
  const _TopicDetailTile({required this.label, required this.value});

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
              height: 1.66,
            ),
          ),
        ],
      ),
    );
  }
}
