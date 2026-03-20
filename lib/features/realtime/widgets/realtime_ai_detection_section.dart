import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/features/ai/domain/ai_detection_summary.dart';
import 'package:sickandflutter/shared/widgets/common_button.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';
import 'package:sickandflutter/shared/widgets/feature_surface.dart';

/// 值守台中的 AI 巡检结果区。
class RealtimeAiDetectionSection extends StatelessWidget {
  /// 创建 AI 巡检结果区。
  const RealtimeAiDetectionSection({
    required this.overviewAsync,
    required this.onRefresh,
    super.key,
  });

  /// AI 检测总览异步状态。
  final AsyncValue<AiDetectionOverview> overviewAsync;

  /// 刷新回调。
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: 'AI 巡检',
      subtitle: '直接读取后端汇总后的边缘识别结果，辅助值守时快速判断风险。',
      accentColor: AppPalette.softLavender,
      padding: const EdgeInsets.all(18),
      child: overviewAsync.when(
        loading: () => Row(
          children: <Widget>[
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '正在同步 AI 巡检结果...',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
        error: (error, stackTrace) =>
            _StateBlock(message: 'AI 巡检结果加载失败：$error', onRefresh: onRefresh),
        data: (overview) {
          if (!overview.hasAnyData) {
            return const _EmptyBlock();
          }

          final latest = overview.latest;
          final history = overview.history;

          return LayoutBuilder(
            builder: (context, constraints) {
              final latestPanel = latest == null
                  ? const _EmptyLatestPanel()
                  : _LatestPanel(latest: latest);
              final historyPanel = _HistoryPanel(history: history);
              final refreshButton = CommonButton(
                label: '刷新 AI 巡检',
                tone: CommonButtonTone.secondary,
                icon: const Icon(Icons.refresh_rounded),
                onPressed: onRefresh,
              );

              if (constraints.maxWidth < 980) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    latestPanel,
                    const SizedBox(height: 14),
                    historyPanel,
                    const SizedBox(height: 14),
                    refreshButton,
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(flex: 7, child: latestPanel),
                      const SizedBox(width: 14),
                      Expanded(flex: 5, child: historyPanel),
                    ],
                  ),
                  const SizedBox(height: 14),
                  refreshButton,
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _StateBlock extends StatelessWidget {
  const _StateBlock({required this.message, required this.onRefresh});

  final String message;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: colorScheme.error,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 14),
        CommonButton(
          label: '重新获取',
          tone: CommonButtonTone.secondary,
          icon: const Icon(Icons.refresh_rounded),
          onPressed: onRefresh,
        ),
      ],
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  const _EmptyBlock();

  @override
  Widget build(BuildContext context) {
    return FeatureInsetPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: 24,
      accentColor: AppPalette.softLavender,
      shadow: true,
      child: Text(
        '后端尚未收到边缘 AI 上报。可以先去视频中心确认 AI 结果转发是否已经打开，再回到这里刷新。',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
      ),
    );
  }
}

class _EmptyLatestPanel extends StatelessWidget {
  const _EmptyLatestPanel();

  @override
  Widget build(BuildContext context) {
    return FeatureInsetPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: 24,
      accentColor: AppPalette.softLavender,
      shadow: true,
      child: Text(
        '当前还没有最新 AI 结果。',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6),
      ),
    );
  }
}

class _LatestPanel extends StatelessWidget {
  const _LatestPanel({required this.latest});

  final AiDetectionSummary latest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final riskLabel = _riskLabel(latest.overallRiskLevel);
    final riskColor = _riskColor(latest.overallRiskLevel);
    final primaryItems = latest.items.take(3).toList(growable: false);

