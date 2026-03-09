import 'package:flutter/material.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
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
    required this.onOpenOverview,
    required this.onOpenSettings,
    required this.onRefresh,
    required this.onToggleAutoRefresh,
    required this.onLogout,
    super.key,
  });

  /// 当前登录用户显示名。
  final String currentUser;

  /// 实时监控页状态。
  final RealtimeDetectState state;

  /// 打开平台总览回调。
  final VoidCallback onOpenOverview;

  /// 打开运维设置回调。
  final VoidCallback onOpenSettings;

  /// 手动刷新回调。
  final Future<void> Function() onRefresh;

  /// 自动刷新开关回调。
  final Future<void> Function(bool enabled) onToggleAutoRefresh;

  /// 退出登录回调。
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CommonCard(
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          _StatusPill(
            icon: Icons.person_outline_rounded,
            label: '当前用户：$currentUser',
          ),
          _StatusPill(
            icon: Icons.cable_rounded,
            label: state.errorMessage == null ? '链路正常' : '链路异常',
            foregroundColor: state.errorMessage == null
                ? const Color(0xFF166534)
                : theme.colorScheme.error,
            backgroundColor: state.errorMessage == null
                ? const Color(0xFFE8F7EB)
                : theme.colorScheme.errorContainer,
          ),
          _StatusPill(
            icon: Icons.schedule_rounded,
            label: '轮询间隔：${state.isAutoRefreshEnabled ? '3 秒' : '已暂停自动刷新'}',
          ),
          _StatusPill(
            icon: Icons.update_rounded,
            label: '最近同步：${formatRealtimeTimestamp(state.lastRefreshAt)}',
          ),
          Switch.adaptive(
            value: state.isAutoRefreshEnabled,
            onChanged: onToggleAutoRefresh,
          ),
          Text(
            '自动刷新',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          CommonButton(
            label: AppCopy.realtimeOpenOverview,
            tone: CommonButtonTone.secondary,
            icon: const Icon(Icons.dashboard_outlined),
            onPressed: onOpenOverview,
          ),
          CommonButton(
            label: AppCopy.realtimeOpenSettings,
            tone: CommonButtonTone.secondary,
            icon: const Icon(Icons.settings_outlined),
            onPressed: onOpenSettings,
          ),
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
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
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
    final effectiveForeground = foregroundColor ?? const Color(0xFF344256);
    final effectiveBackground = backgroundColor ?? const Color(0xFFF3F7FC);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: effectiveBackground,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD8E2EF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: effectiveForeground),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: effectiveForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
