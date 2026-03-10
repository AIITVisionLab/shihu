import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/app/app_workspace_destination.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/app/widgets/app_workspace_scaffold.dart';
import 'package:sickandflutter/core/config/video_service_endpoint.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/video/video_hub_query_controller.dart';
import 'package:sickandflutter/features/video/video_link_action_handler.dart';
import 'package:sickandflutter/features/video/video_stream_repository.dart';
import 'package:sickandflutter/features/video/widgets/video_hub_filter_bar.dart';
import 'package:sickandflutter/features/video/widgets/video_hub_hero_card.dart';
import 'package:sickandflutter/features/video/widgets/video_hub_overview_card.dart';
import 'package:sickandflutter/features/video/widgets/video_service_error_card.dart';
import 'package:sickandflutter/features/video/widgets/video_stream_card.dart';
import 'package:sickandflutter/shared/models/video_stream_info.dart';
import 'package:sickandflutter/shared/widgets/adaptive_wrap_grid.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';
import 'package:sickandflutter/shared/widgets/empty_view.dart';
import 'package:sickandflutter/shared/widgets/loading_view.dart';

/// 视频中心页面。
class VideoHubPage extends ConsumerWidget {
  /// 创建视频中心页面。
  const VideoHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final currentUser =
        authState.session?.user.displayName ??
        authState.session?.user.account ??
        '--';
    final streamsAsync = ref.watch(videoStreamsProvider);
    final filteredStreamsAsync = ref.watch(filteredVideoStreamsProvider);
    final queryState = ref.watch(videoHubQueryControllerProvider);
    final serviceBaseUrl =
        ref.watch(videoServiceBaseUrlProvider).asData?.value ??
        AppConstants.defaultVideoBaseUrl;
    final serviceStreamsUrl = VideoServiceEndpoint.resolveStreamsUrl(
      serviceBaseUrl,
    );
    final totalStreams =
        streamsAsync.asData?.value ?? const <VideoStreamInfo>[];
    final visibleStreams =
        filteredStreamsAsync.asData?.value ?? const <VideoStreamInfo>[];

    return AppWorkspaceScaffold(
      destination: AppWorkspaceDestination.video,
      title: AppCopy.videoPageTitle,
      subtitle: AppCopy.videoPageSubtitle,
      currentUser: currentUser,
      backgroundGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          Color(0xFFF0EEE5),
          Color(0xFFF2F3EC),
          Color(0xFFEAE3D7),
        ],
      ),
      child: RefreshIndicator(
        onRefresh: () async => _refresh(ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: <Widget>[
            VideoHubHeroCard(
              serviceLabel: serviceStreamsUrl,
              totalCount: totalStreams.length,
              availableCount: totalStreams
                  .where((stream) => stream.available)
                  .length,
              aiForwardedCount: totalStreams
                  .where((stream) => stream.aiResultForwarded)
                  .length,
              onRefresh: () => _refresh(ref),
              onCopyServiceUrl: () => VideoLinkActionHandler.copyServiceUrl(
                context,
                serviceUrl: serviceStreamsUrl,
              ),
            ),
            const SizedBox(height: 22),
            VideoHubFilterBar(
              queryState: queryState,
              visibleCount: visibleStreams.length,
              totalCount: totalStreams.length,
              onKeywordChanged: (value) => ref
                  .read(videoHubQueryControllerProvider.notifier)
                  .setKeyword(value),
              onClearKeyword: () => ref
                  .read(videoHubQueryControllerProvider.notifier)
                  .clearKeyword(),
              onFilterChanged: (filter) => ref
                  .read(videoHubQueryControllerProvider.notifier)
                  .setFilter(filter),
            ),
            const SizedBox(height: 22),
            VideoHubOverviewCard(
              serviceBaseUrl: serviceBaseUrl,
              streams: totalStreams,
            ),
            const SizedBox(height: 22),
            filteredStreamsAsync.when(
              loading: () => const CommonCard(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 36),
                  child: LoadingView(message: AppCopy.videoLoading),
                ),
              ),
              error: (error, stackTrace) => VideoServiceErrorCard(
                serviceBaseUrl: serviceBaseUrl,
                error: error,
                onRetry: () => _refresh(ref),
                onCopyServiceUrl: () => VideoLinkActionHandler.copyServiceUrl(
                  context,
                  serviceUrl: serviceStreamsUrl,
                ),
              ),
              data: (streams) {
                if (totalStreams.isEmpty) {
                  return CommonCard(
                    child: EmptyView(
                      title: AppCopy.videoEmptyTitle,
                      message: AppCopy.videoEmptyMessage,
                      actionLabel: AppCopy.refresh,
                      onAction: () => _refresh(ref),
                    ),
                  );
                }

                if (streams.isEmpty) {
                  return CommonCard(
                    child: EmptyView(
                      title: AppCopy.videoFilteredEmptyTitle,
                      message: AppCopy.videoFilteredEmptyMessage,
                      actionLabel: AppCopy.videoFilterAll,
                      onAction: () => ref
                          .read(videoHubQueryControllerProvider.notifier)
                          .reset(),
                    ),
                  );
                }

                return AdaptiveWrapGrid(
                  minItemWidth: 320,
                  spacing: 16,
                  runSpacing: 16,
                  children: streams
                      .map(
                        (stream) => VideoStreamCard(
                          stream: stream,
                          onTap: () => context.pushNamed(
                            AppRoutes.videoStreamDetail,
                            pathParameters: <String, String>{
                              'streamId': stream.streamId,
                            },
                          ),
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
                          onOpenDetail: () => context.pushNamed(
                            AppRoutes.videoStreamDetail,
                            pathParameters: <String, String>{
                              'streamId': stream.streamId,
                            },
                          ),
                        ),
                      )
                      .toList(growable: false),
                );
              },
            ),
            const SizedBox(height: 22),
            CommonCard(
              title: '协作约束',
              subtitle: '这一轮只接视频元数据与播放地址，不在客户端直接拉取 RK3568 的 AI JSON。',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'AI 结果如果需要在客户端展示，应由 Java 服务先接收、落库或缓存后再下发查询接口。当前页面只展示 `aiResultForwarded` 这类后端摘要字段。',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    serviceStreamsUrl,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _refresh(WidgetRef ref) {
    ref.invalidate(videoServiceBaseUrlProvider);
    ref.invalidate(videoStreamsProvider);
    ref.invalidate(filteredVideoStreamsProvider);
  }
}
