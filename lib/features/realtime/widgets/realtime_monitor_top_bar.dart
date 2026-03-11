import 'package:flutter/material.dart';
import 'package:sickandflutter/features/realtime/realtime_detect_controller.dart';
import 'package:sickandflutter/features/realtime/realtime_view_utils.dart';
import 'package:sickandflutter/shared/widgets/common_button.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 实时监控页顶部状态条，展示轮询状态和主操作入口。
class RealtimeMonitorTopBar extends StatelessWidget {
  /// 创建实时监控页顶部状态条。
  const RealtimeMonitorTopBar({
    required this.currentUser,
    required this.state,
    required this.onRefresh,
    required this.onToggleAutoRefresh,
    required this.onLogout,
    super.key,
  });

  /// 当前登录用户显示名。
  final String currentUser;

  /// 实时监控页状态。
  final RealtimeDetectState state;

  /// 手动刷新回调。
  final Future<void> Function() onRefresh;

  /// 自动刷新开关回调。
  final Future<void> Function(bool enabled) onToggleAutoRefresh;

  /// 退出登录回调。
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusCards = <Widget>[
      _StatusChip(
        icon: Icons.person_outline_rounded,
        label: '当前用户：$currentUser',
      ),
      _StatusChip(
        icon: Icons.cable_rounded,
        label: state.errorMessage == null ? '链路稳定' : '链路异常',
        foregroundColor: state.errorMessage == null
            ? const Color(0xFF176255)
            : colorScheme.error,
        backgroundColor: state.errorMessage == null
            ? colorScheme.primaryContainer.withValues(alpha: 0.68)
            : colorScheme.errorContainer,
      ),
      _StatusChip(
        icon: Icons.lightbulb_outline_rounded,
        label: state.isSubmittingLed ? '补光提交中' : '补光待命',
      ),
      _StatusChip(
        icon: Icons.update_rounded,
        label: '最近同步：${formatRealtimeTimestamp(state.lastRefreshAt)}',
      ),
    ];

    return CommonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 760;
              final heading = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '值守台',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '主控台优先呈现刷新状态、链路反馈和退出操作，避免值守中频繁切换页面。',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.56,
                    ),
                  ),
                ],
              );
              final actions = Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  CommonButton(
                    label: '立即刷新',
                    tone: CommonButtonTone.secondary,
                    isLoading: state.isRefreshing,
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: onRefresh,
                  ),
                  CommonButton(
                    label: '退出登录',
                    tone: CommonButtonTone.danger,
                    icon: const Icon(Icons.logout_rounded),
                    onPressed: onLogout,
                  ),
                ],
              );

              if (isCompact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    heading,
                    const SizedBox(height: 16),
                    actions,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: heading),
                  const SizedBox(width: 16),
                  Flexible(child: actions),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          Wrap(spacing: 12, runSpacing: 12, children: statusCards),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.32),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 620;
                final summary = Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.autorenew_rounded,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '自动轮询',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            state.isAutoRefreshEnabled
                                ? '当前保持每 3 秒自动拉取一次设备状态。'
                                : '当前已暂停自动轮询，只响应手动刷新。',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
                final switchPanel = Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.24),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Switch.adaptive(
                        value: state.isAutoRefreshEnabled,
                        onChanged: onToggleAutoRefresh,
                      ),
                      Text(
                        state.isAutoRefreshEnabled ? '已开启' : '已暂停',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                );

                if (isCompact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      summary,
                      const SizedBox(height: 16),
                      switchPanel,
                    ],
                  );
                }

                return Row(
                  children: <Widget>[
                    Expanded(child: summary),
                    const SizedBox(width: 16),
                    switchPanel,
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    this.foregroundColor,
    this.backgroundColor,
  });

  final IconData icon;
  final String label;
  final Color? foregroundColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveForeground = foregroundColor ?? colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            colorScheme.surfaceContainerHigh.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: effectiveForeground),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: effectiveForeground,
            ),
          ),
        ],
      ),
    );
  }
}
