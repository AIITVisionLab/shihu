import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/features/video/video_playback_page.dart';
import 'package:sickandflutter/features/video/video_stream_info.dart';
import 'package:sickandflutter/features/video/widgets/video_inline_playback_stage.dart';
import 'package:sickandflutter/features/video/widgets/video_stream_card.dart';
import 'package:sickandflutter/features/video/widgets/video_view_primitives.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';
import 'package:sickandflutter/shared/widgets/workspace_layout.dart';

/// 视频页主画面聚焦卡片。
class VideoPrimaryFocusCard extends StatelessWidget {
  /// 创建主画面聚焦卡片。
  const VideoPrimaryFocusCard({
    required this.stream,
    required this.totalCount,
    required this.onlineCount,
    required this.readyCount,
    this.enableInlinePlayback = true,
    super.key,
  });

  /// 当前主画面。
  final VideoStreamInfo stream;

  /// 当前总画面数。
  final int totalCount;

  /// 当前在线画面数。
  final int onlineCount;

  /// 当前可查看画面数。
  final int readyCount;

  /// 是否在主画面卡片里直接启用内联播放。
  final bool enableInlinePlayback;

  @override
  Widget build(BuildContext context) {
    final primaryUrl = stream.hasPlayerUrl
        ? stream.playerUrl
        : stream.gatewayPageUrl;
    final hasPrimaryAction = primaryUrl.trim().isNotEmpty;
    final hasSecondaryAction =
        stream.hasPlayerUrl &&
        stream.hasGatewayPageUrl &&
        stream.gatewayPageUrl != stream.playerUrl;

    return CommonCard(
      accentColor: AppPalette.linenOlive,
      child: WorkspaceTwoPane(
        breakpoint: 1080,
        gap: 18,
        primary: enableInlinePlayback
            ? VideoInlinePlaybackStage(stream: stream)
            : VideoScreenStage(
                stream: stream,
                hasPrimaryAction: hasPrimaryAction,
              ),
        secondary: _VideoPrimaryControlPanel(
          stream: stream,
          totalCount: totalCount,
          onlineCount: onlineCount,
          readyCount: readyCount,
          hasPrimaryAction: hasPrimaryAction,
          hasSecondaryAction: hasSecondaryAction,
          onOpenPrimary: hasPrimaryAction
              ? () => _openPlayer(
                  context,
                  title: stream.displayName,
                  url: primaryUrl,
                  sourceLabel: stream.hasPlayerUrl ? '主画面' : '备用入口',
                )
              : null,
          onOpenSecondary: hasSecondaryAction
              ? () => _openPlayer(
                  context,
                  title: stream.displayName,
                  url: stream.gatewayPageUrl,
                  sourceLabel: '备用入口',
                )
              : null,
        ),
      ),
    );
  }

  Future<void> _openPlayer(
    BuildContext context, {
    required String title,
    required String url,
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
          streamId: stream.streamId,
          gatewayPageUrl: stream.gatewayPageUrl,
          sourceLabel: sourceLabel,
        ),
      ),
    );
  }
}

class _VideoPrimaryControlPanel extends StatelessWidget {
  const _VideoPrimaryControlPanel({
    required this.stream,
    required this.totalCount,
    required this.onlineCount,
    required this.readyCount,
    required this.hasPrimaryAction,
    required this.hasSecondaryAction,
    required this.onOpenPrimary,
    required this.onOpenSecondary,
  });

  final VideoStreamInfo stream;
  final int totalCount;
  final int onlineCount;
  final int readyCount;
  final bool hasPrimaryAction;
  final bool hasSecondaryAction;
  final VoidCallback? onOpenPrimary;
  final VoidCallback? onOpenSecondary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            const VideoStatusChip(
              label: '当前主画面',
              tone: VideoStatusChipTone.info,
            ),
            VideoStatusChip(
              label: stream.available ? '在线' : '离线',
              tone: stream.available
                  ? VideoStatusChipTone.active
                  : VideoStatusChipTone.muted,
            ),
            VideoStatusChip(
              label: _modeLabel(stream),
              tone: VideoStatusChipTone.secondary,
            ),
            VideoStatusChip(
              label: stream.aiResultForwarded ? 'AI 已联动' : 'AI 待联动',
              tone: stream.aiResultForwarded
                  ? VideoStatusChipTone.info
                  : VideoStatusChipTone.muted,
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          stream.displayName,
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _buildPrimaryDescription(stream),
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final metrics = <Widget>[
              const VideoInfoTile(
                label: '当前值守',
                value: '先看主画面',
                accentColor: AppPalette.softPine,
              ),
              VideoInfoTile(
                label: '在线画面',
                value: '$onlineCount / $totalCount',
                accentColor: AppPalette.mistMint,
              ),
              VideoInfoTile(
                label: '可直接查看',
                value: '$readyCount 路',
                accentColor: AppPalette.linenOlive,
              ),
              VideoInfoTile(
                label: 'AI 联动',
                value: stream.aiResultForwarded ? '已收到结果' : '等待上送',
                accentColor: AppPalette.softLavender,
              ),
            ];

            if (constraints.maxWidth < 720) {
              return Column(
                children: <Widget>[
                  metrics[0],
                  const SizedBox(height: 10),
                  metrics[1],
                  const SizedBox(height: 10),
                  metrics[2],
                  const SizedBox(height: 10),
                  metrics[3],
                ],
              );
            }

            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: metrics
                  .map(
                    (metric) => SizedBox(
                      width: (constraints.maxWidth - 10) / 2,
                      child: metric,
                    ),
                  )
                  .toList(growable: false),
            );
          },
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 420;
            final primaryButton = FilledButton.icon(
              onPressed: onOpenPrimary,
              icon: const Icon(Icons.fullscreen_rounded),
              label: const Text('放大查看'),
            );
            final secondaryButton = OutlinedButton.icon(
              onPressed: onOpenSecondary,
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('备用入口'),
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(width: double.infinity, child: primaryButton),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: secondaryButton),
                ],
              );
            }

            return Row(
              children: <Widget>[
                Expanded(child: primaryButton),
                const SizedBox(width: 12),
                Expanded(child: secondaryButton),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
        Text(
          hasPrimaryAction
              ? '主画面放在最上面，值守时先看这里；只有主入口异常时再切备用入口。'
              : '当前主画面还没有可用入口，请先刷新状态，恢复后再进入。',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.55,
          ),
        ),
      ],
    );
  }

  static String _buildPrimaryDescription(VideoStreamInfo stream) {
    if (stream.aiResultForwarded) {
      return '值守时主画面会直接在上方播放，后端最近也已经收到这一路的 AI 结果，适合边看边复核。';
    }
    if (!stream.available) {
      return '主画面当前离线，先确认链路恢复；恢复后会直接在上方开始播放。';
    }
    if (!stream.hasPlayerUrl && !stream.hasGatewayPageUrl) {
      return '主画面已经在线，但入口还没准备好，刷新后会自动恢复。';
    }
    return '值守时主画面会直接在上方播放，需要更大视图时再放大查看。';
  }

  static String _modeLabel(VideoStreamInfo stream) {
    final summary = stream.modeSummary.toLowerCase();
    if (summary.contains('webrtc')) {
      return '实时优先';
    }
    if (summary.contains('mse')) {
      return '标准模式';
    }
    return '自动选择';
  }
}
