import 'package:flutter/material.dart';
import 'package:sickandflutter/shared/models/device_state_info.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 实时监控页状态说明区。
class RealtimeStatusGuideSection extends StatelessWidget {
  /// 创建实时监控页状态说明区。
  const RealtimeStatusGuideSection({required this.deviceState, super.key});

  /// 当前设备状态。
  final DeviceStateInfo? deviceState;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: '状态说明',
      subtitle: '这一组说明与后端静态控制台保持一致，用于解释错误码展示语义。',
      child: Column(
        children: <Widget>[
          _GuideItem(
            icon: Icons.verified_outlined,
            title: '错误码 0',
            description: '系统运行正常，设备状态处于安全区间，可继续观察实时数据。',
            isActive: deviceState?.errorCode == 0,
          ),
          const SizedBox(height: 14),
          _GuideItem(
            icon: Icons.warning_amber_rounded,
            title: '错误码 1',
            description: '系统进入预警状态，建议人工复核当前设备环境和控制策略。',
            isActive: deviceState?.errorCode == 1,
          ),
          const SizedBox(height: 14),
          _GuideItem(
            icon: Icons.gpp_bad_rounded,
            title: '错误码 2',
            description: '系统进入严重告警状态，应优先处理设备异常或环境风险。',
            isActive: deviceState?.errorCode == 2,
          ),
          const SizedBox(height: 14),
          _GuideItem(
            icon: Icons.help_outline_rounded,
            title: '其他情况',
            description: '当前前端按未知状态展示，用于覆盖后端尚未定义或未返回的错误码。',
            isActive:
                deviceState == null ||
                deviceState?.alertLevel == DeviceAlertLevel.unknown,
          ),
        ],
      ),
    );
  }
}

class _GuideItem extends StatelessWidget {
  const _GuideItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.isActive,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive
            ? colorScheme.primaryContainer.withValues(alpha: 0.45)
            : colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive
              ? colorScheme.primary.withValues(alpha: 0.32)
              : colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive
                  ? colorScheme.primaryContainer
                  : colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
