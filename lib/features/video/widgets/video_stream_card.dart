import 'package:flutter/material.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/features/video/widgets/video_stream_status_chip.dart';
import 'package:sickandflutter/shared/models/video_stream_info.dart';
import 'package:sickandflutter/shared/widgets/common_button.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';
import 'package:sickandflutter/shared/widgets/responsive_info_row.dart';

/// 视频流概览卡片。
class VideoStreamCard extends StatelessWidget {
  /// 创建视频流概览卡片。
  const VideoStreamCard({
    required this.stream,
    required this.onTap,
    required this.onOpenPlayer,
    required this.onCopyPlayer,
    required this.onOpenGateway,
    required this.onOpenDetail,
    super.key,
  });

  /// 当前视频流。
  final VideoStreamInfo stream;

  /// 点击整卡回调。
  final VoidCallback onTap;

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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: CommonCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    colors: <Color>[colorScheme.primary, colorScheme.secondary],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          stream.resolvedDisplayName,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          stream.hasPlayerUrl
                              ? '优先使用 ${stream.playbackModeLabel} 打开外部播放页。'
                              : '当前后端尚未返回播放地址，请先检查视频服务。',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.72,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 20,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  VideoStreamStatusChip(
                    label: stream.available ? '在线' : '待就绪',
                    icon: stream.available
                        ? Icons.check_circle_outline_rounded
                        : Icons.schedule_rounded,
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
                ],
              ),
              const SizedBox(height: 16),
              ResponsiveInfoRow(label: '流标识', value: stream.streamId),
              const SizedBox(height: 12),
              ResponsiveInfoRow(label: '设备标识', value: stream.deviceId),
              const SizedBox(height: 12),
              ResponsiveInfoRow(label: '播放模式', value: stream.playbackModeLabel),
              const SizedBox(height: 12),
              ResponsiveInfoRow(
                label: '公网端点',
                value: stream.publicEndpointLabel,
              ),
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
        ),
      ),
    );
  }
}
