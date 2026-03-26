import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/features/video/video_playback_page.dart';
import 'package:sickandflutter/features/video/video_stream_info.dart';
import 'package:sickandflutter/features/video/widgets/video_view_primitives.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 单路画面卡片。
class VideoStreamCard extends StatelessWidget {
  /// 创建单路画面卡片。
  const VideoStreamCard({required this.stream, super.key});

  /// 当前画面信息。
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

    return CommonCard(
      padding: const EdgeInsets.all(22),
      accentColor: AppPalette.linenOlive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          VideoScreenStage(stream: stream, hasPrimaryAction: hasPrimaryAction),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              VideoStatusChip(
                label: stream.available ? '在线' : '离线',
                tone: stream.available
                    ? VideoStatusChipTone.active
                    : VideoStatusChipTone.muted,
              ),
              VideoStatusChip(
                label: hasPrimaryAction ? '可查看' : '暂不可查看',
                tone: hasPrimaryAction
                    ? VideoStatusChipTone.info
                    : VideoStatusChipTone.muted,
              ),
              VideoStatusChip(
                label: _modeLabel(),
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
          const SizedBox(height: 16),
          Text(
            stream.displayName,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _buildDescription(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.58,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final modeTile = VideoInfoTile(
                label: '观看方式',
                value: _modeLabel(),
                accentColor: AppPalette.linenOlive,
              );
              final backupTile = VideoInfoTile(
                label: '备用入口',
                value: stream.hasGatewayPageUrl ? '已提供' : '暂无',
                accentColor: AppPalette.softLavender,
              );
              final stateTile = VideoInfoTile(
                label: '当前状态',
                value: stream.available ? '可查看' : '等待恢复',
                accentColor: AppPalette.mistMint,
              );
              final aiTile = VideoInfoTile(
                label: 'AI 联动',
                value: stream.aiResultForwarded ? '已收到结果' : '等待上送',
                accentColor: AppPalette.softLavender,
              );

              if (constraints.maxWidth < 720) {
                return Column(
                  children: <Widget>[
                    modeTile,
                    const SizedBox(height: 12),
                    backupTile,
                    const SizedBox(height: 12),
                    stateTile,
                    const SizedBox(height: 12),
                    aiTile,
                  ],
                );
              }

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
                    child: modeTile,
                  ),
                  SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
                    child: backupTile,
                  ),
                  SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
                    child: stateTile,
                  ),
                  SizedBox(
                    width: (constraints.maxWidth - 12) / 2,
                    child: aiTile,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 520;
              final primaryButton = FilledButton.icon(
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
                label: const Text('打开画面'),
              );
              final secondaryButton = OutlinedButton.icon(
                onPressed: hasSecondaryAction
                    ? () => _openPlayer(
                        context,
                        title: stream.displayName,
                        url: stream.gatewayPageUrl,
                        streamId: stream.streamId,
                        gatewayPageUrl: stream.gatewayPageUrl,
                        sourceLabel: '备用入口',
                      )
                    : null,
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('备用入口'),
              );

              if (stacked) {
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
        ],
      ),
    );
  }

  String _buildDescription() {
    if (stream.aiResultForwarded && stream.available) {
      return '当前画面可正常查看，后端最近也已经收到了对应 AI 结果。';
    }
    if (!stream.available) {
      return '当前暂未连通，稍后刷新后再看。';
    }
    if (!stream.hasPlayerUrl && !stream.hasGatewayPageUrl) {
      return '画面已经在线，正在准备打开方式。';
    }
    return '当前画面可正常查看，需要时可以直接在软件内查看。';
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

/// 单路画面舞台区。
class VideoScreenStage extends StatelessWidget {
  /// 创建单路画面舞台区。
  const VideoScreenStage({
    required this.stream,
    required this.hasPrimaryAction,
    super.key,
  });

  /// 当前画面信息。
  final VideoStreamInfo stream;

  /// 是否存在主入口。
  final bool hasPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final stageAccent = stream.available
        ? AppPalette.mistMint
        : AppPalette.softLavender;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              AppPalette.blendOnPaper(
                stageAccent,
                opacity: 0.14,
                base: stream.available
                    ? colorScheme.surfaceContainerLowest
                    : colorScheme.surfaceContainerLow,
              ),
              AppPalette.blendOnPaper(
                AppPalette.linenOlive,
                opacity: 0.06,
                base: colorScheme.surfaceContainer,
              ),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppPalette.pineShadow.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: <Widget>[
              Positioned(
                top: 14,
                left: 14,
                child: VideoStatusChip(
                  label: stream.available ? '在线' : '离线',
                  tone: stream.available
                      ? VideoStatusChipTone.active
                      : VideoStatusChipTone.muted,
                ),
              ),
              Center(
                child: Icon(
                  hasPrimaryAction
                      ? Icons.play_circle_fill_rounded
                      : Icons.videocam_outlined,
                  size: 54,
                  color: hasPrimaryAction
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppPalette.blendOnPaper(
                      stageAccent,
                      opacity: 0.14,
                      base: colorScheme.surfaceContainerLowest,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.8),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AppPalette.softPine.withValues(alpha: 0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          stream.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '实时画面',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
