import 'package:flutter/material.dart';
import 'package:sickandflutter/shared/widgets/common_button.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 实时识别页，承接摄像头预览、会话控制和实时摘要的页面骨架。
class RealtimeDetectPage extends StatelessWidget {
  /// 创建实时识别页。
  const RealtimeDetectPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('实时监测')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: const <Widget>[
                _RealtimeStatusCard(),
                SizedBox(height: 20),
                _RealtimePreviewCard(),
                SizedBox(height: 20),
                _RealtimeMetricsSection(),
                SizedBox(height: 20),
                _RealtimeSessionCard(),
                SizedBox(height: 20),
                _RealtimeNextStepsCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RealtimeStatusCard extends StatelessWidget {
  const _RealtimeStatusCard();

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: '链路状态',
      subtitle: '当前只完成实时识别页面骨架，不伪造摄像头预览、检测框或实时结果。',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: const <Widget>[
          _StatePill(label: '页面骨架已接入'),
          _StatePill(label: '摄像头权限待接入'),
          _StatePill(label: '帧推理待接入'),
          _StatePill(label: 'Overlay 待接入'),
        ],
      ),
    );
  }
}

class _RealtimePreviewCard extends StatelessWidget {
  const _RealtimePreviewCard();

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: '预览区域',
      subtitle: '该区域会在下一轮承接摄像头画面、检测框 Overlay 和实时结果高亮。',
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
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
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
                        child: const Icon(
                          Icons.videocam_outlined,
                          size: 42,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        '摄像头预览将在下一轮接入',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '当前保留稳定布局和信息层级，避免在真实链路未接通前用假画面制造已实现错觉。',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
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

class _RealtimeMetricsSection extends StatelessWidget {
  const _RealtimeMetricsSection();

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: '实时摘要',
      subtitle: '先固定信息层级和节奏，后续只把真实数据灌进来。',
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
                value: '--',
                subtitle: '待接入实时摘要',
              ),
              _RealtimeMetricCard(
                width: cardWidth,
                title: '严重程度',
                value: '--',
                subtitle: '待接入实时状态',
              ),
              _RealtimeMetricCard(
                width: cardWidth,
                title: '单帧耗时',
                value: '--',
                subtitle: '待接入推理延迟',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RealtimeSessionCard extends StatelessWidget {
  const _RealtimeSessionCard();

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: '会话控制',
      subtitle: '待摄像头权限、预览链路和帧采样状态接入后开放。',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 560;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (isCompact)
                Column(
                  children: const <Widget>[
                    CommonButton(
                      label: '开始实时识别',
                      icon: Icon(Icons.play_arrow_rounded),
                    ),
                    SizedBox(height: 12),
                    CommonButton(
                      label: '暂停会话',
                      tone: CommonButtonTone.secondary,
                      icon: Icon(Icons.pause_rounded),
                    ),
                  ],
                )
              else
                Row(
                  children: const <Widget>[
                    Expanded(
                      child: CommonButton(
                        label: '开始实时识别',
                        icon: Icon(Icons.play_arrow_rounded),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: CommonButton(
                        label: '暂停会话',
                        tone: CommonButtonTone.secondary,
                        icon: Icon(Icons.pause_rounded),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              Text(
                '当前版本不触发权限申请、不启动摄像头，也不伪造运行中状态。',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          );
        },
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
          _TodoLine(text: '接入摄像头权限申请和失败态。'),
          _TodoLine(text: '承接实时预览、帧采样和会话状态流。'),
          _TodoLine(text: '接入 `/api/v1/detect/realtime/frame` 与 Overlay 刷新。'),
        ],
      ),
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

class _StatePill extends StatelessWidget {
  const _StatePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _TodoLine extends StatelessWidget {
  const _TodoLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.check_circle_outline, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

double _metricCardWidth(double maxWidth) {
  if (maxWidth < 420) {
    return maxWidth;
  }
  if (maxWidth < 760) {
    return (maxWidth - 16) / 2;
  }
  return (maxWidth - 32) / 3;
}
