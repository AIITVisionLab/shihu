import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/features/realtime/realtime_detect_controller.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/detection_item.dart';
import 'package:sickandflutter/shared/widgets/common_button.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 实时识别页，承接测试帧链路、会话控制和后续摄像头扩展。
class RealtimeDetectPage extends ConsumerWidget {
  /// 创建实时识别页。
  const RealtimeDetectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(realtimeDetectControllerProvider);
    final controller = ref.read(realtimeDetectControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('实时监测')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: <Widget>[
                _RealtimeStatusCard(state: state),
                const SizedBox(height: 20),
                _RealtimePreviewCard(state: state),
                const SizedBox(height: 20),
                _RealtimeMetricsSection(state: state),
                const SizedBox(height: 20),
                _RealtimeSessionCard(
                  state: state,
                  onStart: controller.startSession,
                  onPause: controller.pauseSession,
                  onResume: controller.resumeSession,
                ),
                const SizedBox(height: 20),
                _RealtimeDetectionsCard(state: state),
                const SizedBox(height: 20),
                const _RealtimeNextStepsCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RealtimeStatusCard extends StatelessWidget {
  const _RealtimeStatusCard({required this.state});

  final RealtimeDetectState state;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: '链路状态',
      subtitle: state.supportsTestFeed
          ? '当前已接入测试帧会话和摘要刷新，但仍不伪造摄像头预览或真实检测框。'
          : '当前环境未开放测试帧链路，需接入摄像头取帧后再启用真实实时识别。',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: <Widget>[
          _StatePill(
            label: '会话状态：${state.status.label}',
            tone: _pillToneForStatus(state.status),
          ),
          _StatePill(label: state.supportsTestFeed ? '测试帧链路已接入' : '待接入摄像头取帧'),
          _StatePill(
            label: state.hasResult ? '实时摘要已刷新' : '等待首帧摘要',
            tone: state.hasResult
                ? _StatePillTone.success
                : _StatePillTone.neutral,
          ),
          _StatePill(
            label: state.hasResult
                ? '当前帧检测框 ${state.detectionCount} 个'
                : 'Overlay 元数据待刷新',
          ),
        ],
      ),
    );
  }
}

class _RealtimePreviewCard extends StatelessWidget {
  const _RealtimePreviewCard({required this.state});

  final RealtimeDetectState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final summary = state.summary;

