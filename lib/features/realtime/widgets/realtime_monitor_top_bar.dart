import 'package:flutter/material.dart';
import 'package:sickandflutter/features/realtime/realtime_detect_controller.dart';
import 'package:sickandflutter/shared/widgets/common_button.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 实时监控页顶部状态条，展示轮询状态和主操作入口。
class RealtimeMonitorTopBar extends StatelessWidget {
  /// 创建实时监控页顶部状态条。
  const RealtimeMonitorTopBar({
    required this.state,
    required this.onRefresh,
    required this.onToggleAutoRefresh,
    required this.onLogout,
    super.key,
  });

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

    return CommonCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final heading = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '快速操作',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '自动刷新默认开启，退出登录也放在这里。',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );

          final controls = Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Switch.adaptive(
                    value: state.isAutoRefreshEnabled,
                    onChanged: onToggleAutoRefresh,
                  ),
                  Text(
                    state.isAutoRefreshEnabled ? '轮询已开启' : '轮询已暂停',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              CommonButton(
                label: '刷新',
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

          if (constraints.maxWidth < 760) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[heading, const SizedBox(height: 14), controls],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: heading),
              const SizedBox(width: 16),
              Flexible(child: controls),
            ],
          );
        },
      ),
    );
  }
}
