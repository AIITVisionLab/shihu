import 'package:flutter/material.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/shared/models/video_stream_info.dart';
import 'package:sickandflutter/shared/widgets/common_button.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';
import 'package:sickandflutter/shared/widgets/responsive_info_row.dart';

/// 单路视频流操作卡片。
class VideoStreamActionsCard extends StatelessWidget {
  /// 创建单路视频流操作卡片。
  const VideoStreamActionsCard({
    required this.stream,
    required this.onOpenPlayer,
    required this.onCopyPlayer,
    required this.onOpenGateway,
    required this.onCopyGateway,
    super.key,
  });

  /// 当前视频流详情。
  final VideoStreamInfo stream;

  /// 打开播放页回调。
  final VoidCallback? onOpenPlayer;

  /// 复制播放页回调。
  final VoidCallback? onCopyPlayer;

  /// 打开网关页回调。
  final VoidCallback? onOpenGateway;

  /// 复制网关页回调。
  final VoidCallback? onCopyGateway;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: '访问入口',
      subtitle: '客户端只使用 Java 服务下发的地址，不直接拼接内网媒体地址。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ResponsiveInfoRow(
            label: '播放地址',
            value: stream.playerUrl.isEmpty ? '未返回' : stream.playerUrl,
          ),
          const SizedBox(height: 12),
          ResponsiveInfoRow(
            label: '网关地址',
            value: stream.gatewayPageUrl.isEmpty
                ? '未返回'
                : stream.gatewayPageUrl,
          ),
          const SizedBox(height: 12),
          ResponsiveInfoRow(label: '公网端点', value: stream.publicEndpointLabel),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: <Widget>[
              CommonButton(
                label: AppCopy.videoOpenPlayer,
                icon: const Icon(Icons.open_in_new_rounded),
                onPressed: onOpenPlayer,
              ),
              CommonButton(
                label: AppCopy.videoCopyPlayer,
                tone: CommonButtonTone.secondary,
                icon: const Icon(Icons.content_copy_rounded),
                onPressed: onCopyPlayer,
              ),
              CommonButton(
                label: AppCopy.videoOpenGateway,
                tone: CommonButtonTone.secondary,
                icon: const Icon(Icons.hub_outlined),
                onPressed: onOpenGateway,
              ),
              CommonButton(
                label: AppCopy.videoCopyGateway,
                tone: CommonButtonTone.secondary,
                icon: const Icon(Icons.link_rounded),
                onPressed: onCopyGateway,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