    return CommonCard(
      title: '预览区域',
      subtitle: state.supportsTestFeed
          ? '当前只展示测试链路状态和 Overlay 元数据，不展示真实摄像头画面。'
          : '后续将在这里承接摄像头画面、检测框 Overlay 和实时结果高亮。',
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xFF173628), Color(0xFF32684E)],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 160,
                  height: 160,
                  margin: const EdgeInsets.only(top: 18, right: 18),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  width: 120,
                  height: 120,
                  margin: const EdgeInsets.only(left: 24, bottom: 24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _PreviewBanner(state: state),
                    const Spacer(),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Icon(
                              state.supportsTestFeed
                                  ? Icons.stream_outlined
                                  : Icons.videocam_off_outlined,
                              size: 42,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            state.supportsTestFeed ? '测试帧链路已接入' : '摄像头预览待接入',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            state.supportsTestFeed
                                ? '当前会话只刷新测试帧摘要和检测框元数据，避免在真实链路未打通前用假预览制造完成错觉。'
                                : '当前环境不提供无摄像头测试链路，后续会在这里接入真实预览和 Overlay 渲染。',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  height: 1.5,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: _PreviewMetric(
                              title: '当前主结果',
                              value: summary?.primaryLabelName ?? '--',
                            ),
                          ),
                          Expanded(
                            child: _PreviewMetric(
                              title: '检测框数量',
                              value: '${state.detectionCount}',
                            ),
                          ),
                          Expanded(
                            child: _PreviewMetric(
                              title: '最近刷新',
                              value: _formatClockTime(state.lastFrameAt),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (state.errorMessage != null) ...<Widget>[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer.withValues(
                            alpha: 0.92,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          state.errorMessage!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.onErrorContainer),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RealtimeMetricsSection extends StatelessWidget {
  const _RealtimeMetricsSection({required this.state});

  final RealtimeDetectState state;

  @override
  Widget build(BuildContext context) {
    final summary = state.summary;

    return CommonCard(
      title: '实时摘要',
      subtitle: state.hasResult
          ? '最近一帧结果已刷新，可继续观察会话状态和检测框元数据变化。'
          : '开始测试链路后，这里会展示主识别结果、健康状态和单帧耗时。',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = _metricCardWidth(constraints.maxWidth);

          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: <Widget>[
              _RealtimeMetricCard(
                width: cardWidth,
                title: '主识别结果',
                value: summary?.primaryLabelName ?? '--',
                subtitle: state.hasResult ? '最近一帧主标签' : '等待测试帧首个结果',
              ),
              _RealtimeMetricCard(
                width: cardWidth,
                title: '健康状态',
                value: summary?.healthStatus.label ?? '--',
                subtitle: state.hasResult ? '来自最近一帧摘要' : '待接入实时状态',
              ),
              _RealtimeMetricCard(
                width: cardWidth,
                title: '严重程度',
                value: summary?.severityLevel.label ?? '--',
                subtitle: state.hasResult ? '按最近一帧结果刷新' : '待接入严重度判断',
              ),
              _RealtimeMetricCard(
                width: cardWidth,
                title: '单帧耗时',
                value: state.lastInferenceMs == null
                    ? '--'
                    : '${state.lastInferenceMs} ms',
                subtitle: state.hasResult ? '模型推理耗时' : '待接入推理延迟',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RealtimeSessionCard extends StatelessWidget {
  const _RealtimeSessionCard({
    required this.state,
    required this.onStart,
    required this.onPause,
    required this.onResume,
  });

  final RealtimeDetectState state;
  final Future<void> Function() onStart;
  final VoidCallback onPause;
  final Future<void> Function() onResume;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: '会话控制',
      subtitle: state.supportsTestFeed
          ? '当前控制的是测试帧轮询，不会触发权限申请或真实摄像头预览。'
          : '当前环境下只能保留会话入口，需接入摄像头取帧后才能真正运行。',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 560;
          final actions = _buildActions();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (isCompact)
                Column(
                  children: actions
                      .expand(
                        (button) => <Widget>[
                          button,
                          const SizedBox(height: 12),
                        ],
                      )
                      .take(actions.length * 2 - 1)
                      .toList(growable: false),
                )
              else
                Row(
                  children: actions
                      .expand(
                        (button) => <Widget>[
                          Expanded(child: button),
                          const SizedBox(width: 12),
                        ],
                      )
                      .take(actions.length * 2 - 1)
                      .toList(growable: false),
                ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: <Widget>[
                  _SessionMetaItem(label: '当前状态', value: state.status.label),
                  _SessionMetaItem(
                    label: '会话 ID',
                    value: state.sessionId ?? '--',
                  ),
                  _SessionMetaItem(
                    label: '已处理帧数',
                    value: '${state.frameIndex}',
                  ),
                  _SessionMetaItem(
                    label: '最近刷新',
                    value: _formatClockTime(state.lastFrameAt),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _buildActions() {
    final isInitializing = state.status == RealtimeSessionStatus.initializing;
    final isRunning = state.status == RealtimeSessionStatus.running;
    final isPaused = state.status == RealtimeSessionStatus.paused;

    if (isRunning) {
      return <Widget>[
        const CommonButton(
          label: '会话运行中',
          icon: Icon(Icons.play_circle_fill_rounded),
        ),
        CommonButton(
          label: '暂停会话',
          tone: CommonButtonTone.secondary,
          icon: const Icon(Icons.pause_rounded),
          onPressed: onPause,
        ),
      ];
    }

    if (isPaused) {
      return <Widget>[
        CommonButton(
          label: '继续会话',
          icon: const Icon(Icons.play_arrow_rounded),
          onPressed: onResume,
        ),
        CommonButton(
          label: '重新开始',
          tone: CommonButtonTone.secondary,
          icon: const Icon(Icons.replay_rounded),
          onPressed: onStart,
        ),
      ];
    }

    return <Widget>[
      CommonButton(
        label: state.supportsTestFeed ? '开始测试链路' : '等待摄像头接入',
        icon: Icon(
          state.supportsTestFeed
              ? Icons.play_arrow_rounded
              : Icons.videocam_off_outlined,
        ),
        isLoading: isInitializing,
        onPressed: state.supportsTestFeed && !isInitializing ? onStart : null,
      ),
      CommonButton(
        label: '暂停会话',
        tone: CommonButtonTone.secondary,
        icon: const Icon(Icons.pause_rounded),
        onPressed: null,
      ),
    ];
  }
}

class _RealtimeDetectionsCard extends StatelessWidget {
  const _RealtimeDetectionsCard({required this.state});

  final RealtimeDetectState state;

  @override
  Widget build(BuildContext context) {
    final detections =
        state.latestResult?.detections ?? const <DetectionItem>[];

    return CommonCard(
      title: '当前帧检测框',
      subtitle: state.hasResult
          ? '当前仅刷新检测框元数据，真实画面叠框渲染仍待摄像头链路接入。'
          : '开始测试链路后，这里会展示当前帧检测框数量、位置和严重程度。',
      child: detections.isEmpty
          ? Text(state.hasResult ? '当前帧未检测到异常框。' : '当前还没有可展示的检测框数据。')
          : Column(
              children: detections
                  .map((item) => _DetectionItemTile(item: item))
                  .toList(growable: false),
            ),
    );
  }
}

class _RealtimeNextStepsCard extends StatelessWidget {
  const _RealtimeNextStepsCard();

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: '下一步接入项',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const <Widget>[
          _TodoLine(text: '测试帧轮询、会话状态和摘要刷新已接入。', done: true),
          _TodoLine(text: '接入摄像头权限申请和失败态。'),
          _TodoLine(text: '承接真实预览、帧采样和实时接口请求。'),
          _TodoLine(text: '把当前检测框元数据渲染为真实 Overlay。'),
        ],
      ),
    );
  }
}

class _PreviewBanner extends StatelessWidget {
  const _PreviewBanner({required this.state});

  final RealtimeDetectState state;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.radar_rounded, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              _previewBannerText(state),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _previewBannerText(RealtimeDetectState state) {
    switch (state.status) {
      case RealtimeSessionStatus.running:
        return '测试帧链路运行中';
      case RealtimeSessionStatus.paused:
        return '会话已暂停';
      case RealtimeSessionStatus.initializing:
        return '正在拉取首帧';
      case RealtimeSessionStatus.error:
        return '链路异常';
      case RealtimeSessionStatus.permissionDenied:
        return '权限受限';
      case RealtimeSessionStatus.idle:
        return state.supportsTestFeed ? '等待开始测试链路' : '等待摄像头接入';
    }
  }
}

class _PreviewMetric extends StatelessWidget {
  const _PreviewMetric({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.72),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _RealtimeMetricCard extends StatelessWidget {
  const _RealtimeMetricCard({
    required this.width,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  final double width;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetectionItemTile extends StatelessWidget {
  const _DetectionItemTile({required this.item});

  final DetectionItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.labelName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '类别：${item.category.label}  ·  严重程度：${item.severityLevel.label}',
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '置信度 ${(item.confidence * 100).toStringAsFixed(1)}%  ·  坐标 (${item.bbox.x.toStringAsFixed(2)}, ${item.bbox.y.toStringAsFixed(2)})',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _StatePill(
                label:
                    '${(item.bbox.width * 100).toStringAsFixed(0)}% x ${(item.bbox.height * 100).toStringAsFixed(0)}%',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionMetaItem extends StatelessWidget {
  const _SessionMetaItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

enum _StatePillTone { neutral, success, warning }

class _StatePill extends StatelessWidget {
  const _StatePill({required this.label, this.tone = _StatePillTone.neutral});

  final String label;
  final _StatePillTone tone;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (tone) {
      _StatePillTone.success => (
        Theme.of(context).colorScheme.tertiaryContainer,
        Theme.of(context).colorScheme.onTertiaryContainer,
      ),
      _StatePillTone.warning => (
        Theme.of(context).colorScheme.errorContainer,
        Theme.of(context).colorScheme.onErrorContainer,
      ),
      _StatePillTone.neutral => (
        Theme.of(context).colorScheme.primaryContainer,
        Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _TodoLine extends StatelessWidget {
  const _TodoLine({required this.text, this.done = false});

  final String text;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(
              done ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 18,
              color: done ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

_StatePillTone _pillToneForStatus(RealtimeSessionStatus status) {
  switch (status) {
    case RealtimeSessionStatus.running:
      return _StatePillTone.success;
    case RealtimeSessionStatus.error:
    case RealtimeSessionStatus.permissionDenied:
      return _StatePillTone.warning;
    case RealtimeSessionStatus.idle:
    case RealtimeSessionStatus.initializing:
    case RealtimeSessionStatus.paused:
      return _StatePillTone.neutral;
  }
}

String _formatClockTime(DateTime? value) {
  if (value == null) {
    return '--';
  }

  final hours = value.hour.toString().padLeft(2, '0');
  final minutes = value.minute.toString().padLeft(2, '0');
  final seconds = value.second.toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}

double _metricCardWidth(double maxWidth) {
  if (maxWidth < 420) {
    return maxWidth;
  }
  if (maxWidth < 760) {
    return (maxWidth - 16) / 2;
  }
  if (maxWidth < 1040) {
    return (maxWidth - 32) / 3;
  }
  return (maxWidth - 48) / 4;
}