    return FeatureInsetPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: 24,
      accentColor: riskColor,
      shadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '最新结论',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      latest.summary.isEmpty ? '后端未返回总结文案。' : latest.summary,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _RiskBadge(
                label: riskLabel.isEmpty ? '待确认' : riskLabel,
                color: riskColor,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _MetaBadge(
                icon: Icons.videocam_outlined,
                label: _sourceLabel(latest),
              ),
              _MetaBadge(
                icon: Icons.center_focus_strong_rounded,
                label: '${latest.detectionCount} 个目标',
              ),
              _MetaBadge(
                icon: Icons.schedule_rounded,
                label: _formatDateTime(latest.detectedAt),
              ),
              if (latest.frameId != null)
                _MetaBadge(
                  icon: Icons.confirmation_num_outlined,
                  label: '帧 ${latest.frameId}',
                ),
            ],
          ),
          if (primaryItems.isNotEmpty) ...<Widget>[
            const SizedBox(height: 14),
            Text(
              '重点目标',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: <Widget>[
                for (
                  int index = 0;
                  index < primaryItems.length;
                  index++
                ) ...<Widget>[
                  _DetectionItemTile(item: primaryItems[index]),
                  if (index != primaryItems.length - 1)
                    const SizedBox(height: 10),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DetectionItemTile extends StatelessWidget {
  const _DetectionItemTile({required this.item});

  final AiDetectionItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final riskLabel = _riskLabel(item.riskLevel);
    final riskColor = _riskColor(item.riskLevel);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppPalette.blendOnPaper(
          AppPalette.softLavender,
          opacity: 0.12,
          base: colorScheme.surfaceContainerLowest,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppPalette.softLavender.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text(
                item.displayName.isEmpty ? '未命名目标' : item.displayName,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              _RiskBadge(
                label: riskLabel.isEmpty ? '待确认' : riskLabel,
                color: riskColor,
              ),
              if (item.confidence != null)
                Text(
                  '置信度 ${_formatConfidence(item.confidence)}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          if (item.advice.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              item.advice,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.55,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryPanel extends StatelessWidget {
  const _HistoryPanel({required this.history});

  final List<AiDetectionSummary> history;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = history.take(4).toList(growable: false);

    return FeatureInsetPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: 24,
      accentColor: AppPalette.linenOlive,
      shadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '最近记录',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '用于确认后端最近是否持续收到边缘 AI 上报。',
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.55,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            Text(
              '当前没有历史记录。',
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            )
          else
            Column(
              children: <Widget>[
                for (
                  int index = 0;
                  index < entries.length;
                  index++
                ) ...<Widget>[
                  _HistoryTile(entry: entries[index]),
                  if (index != entries.length - 1) const SizedBox(height: 10),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry});

  final AiDetectionSummary entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final riskLabel = _riskLabel(entry.overallRiskLevel);
    final riskColor = _riskColor(entry.overallRiskLevel);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppPalette.blendOnPaper(
          AppPalette.linenOlive,
          opacity: 0.12,
          base: colorScheme.surfaceContainerLowest,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppPalette.linenOlive.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text(
                _formatDateTime(entry.detectedAt),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              _RiskBadge(
                label: riskLabel.isEmpty ? '待确认' : riskLabel,
                color: riskColor,
              ),
              Text(
                '${entry.detectionCount} 个目标',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            entry.summary.isEmpty ? '后端未返回总结文案。' : entry.summary,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  const _MetaBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: AppPalette.blendOnPaper(
          AppPalette.softLavender,
          opacity: 0.12,
          base: colorScheme.surfaceContainerLowest,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppPalette.softLavender.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskBadge extends StatelessWidget {
  const _RiskBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

Color _riskColor(String rawValue) {
  switch (_riskLabel(rawValue)) {
    case '极高':
    case '高':
      return const Color(0xFFC45A43);
    case '中':
      return const Color(0xFFB57A12);
    case '低':
      return const Color(0xFF4E8B5A);
    case '健康':
      return const Color(0xFF2E7D32);
    default:
      return const Color(0xFF6B7280);
  }
}

String _riskLabel(String rawValue) {
  switch (rawValue.trim().toLowerCase()) {
    case 'extreme':
    case 'critical':
    case 'very_high':
    case 'very-high':
    case 'severe':
    case '极高':
      return '极高';
    case 'high':
    case 'alarm':
    case '高':
      return '高';
    case 'medium':
    case 'moderate':
    case 'mid':
    case '中':
      return '中';
    case 'low':
    case 'minor':
    case '低':
      return '低';
    case 'healthy':
    case 'normal':
    case 'safe':
    case 'ok':
    case '健康':
      return '健康';
    default:
      return rawValue.trim();
  }
}

String _sourceLabel(AiDetectionSummary summary) {
  final stream = summary.stream.trim();
  if (stream.isNotEmpty) {
    return stream.contains('画面') ? stream : '画面 $stream';
  }

  final deviceId = summary.deviceId.trim();
  if (deviceId.isNotEmpty) {
    return '设备 $deviceId';
  }

  return '来源未标记';
}

String _formatConfidence(double? value) {
  if (value == null) {
    return '--';
  }
  return '${(value * 100).toStringAsFixed(0)}%';
}

String _formatDateTime(DateTime? value) {
  if (value == null) {
    return '时间未知';
  }

  final localValue = value.toLocal();
  final month = localValue.month.toString().padLeft(2, '0');
  final day = localValue.day.toString().padLeft(2, '0');
  final hour = localValue.hour.toString().padLeft(2, '0');
  final minute = localValue.minute.toString().padLeft(2, '0');
  final second = localValue.second.toString().padLeft(2, '0');
  return '${localValue.year}-$month-$day $hour:$minute:$second';
}
