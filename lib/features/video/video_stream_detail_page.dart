import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/app/app_workspace_destination.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/app/widgets/app_workspace_scaffold.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/video/video_link_action_handler.dart';
import 'package:sickandflutter/features/video/video_stream_repository.dart';
import 'package:sickandflutter/features/video/widgets/video_service_error_card.dart';
import 'package:sickandflutter/features/video/widgets/video_stream_actions_card.dart';
import 'package:sickandflutter/features/video/widgets/video_stream_detail_summary_card.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';
import 'package:sickandflutter/shared/widgets/loading_view.dart';

/// 单路视频流详情页面。
class VideoStreamDetailPage extends ConsumerWidget {
  /// 创建单路视频流详情页面。
  const VideoStreamDetailPage({required this.streamId, super.key});

  /// 当前路由携带的视频流标识。
  final String streamId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final currentUser =
        authState.session?.user.displayName ??
        authState.session?.user.account ??
        '--';
    final detailAsync = ref.watch(videoStreamDetailProvider(streamId));
    final serviceBaseUrl =
        ref.watch(videoServiceBaseUrlProvider).asData?.value ??
        AppConstants.defaultVideoBaseUrl;

    return AppWorkspaceScaffold(
      destination: AppWorkspaceDestination.video,
      title: AppCopy.videoDetailPageTitle,
      subtitle: '查看单路视频流的播放地址、网关入口和 AI 转发状态。',
      currentUser: currentUser,
      backgroundGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color(0xFFF1F0E7),
          Color(0xFFF6F3EC),
          Color(0xFFEAE4D8),
        ],
      ),
      headerActions: <Widget>[
        OutlinedButton.icon(
          onPressed: () => context.goNamed(AppRoutes.video),
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text(AppCopy.videoBackToHub),
        ),
        OutlinedButton.icon(
          onPressed: () => ref.invalidate(videoStreamDetailProvider(streamId)),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text(AppCopy.refresh),
        ),
      ],
      child: detailAsync.when(
        loading: () => const Center(
          child: CommonCard(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 36),
              child: LoadingView(message: AppCopy.videoDetailLoading),
            ),
          ),
        ),
        error: (error, stackTrace) => Center(
          child: VideoServiceErrorCard(
            serviceBaseUrl: serviceBaseUrl,
            error: error,
            onRetry: () => ref.invalidate(videoStreamDetailProvider(streamId)),
            onCopyServiceUrl: () => VideoLinkActionHandler.copyServiceUrl(
              context,
              serviceUrl:
                  '$serviceBaseUrl/api/video/streams/${Uri.encodeComponent(streamId)}',
            ),
          ),
        ),
        data: (stream) => RefreshIndicator(
          onRefresh: () async =>
              ref.invalidate(videoStreamDetailProvider(streamId)),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            children: <Widget>[
              VideoStreamDetailSummaryCard(stream: stream),
              const SizedBox(height: 20),
              VideoStreamActionsCard(
                stream: stream,
                onOpenPlayer: stream.hasPlayerUrl
                    ? () => VideoLinkActionHandler.openOrCopy(
                        context,
                        url: stream.playerUrl,
                        copiedLabel: '播放地址',
                      )
                    : null,
                onCopyPlayer: stream.hasPlayerUrl
                    ? () => VideoLinkActionHandler.copy(
                        context,
                        url: stream.playerUrl,
                        copiedLabel: '播放地址',
                      )
                    : null,
                onOpenGateway: stream.hasGatewayPageUrl
                    ? () => VideoLinkActionHandler.openOrCopy(
                        context,
                        url: stream.gatewayPageUrl,
                        copiedLabel: '网关地址',
                      )
                    : null,
                onCopyGateway: stream.hasGatewayPageUrl
                    ? () => VideoLinkActionHandler.copy(
                        context,
                        url: stream.gatewayPageUrl,
                        copiedLabel: '网关地址',
                      )
                    : null,
              ),
              const SizedBox(height: 20),
              const CommonCard(
                title: 'AI 协作边界',
                subtitle: '客户端当前不直接读取边缘侧 AI JSON。',
                child: Text(
                  '如果需要在客户端展示检测结果，应由 Java 服务先接收 `/api/edge/ai-detections` 上送结果，再提供新的查询接口或推送接口。',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
