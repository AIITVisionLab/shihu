import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/features/video/video_playback_page.dart';
import 'package:sickandflutter/features/video/video_stream_info.dart';
import 'package:sickandflutter/features/video/widgets/video_view_primitives.dart';
import 'package:sickandflutter/shared/widgets/feature_surface.dart';

/// 视频页其它画面入口区。
class VideoGallery extends StatelessWidget {
  /// 创建其它画面入口区。
  const VideoGallery({required this.streams, super.key});

  /// 当前画面列表。
  final List<VideoStreamInfo> streams;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '其它画面',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '其它流收成紧凑入口，需要切换时再打开，不再重复堆整张大卡。',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.56,
          ),
        ),
        const SizedBox(height: 14),
        Column(
          children: <Widget>[
            for (int index = 0; index < streams.length; index++) ...<Widget>[
              _VideoGalleryRow(stream: streams[index]),
              if (index != streams.length - 1) const SizedBox(height: 12),
            ],
          ],
        ),
      ],
    );
  }
}

class _VideoGalleryRow extends StatelessWidget {
  const _VideoGalleryRow({required this.stream});

  final VideoStreamInfo stream;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryUrl = stream.hasPlayerUrl
        ? stream.playerUrl
        : stream.gatewayPageUrl;
    final hasPrimaryAction = primaryUrl.trim().isNotEmpty;
    final hasSecondaryAction =
        stream.hasPlayerUrl &&
        stream.hasGatewayPageUrl &&
        stream.gatewayPageUrl != stream.playerUrl;

    return FeatureInsetPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: 22,
      accentColor: AppPalette.linenOlive,
      shadow: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final detailBlock = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppPalette.blendOnPaper(
                        AppPalette.linenOlive,
                        opacity: 0.14,
                        base: colorScheme.surfaceContainerLowest,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppPalette.linenOlive.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Icon(
                      Icons.videocam_outlined,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          stream.displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _buildDescription(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  VideoStatusChip(
                    label: stream.available ? '在线' : '离线',
                    tone: stream.available
                        ? VideoStatusChipTone.active
                        : VideoStatusChipTone.muted,
                  ),
                  VideoStatusChip(
                    label: _modeLabel(),
                    tone: VideoStatusChipTone.secondary,
                  ),
                  VideoStatusChip(
                    label: hasPrimaryAction ? '可查看' : '待恢复',
                    tone: hasPrimaryAction
                        ? VideoStatusChipTone.info
                        : VideoStatusChipTone.muted,
                  ),
                  VideoStatusChip(
                    label: stream.aiResultForwarded ? 'AI 已联动' : 'AI 待联动',
                    tone: stream.aiResultForwarded
                        ? VideoStatusChipTone.info
                        : VideoStatusChipTone.muted,
                  ),
                ],
              ),
            ],
          );
          final actions = Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.end,
            children: <Widget>[
              FilledButton.tonalIcon(
                onPressed: hasPrimaryAction
                    ? () => _openPlayer(
                        context,
                        title: stream.displayName,
                        url: primaryUrl,
                        streamId: stream.streamId,
                        gatewayPageUrl: stream.gatewayPageUrl,
                        sourceLabel: stream.hasPlayerUrl ? '主画面' : '备用入口',
                      )
                    : null,
                icon: const Icon(Icons.play_circle_outline_rounded),
                label: const Text('打开'),
              ),
              if (hasSecondaryAction)
                OutlinedButton.icon(
                  onPressed: () => _openPlayer(
                    context,
                    title: stream.displayName,
                    url: stream.gatewayPageUrl,
                    streamId: stream.streamId,
                    gatewayPageUrl: stream.gatewayPageUrl,
                    sourceLabel: '备用入口',
                  ),
                  icon: const Icon(Icons.open_in_new_rounded),
                  label: const Text('备用入口'),
                ),
            ],
          );

          if (constraints.maxWidth < 760) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                detailBlock,
                const SizedBox(height: 14),
                actions,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: detailBlock),
              const SizedBox(width: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 240),
                child: Align(alignment: Alignment.topRight, child: actions),
              ),
            ],
          );
        },
      ),
    );
  }

  String _buildDescription() {
    if (stream.aiResultForwarded && stream.available) {
      return '这一路画面在线，而且后端最近已收到对应 AI 结果，切过来就能直接复核。';
    }
    if (!stream.available) {
      return '当前暂未连通，恢复后再切换查看。';
    }
    if (!stream.hasPlayerUrl && !stream.hasGatewayPageUrl) {
      return '画面在线，但打开入口还没准备好。';
    }
    return '需要切换视角时再打开，不打断当前主画面。';
  }

  String _modeLabel() {
    final summary = stream.modeSummary.toLowerCase();
    if (summary.contains('webrtc')) {
      return '实时优先';
    }
    if (summary.contains('mse')) {
      return '标准模式';
    }
    return '自动选择';
  }

  Future<void> _openPlayer(
    BuildContext context, {
    required String title,
    required String url,
    required String streamId,
    required String gatewayPageUrl,
    required String sourceLabel,
  }) async {
    if (!context.mounted) {
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => VideoPlaybackPage(
          title: title,
          initialUrl: url,
          streamId: streamId,
          gatewayPageUrl: gatewayPageUrl,
          sourceLabel: sourceLabel,
        ),
      ),
    );
  }
}
