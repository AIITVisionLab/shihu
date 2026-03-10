import 'package:flutter/material.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/shared/models/video_stream_info.dart';
import 'package:sickandflutter/shared/widgets/common_button.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';
import 'package:sickandflutter/shared/widgets/responsive_info_row.dart';

/// 视频流概览卡片。
class VideoStreamCard extends StatelessWidget {
  /// 创建视频流概览卡片。
  const VideoStreamCard({
    required this.stream,
    required this.onOpenPlayer,
    required this.onCopyPlayer,
    required this.onOpenGateway,
    required this.onOpenDetail,
    super.key,
  });

  /// 当前视频流。
  final VideoStreamInfo stream;

  /// 打开播放链接回调。
  final VoidCallback? onOpenPlayer;

  /// 复制播放链接回调。
  final VoidCallback? onCopyPlayer;

  /// 打开网关页回调。
  final VoidCallback? onOpenGateway;

  /// 打开详情回调。
  final VoidCallback onOpenDetail;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CommonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Text(
                stream.resolvedDisplayName,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              _StatusChip(
                label: stream.available ? '在线' : '待就绪',
                backgroundColor: stream.available
                    ? const Color(0xFFE8F7EB)
                    : const Color(0xFFF6EDE2),
                foregroundColor: stream.available
                    ? const Color(0xFF166534)
                    : const Color(0xFF9A6700),
              ),
              _StatusChip(
                label: stream.aiResultForwarded ? 'AI 已转发' : 'AI 未转发',
                backgroundColor: colorScheme.secondaryContainer.withValues(
                  alpha: 0.66,
                ),
                foregroundColor: colorScheme.onSecondaryContainer,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ResponsiveInfoRow(label: '流标识', value: stream.streamId),
          const SizedBox(height: 12),
          ResponsiveInfoRow(label: '设备标识', value: stream.deviceId),
          const SizedBox(height: 12),
          ResponsiveInfoRow(label: '播放模式', value: stream.playbackModeLabel),
          const SizedBox(height: 12),
          ResponsiveInfoRow(label: '公网端点', value: stream.publicEndpointLabel),
          const SizedBox(height: 16),
          Text(
            stream.hasPlayerUrl ? stream.playerUrl : '后端未返回播放地址。',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              CommonButton(
                label: AppCopy.videoOpenDetail,
                icon: const Icon(Icons.read_more_rounded),
                onPressed: onOpenDetail,
              ),
              CommonButton(
                label: AppCopy.videoOpenPlayer,
                tone: CommonButtonTone.secondary,
                icon: const Icon(Icons.open_in_new_rounded),
                onPressed: onOpenPlayer,
              ),
              CommonButton(
                label: AppCopy.videoCopyPlayer,
                tone: CommonButtonTone.secondary,
                icon: const Icon(Icons.content_copy_rounded),
                onPressed: onCopyPlayer,
              ),
              if (stream.hasGatewayPageUrl)
                CommonButton(
                  label: AppCopy.videoOpenGateway,
                  tone: CommonButtonTone.secondary,
                  icon: const Icon(Icons.hub_outlined),
                  onPressed: onOpenGateway,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: foregroundColor),
      ),
    );
  }
}
