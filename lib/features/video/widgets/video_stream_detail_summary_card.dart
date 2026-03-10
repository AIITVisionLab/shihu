import 'package:flutter/material.dart';
import 'package:sickandflutter/features/video/widgets/video_stream_status_chip.dart';
import 'package:sickandflutter/shared/models/video_stream_info.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';
import 'package:sickandflutter/shared/widgets/responsive_info_row.dart';

/// 单路视频流详情摘要卡片。
class VideoStreamDetailSummaryCard extends StatelessWidget {
  /// 创建单路视频流详情摘要卡片。
  const VideoStreamDetailSummaryCard({required this.stream, super.key});

  /// 当前视频流详情。
  final VideoStreamInfo stream;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CommonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            stream.resolvedDisplayName,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            stream.available ? '当前视频流可用。' : '当前视频流未就绪，请等待服务恢复或检查网关状态。',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              VideoStreamStatusChip(
                label: stream.available ? '当前在线' : '待就绪',
                icon: stream.available
                    ? Icons.play_circle_outline_rounded
                    : Icons.pause_circle_outline_rounded,
                backgroundColor: stream.available
                    ? const Color(0xFFE8F7EB)
                    : const Color(0xFFF6EDE2),
                foregroundColor: stream.available
                    ? const Color(0xFF166534)
                    : const Color(0xFF9A6700),
              ),
              VideoStreamStatusChip(
                label: stream.aiResultForwarded ? 'AI 已转发' : 'AI 未转发',
                icon: stream.aiResultForwarded
                    ? Icons.memory_rounded
                    : Icons.memory_outlined,
                backgroundColor: colorScheme.secondaryContainer.withValues(
                  alpha: 0.66,
                ),
                foregroundColor: colorScheme.onSecondaryContainer,
              ),
              VideoStreamStatusChip(
                label: stream.hasPlayerUrl ? '可直接打开播放页' : '缺少播放地址',
                icon: stream.hasPlayerUrl
                    ? Icons.link_rounded
                    : Icons.link_off_rounded,
                backgroundColor: colorScheme.tertiaryContainer.withValues(
                  alpha: 0.64,
                ),
                foregroundColor: colorScheme.onTertiaryContainer,
              ),
            ],
          ),
          const SizedBox(height: 18),
          ResponsiveInfoRow(label: '流标识', value: stream.streamId),
          const SizedBox(height: 12),
          ResponsiveInfoRow(label: '设备标识', value: stream.deviceId),
          const SizedBox(height: 12),
          ResponsiveInfoRow(
            label: 'AI 转发',
            value: stream.aiResultForwarded ? '已开启' : '未开启',
          ),
          const SizedBox(height: 12),
          ResponsiveInfoRow(label: '播放模式', value: stream.playbackModeLabel),
          const SizedBox(height: 12),
          ResponsiveInfoRow(label: '公网端点', value: stream.publicEndpointLabel),
        ],
      ),
    );
  }
}
