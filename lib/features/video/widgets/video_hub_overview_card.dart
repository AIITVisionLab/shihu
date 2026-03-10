import 'package:flutter/material.dart';
import 'package:sickandflutter/core/config/video_service_endpoint.dart';
import 'package:sickandflutter/shared/models/video_stream_info.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 视频中心顶部概览卡片。
class VideoHubOverviewCard extends StatelessWidget {
  /// 创建视频中心顶部概览卡片。
  const VideoHubOverviewCard({
    required this.serviceBaseUrl,
    required this.streams,
    super.key,
  });

  /// 当前视频服务基础地址。
  final String serviceBaseUrl;

  /// 当前已加载的视频流列表。
  final List<VideoStreamInfo> streams;

  @override
  Widget build(BuildContext context) {
    final totalCount = streams.length;
    final availableCount = streams.where((stream) => stream.available).length;
    final aiForwardedCount = streams
        .where((stream) => stream.aiResultForwarded)
        .length;
    final colorScheme = Theme.of(context).colorScheme;

    return CommonCard(
      title: '接入说明',
      subtitle: '把视频编排入口、播放模式和当前接入数量集中在同一个区域，方便值守时快速确认链路完整性。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              _MetricChip(label: '总流数', value: '$totalCount'),
              _MetricChip(label: '可用流', value: '$availableCount'),
              _MetricChip(label: '已转发 AI', value: '$aiForwardedCount'),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withValues(alpha: 0.52),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Text(
              '视频流信息由 Java 服务下发，客户端只消费流元数据并打开外部播放地址，媒体字节流仍直接走网关链路。',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            '服务地址',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          SelectableText(
            VideoServiceEndpoint.resolveStreamsUrl(serviceBaseUrl),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(minWidth: 120),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.56),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
