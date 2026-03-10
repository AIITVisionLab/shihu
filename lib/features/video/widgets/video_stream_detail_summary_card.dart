import 'package:flutter/material.dart';
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
        ],
      ),
    );
  }
}
