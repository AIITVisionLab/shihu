import 'package:flutter/material.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/shared/widgets/common_button.dart';

/// 视频中心主视觉概览卡片。
class VideoHubHeroCard extends StatelessWidget {
  /// 创建视频中心主视觉概览卡片。
  const VideoHubHeroCard({
    required this.serviceLabel,
    required this.totalCount,
    required this.availableCount,
    required this.aiForwardedCount,
    required this.onRefresh,
    required this.onCopyServiceUrl,
    super.key,
  });

  /// 当前接口地址标签。
  final String serviceLabel;

  /// 总视频流数量。
  final int totalCount;

  /// 在线视频流数量。
  final int availableCount;

  /// 已开启 AI 转发的视频流数量。
  final int aiForwardedCount;

  /// 刷新回调。
  final VoidCallback onRefresh;

  /// 复制服务地址回调。
  final VoidCallback onCopyServiceUrl;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF173629),
            Color(0xFF245043),
            Color(0xFFB8894C),
          ],
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x2614291E),
            blurRadius: 44,
            offset: Offset(0, 22),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 860;
          final summary = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: const <Widget>[
                  _HeroPill(label: AppCopy.videoHeroBadge),
                  _HeroPill(label: '媒体直连网关'),
                  _HeroPill(label: '外部播放入口'),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                AppCopy.videoPageTitle,
                style: textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                AppCopy.videoHeroDescription,
                style: textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFFF2F5F0),
                  height: 1.72,
                ),
              ),
              const SizedBox(height: 22),
              SelectableText(
                serviceLabel,
                style: textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFE5ECE0),
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  CommonButton(
                    label: AppCopy.refresh,
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: onRefresh,
                  ),
                  CommonButton(
                    label: AppCopy.videoCopyServiceUrl,
                    tone: CommonButtonTone.secondary,
                    icon: const Icon(Icons.content_copy_rounded),
                    onPressed: onCopyServiceUrl,
                  ),
                ],
              ),
            ],
          );
          final stats = _HeroStats(
            totalCount: totalCount,
            availableCount: availableCount,
            aiForwardedCount: aiForwardedCount,
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[summary, const SizedBox(height: 22), stats],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(flex: 9, child: summary),
              const SizedBox(width: 24),
              Expanded(flex: 5, child: stats),
            ],
          );
        },
      ),
    );
  }
}

class _HeroStats extends StatelessWidget {
  const _HeroStats({
    required this.totalCount,
    required this.availableCount,
    required this.aiForwardedCount,
  });

  final int totalCount;
  final int availableCount;
  final int aiForwardedCount;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '接入摘要',
            style: textTheme.labelLarge?.copyWith(
              color: const Color(0xFFE6EEE0),
            ),
          ),
          const SizedBox(height: 18),
          _HeroStatRow(label: '全部流', value: '$totalCount'),
          const SizedBox(height: 12),
          _HeroStatRow(label: '当前在线', value: '$availableCount'),
          const SizedBox(height: 12),
          _HeroStatRow(label: 'AI 已转发', value: '$aiForwardedCount'),
        ],
      ),
    );
  }
}

class _HeroStatRow extends StatelessWidget {
  const _HeroStatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFE2E8DE),
            ),
          ),
        ),
        Text(
          value,
          style: textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: Colors.white),
      ),
    );
  }
}
