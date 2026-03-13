import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/features/video/video_stream_info.dart';
import 'package:sickandflutter/features/video/widgets/video_view_primitives.dart';
import 'package:sickandflutter/shared/widgets/feature_surface.dart';

/// 视频页顶部总览区。
class VideoIntroCard extends StatelessWidget {
  /// 创建视频页顶部总览区。
  const VideoIntroCard({required this.streams, super.key});

  /// 当前画面列表。
  final List<VideoStreamInfo> streams;

  @override
  Widget build(BuildContext context) {
    final onlineCount = streams.where((item) => item.available).length;
    final readyCount = streams
        .where((item) => item.hasPlayerUrl || item.hasGatewayPageUrl)
        .length;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FeatureHeroCard(
      padding: const EdgeInsets.all(28),
      borderRadius: 36,
      accentColor: AppPalette.softLavender,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final summaryBoard = Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              VideoIntroMetric(
                label: '画面数',
                value: streams.length.toString(),
                accentColor: AppPalette.softPine,
              ),
              VideoIntroMetric(
                label: '在线',
                value: onlineCount.toString(),
                accentColor: AppPalette.mistMint,
              ),
              VideoIntroMetric(
                label: '可查看',
                value: readyCount.toString(),
                accentColor: AppPalette.linenOlive,
              ),
            ],
          );

          final lead = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const VideoHeroTag(
                label: '在线画面',
                accentColor: AppPalette.softPine,
              ),
              const SizedBox(height: 18),
              Text(
                '先确认哪些画面可以直接查看',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '画面在线时可以直接打开；如果暂时打不开，再尝试备用入口。',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 18),
              FeatureInsetPanel(
                padding: const EdgeInsets.all(18),
                borderRadius: 26,
                accentColor: AppPalette.mistMint,
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _VideoLeadPoint(
                      icon: Icons.visibility_rounded,
                      title: '先看在线状态',
                      description: '在线后再决定是否直接打开，避免无效点击。',
                    ),
                    SizedBox(height: 14),
                    _VideoLeadPoint(
                      icon: Icons.open_in_new_rounded,
                      title: '备用入口后置',
                      description: '只有主入口打不开时，再尝试备用入口。',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              summaryBoard,
            ],
          );
          final monitor = VideoHeroMonitor(
            onlineCount: onlineCount,
            readyCount: readyCount,
          );

          if (constraints.maxWidth < 980) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[lead, const SizedBox(height: 20), monitor],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(flex: 10, child: lead),
              const SizedBox(width: 20),
              Expanded(flex: 8, child: monitor),
            ],
          );
        },
      ),
    );
  }
}

/// 视频页总览指标。
class VideoIntroMetric extends StatelessWidget {
  /// 创建视频页总览指标。
  const VideoIntroMetric({
    required this.label,
    required this.value,
    required this.accentColor,
    super.key,
  });

  /// 标题。
  final String label;

  /// 值文案。
  final String value;

  /// 强调色。
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 138),
      child: FeatureInsetPanel(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        borderRadius: 22,
        accentColor: accentColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 视频页顶部说明标签。
class VideoHeroTag extends StatelessWidget {
  /// 创建视频页顶部说明标签。
  const VideoHeroTag({
    required this.label,
    required this.accentColor,
    super.key,
  });

  /// 文案。
  final String label;

  /// 强调色。
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: colorScheme.onSurface),
      ),
    );
  }
}

/// 视频页监看舱位示意区。
class VideoHeroMonitor extends StatelessWidget {
  /// 创建视频页监看舱位示意区。
  const VideoHeroMonitor({
    required this.onlineCount,
    required this.readyCount,
    super.key,
  });

  /// 在线数量。
  final int onlineCount;

  /// 可查看数量。
  final int readyCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FeatureInsetPanel(
      padding: const EdgeInsets.all(20),
      borderRadius: 28,
      accentColor: AppPalette.softPine,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '查看摘要',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          FeatureInsetPanel(
            padding: const EdgeInsets.all(18),
            borderRadius: 24,
            accentColor: AppPalette.mistMint,
            child: Column(
              children: <Widget>[
                _VideoSummaryRow(label: '在线画面', value: '$onlineCount 路'),
                Divider(height: 26, color: colorScheme.outlineVariant),
                _VideoSummaryRow(label: '直接查看', value: '$readyCount 路'),
                Divider(height: 26, color: colorScheme.outlineVariant),
                _VideoSummaryRow(
                  label: '当前建议',
                  value: readyCount > 0 ? '先看在线画面' : '等待画面恢复',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: VideoInfoTile(label: '在线画面', value: '$onlineCount 路'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: VideoInfoTile(label: '直接查看', value: '$readyCount 路'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VideoSummaryRow extends StatelessWidget {
  const _VideoSummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: <Widget>[
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _VideoLeadPoint extends StatelessWidget {
  const _VideoLeadPoint({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppPalette.mistMint.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.52,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
