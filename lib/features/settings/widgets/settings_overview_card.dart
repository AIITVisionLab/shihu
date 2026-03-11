import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/shared/models/device_state_info.dart';
import 'package:sickandflutter/shared/models/service_health_info.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 设置页运行环境概览卡片。
class SettingsOverviewCard extends StatelessWidget {
  /// 创建运行环境概览卡片。
  const SettingsOverviewCard({
    required this.buildFlavorLabel,
    required this.platformLabel,
    required this.versionLabel,
    required this.deviceStateAsync,
    required this.serviceHealthAsync,
    super.key,
  });

  /// 当前构建环境文案。
  final String buildFlavorLabel;

  /// 当前运行平台文案。
  final String platformLabel;

  /// 当前应用版本文案。
  final String versionLabel;

  /// 当前设备状态。
  final AsyncValue<DeviceStateInfo> deviceStateAsync;

  /// 当前服务健康状态。
  final AsyncValue<ServiceHealthInfo> serviceHealthAsync;

  @override
  Widget build(BuildContext context) {
    final deviceSummary = deviceStateAsync.when(
      loading: () => ('设备上报', '同步中', '等待最新设备状态'),
      error: (_, _) => ('设备上报', '异常', '设备状态卡片返回失败'),
      data: (state) =>
          ('设备上报', state.isFresh() ? '稳定' : '滞后', state.freshnessLabel()),
    );
    final healthSummary = serviceHealthAsync.when(
      loading: () => ('服务巡检', '巡检中', '正在检查服务连通性'),
      error: (_, _) => ('服务巡检', '异常', '健康检查返回失败'),
      data: (health) => (
        '服务巡检',
        health.status.trim().toLowerCase() == 'up' ? '正常' : '异常',
        health.freshnessLabel(),
      ),
    );

    return CommonCard(
      title: AppCopy.settingsOverviewTitle,
      subtitle: '设置页首屏优先回答三个问题：我在哪个环境、服务是否正常、设备是否仍在持续上报。',
      child: Column(
        children: <Widget>[
          const _OverviewBanner(),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = _responsiveCardWidth(
                maxWidth: constraints.maxWidth,
                minWidth: 220,
              );

              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: <Widget>[
                  _OverviewMetricCard(
                    width: cardWidth,
                    title: AppCopy.settingsEnvironmentType,
                    value: buildFlavorLabel,
                    supportingText: '决定是否开放高风险配置入口',
                    icon: Icons.layers_rounded,
                  ),
                  _OverviewMetricCard(
                    width: cardWidth,
                    title: AppCopy.settingsCurrentPlatform,
                    value: platformLabel,
                    supportingText: '决定导航布局和输入交互形式',
                    icon: Icons.devices_rounded,
                    trailingLabel: versionLabel,
                  ),
                  _OverviewMetricCard(
                    width: cardWidth,
                    title: deviceSummary.$1,
                    value: deviceSummary.$2,
                    supportingText: deviceSummary.$3,
                    icon: Icons.monitor_heart_rounded,
                  ),
                  _OverviewMetricCard(
                    width: cardWidth,
                    title: healthSummary.$1,
                    value: healthSummary.$2,
                    supportingText: healthSummary.$3,
                    icon: Icons.health_and_safety_outlined,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OverviewBanner extends StatelessWidget {
  const _OverviewBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.tune_rounded, color: colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              '先看巡检，再看设备；如果两者都异常，再回头检查服务地址和会话状态。',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewMetricCard extends StatelessWidget {
  const _OverviewMetricCard({
    required this.width,
    required this.title,
    required this.value,
    required this.supportingText,
    required this.icon,
    this.trailingLabel,
  });

  final double width;
  final String title;
  final String value;
  final String supportingText;
  final IconData icon;
  final String? trailingLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.84),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.28),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.78,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: colorScheme.onPrimaryContainer),
                  ),
                  const Spacer(),
                  if (trailingLabel != null)
                    Text(
                      trailingLabel!,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                supportingText,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

double _responsiveCardWidth({
  required double maxWidth,
  required double minWidth,
}) {
  if (maxWidth >= minWidth * 3 + 28) {
    return (maxWidth - 28) / 3;
  }

  if (maxWidth >= minWidth * 2 + 14) {
    return (maxWidth - 14) / 2;
  }

  return maxWidth;
}
