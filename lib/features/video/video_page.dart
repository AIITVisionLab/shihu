import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/app/app_workspace_destination.dart';
import 'package:sickandflutter/app/widgets/app_workspace_scaffold.dart';
import 'package:sickandflutter/features/auth/application/current_user_label_provider.dart';
import 'package:sickandflutter/features/preview/preview_workspace_seed.dart';
import 'package:sickandflutter/features/video/video_stream_info.dart';
import 'package:sickandflutter/features/video/video_stream_repository.dart';
import 'package:sickandflutter/features/video/widgets/video_feedback_cards.dart';
import 'package:sickandflutter/features/video/widgets/video_gallery.dart';
import 'package:sickandflutter/features/video/widgets/video_primary_focus_card.dart';
import 'package:sickandflutter/shared/widgets/loading_view.dart';

/// 视频中心，负责展示当前可查看的实时画面。
class VideoPage extends ConsumerWidget {
  /// 创建视频中心。
  const VideoPage({this.enableInlinePlayback = true, super.key});

  /// 是否在主画面卡片里直接启用内联播放。
  final bool enableInlinePlayback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streamListAsync = ref.watch(videoStreamListProvider);
    final currentUser = ref.watch(currentUserLabelProvider);
    final previewWorkspaceEnabled = ref.watch(previewWorkspaceEnabledProvider);

    return AppWorkspaceScaffold(
      destination: AppWorkspaceDestination.video,
      title: '视频中心',
      subtitle: '查看当前画面是否在线，必要时直接在软件内观看。',
      currentUser: currentUser,
      backgroundGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[
          AppPalette.paperSnow,
          AppPalette.paperMist,
          AppPalette.paper,
        ],
      ),
      headerActions: <Widget>[
        FilledButton.tonalIcon(
          onPressed: () => _refresh(ref),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('刷新画面'),
        ),
      ],
      child: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: resolveWorkspacePagePadding(context),
          children: streamListAsync.when(
            loading: () => const <Widget>[
              SizedBox(height: 120),
              LoadingView(message: '正在加载画面...'),
            ],
            error: (error, stackTrace) => <Widget>[
              const SizedBox(height: 18),
              VideoErrorCard(onRetry: () => _refresh(ref)),
            ],
            data: (streams) => <Widget>[
              if (streams.isEmpty)
                VideoEmptyCard(onRetry: () => _refresh(ref))
              else
                ..._buildStreamCards(
                  streams,
                  previewWorkspaceEnabled: previewWorkspaceEnabled,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(videoStreamListProvider);
    await ref.read(videoStreamListProvider.future);
  }

  List<Widget> _buildStreamCards(
    List<VideoStreamInfo> streams, {
    bool previewWorkspaceEnabled = false,
  }) {
    final primaryStream = _selectPrimaryStream(streams);
    final secondaryStreams = streams
        .where((stream) => stream.streamId != primaryStream.streamId)
        .toList(growable: false);
    final onlineCount = streams.where((item) => item.available).length;
    final readyCount = streams
        .where((item) => item.hasPlayerUrl || item.hasGatewayPageUrl)
        .length;

    return <Widget>[
      VideoPrimaryFocusCard(
        stream: primaryStream,
        totalCount: streams.length,
        onlineCount: onlineCount,
        readyCount: readyCount,
        enableInlinePlayback: enableInlinePlayback && !previewWorkspaceEnabled,
      ),
      if (secondaryStreams.isNotEmpty) ...<Widget>[
        const SizedBox(height: 18),
        VideoGallery(streams: secondaryStreams),
      ],
    ];
  }

  VideoStreamInfo _selectPrimaryStream(List<VideoStreamInfo> streams) {
    return streams.firstWhere(
      (stream) =>
          stream.available && (stream.hasPlayerUrl || stream.hasGatewayPageUrl),
      orElse: () => streams.first,
    );
  }
}
