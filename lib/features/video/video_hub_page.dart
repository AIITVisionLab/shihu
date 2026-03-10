import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/app/app_workspace_destination.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/app/widgets/app_workspace_scaffold.dart';
import 'package:sickandflutter/core/config/video_service_endpoint.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/core/utils/external_link_launcher.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/video/video_stream_repository.dart';
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
    final serviceBaseUrl =
        ref.watch(videoServiceBaseUrlProvider).asData?.value ??
        AppConstants.defaultVideoBaseUrl;

    return AppWorkspaceScaffold(
      destination: AppWorkspaceDestination.video,
      title: AppCopy.videoPageTitle,
      subtitle: AppCopy.videoPageSubtitle,
      currentUser: currentUser,
      headerActions: <Widget>[
        OutlinedButton.icon(
          onPressed: () => _refresh(ref),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text(AppCopy.refresh),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: <Widget>[
          VideoHubOverviewCard(
            serviceBaseUrl: serviceBaseUrl,
            streams: streamsAsync.asData?.value ?? const <VideoStreamInfo>[],
          ),
          const SizedBox(height: 22),
          streamsAsync.when(
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
            ),
            data: (streams) {
              if (streams.isEmpty) {
                return CommonCard(
                  child: EmptyView(
                    title: AppCopy.videoEmptyTitle,
                    message: AppCopy.videoEmptyMessage,
                    actionLabel: AppCopy.refresh,
                    onAction: () => _refresh(ref),
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
                        onOpenPlayer: stream.hasPlayerUrl
                            ? () => _handleOpenUrl(
                                context,
                                url: stream.playerUrl,
                                copiedLabel: '播放地址',
                              )
                            : null,
                        onCopyPlayer: stream.hasPlayerUrl
                            ? () => _handleCopyUrl(
                                context,
                                url: stream.playerUrl,
                                copiedLabel: '播放地址',
                              )
                            : null,
                        onOpenGateway: stream.hasGatewayPageUrl
                            ? () => _handleOpenUrl(
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
                  VideoServiceEndpoint.resolveStreamsUrl(serviceBaseUrl),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _refresh(WidgetRef ref) {
    ref.invalidate(videoServiceBaseUrlProvider);
    ref.invalidate(videoStreamsProvider);
  }

  Future<void> _handleOpenUrl(
    BuildContext context, {
    required String url,
    required String copiedLabel,
  }) async {
    final opened = await openExternalUrl(url);
    if (!context.mounted) {
      return;
    }

    if (opened) {
      _showMessage(context, AppCopy.videoOpenedExternal);
      return;
    }

    await _handleCopyUrl(context, url: url, copiedLabel: copiedLabel);
  }

  Future<void> _handleCopyUrl(
    BuildContext context, {
    required String url,
    required String copiedLabel,
  }) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) {
      return;
    }
    _showMessage(context, AppCopy.videoCopied(copiedLabel));
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
