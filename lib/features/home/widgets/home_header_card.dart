import 'package:flutter/material.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';

/// 首页顶部总览卡片。
class HomeHeaderCard extends StatelessWidget {
  /// 创建首页顶部总览卡片。
  const HomeHeaderCard({
    required this.version,
    required this.currentUser,
    super.key,
  });

  /// 应用版本。
  final String version;

  /// 当前用户。
  final String currentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF112418),
            Color(0xFF214B39),
            Color(0xFFB3884A),
          ],
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x2614291E),
            blurRadius: 48,
            offset: Offset(0, 26),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 820;
          final summary = _HeaderSummary(
            version: version,
            currentUser: currentUser,
          );
          const scoreCard = _HeaderScoreCard();

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                summary,
                const SizedBox(height: 20),
                scoreCard,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(flex: 10, child: summary),
              const SizedBox(width: 22),
              const Expanded(flex: 5, child: scoreCard),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderSummary extends StatelessWidget {
  const _HeaderSummary({required this.version, required this.currentUser});

  final String version;
  final String currentUser;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                AppCopy.homeCrossPlatformDemo,
                style: textTheme.labelLarge?.copyWith(color: Colors.white),
              ),
            ),
            _MetaPill(label: AppCopy.homeVersionPill(version)),
            _MetaPill(label: '当前用户 $currentUser'),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          AppConstants.appName,
          style: textTheme.displaySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '把栽培环境、设备状态和执行动作收进同一个运营中枢，既能稳定查看，也能直接执行。',
          style: textTheme.titleMedium?.copyWith(
            color: const Color(0xFFF0F4ED),
            height: 1.65,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          AppCopy.homeOverview,
          style: textTheme.bodyLarge?.copyWith(
            color: const Color(0xFFE2E9DD),
            height: 1.72,
          ),
        ),
        const SizedBox(height: 24),
        const Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            _SignalChip(label: '视频流入口'),
            _SignalChip(label: '统一会话管理'),
            _SignalChip(label: '设备状态轮询'),
            _SignalChip(label: '远程补光控制'),
            _SignalChip(label: AppCopy.homeMaterialPill),
          ],
        ),
      ],
    );
  }
}

class _HeaderScoreCard extends StatelessWidget {
  const _HeaderScoreCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '运行基线',
            style: textTheme.labelLarge?.copyWith(
              color: const Color(0xFFE6EEE0),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '5 / 5',
            style: textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '账号、视频流、状态、健康检查与补光控制已经全部接入统一工作台。',
            style: textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFE1E9DC),
              height: 1.7,
            ),
          ),
          const SizedBox(height: 20),
          const _ScoreRow(label: '视频流清单', value: '已接入'),
          const SizedBox(height: 10),
          const _ScoreRow(label: '会话恢复', value: '可用'),
          const SizedBox(height: 10),
          const _ScoreRow(label: '设备状态', value: '同步中'),
          const SizedBox(height: 10),
          const _ScoreRow(label: '远程控制', value: '在线'),
        ],
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: Colors.white),
      ),
    );
  }
}

class _SignalChip extends StatelessWidget {
  const _SignalChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: const Color(0xFFF4F7F1)),
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFFD8E2D3)),
          ),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: const Color(0xFFFFF3DE)),
        ),
      ],
    );
  }
}
