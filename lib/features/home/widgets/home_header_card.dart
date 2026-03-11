import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/shared/models/device_state_info.dart';
import 'package:sickandflutter/shared/models/service_health_info.dart';

/// 首页顶部总览卡片。
class HomeHeaderCard extends StatelessWidget {
  /// 创建首页顶部总览卡片。
  const HomeHeaderCard({
    required this.version,
    required this.currentUser,
    required this.deviceStateAsync,
    required this.serviceHealthAsync,
    required this.onRefresh,
    super.key,
  });

  /// 应用版本。
  final String version;

  /// 当前用户。
  final String currentUser;

  /// 当前设备状态。
  final AsyncValue<DeviceStateInfo> deviceStateAsync;

  /// 当前服务健康状态。
  final AsyncValue<ServiceHealthInfo> serviceHealthAsync;

  /// 手动刷新回调。
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final deviceState = deviceStateAsync.asData?.value;
    final serviceHealth = serviceHealthAsync.asData?.value;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colorScheme.surfaceContainerHighest.withValues(alpha: 0.84),
            colorScheme.surfaceContainerHigh.withValues(alpha: 0.94),
            colorScheme.surfaceContainerLow.withValues(alpha: 0.98),
          ],
        ),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.34),
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x10172019),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 940;
          final lead = _HomeHeaderLead(
            version: version,
            currentUser: currentUser,
            deviceState: deviceState,
            onRefresh: onRefresh,
          );
          final board = _HomeHeaderBoard(
            deviceStateAsync: deviceStateAsync,
            serviceHealthAsync: serviceHealthAsync,
            deviceState: deviceState,
            serviceHealth: serviceHealth,
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[lead, const SizedBox(height: 22), board],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(flex: 11, child: lead),
              const SizedBox(width: 20),
              Expanded(flex: 9, child: board),
            ],
          );
        },
      ),
    );
  }
}

class _HomeHeaderLead extends StatelessWidget {
  const _HomeHeaderLead({
    required this.version,
    required this.currentUser,
    required this.deviceState,
    required this.onRefresh,
  });

  final String version;
  final String currentUser;
  final DeviceStateInfo? deviceState;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            _MetaPill(
              label: AppCopy.homeCrossPlatformDemo,
              backgroundColor: colorScheme.primaryContainer.withValues(
                alpha: 0.78,
              ),
              foregroundColor: colorScheme.onPrimaryContainer,
            ),
            _MetaPill(label: AppCopy.homeVersionPill(version)),
            _MetaPill(label: '当前账号 $currentUser'),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          '值守总览',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '把设备上报、异常等级、服务巡检和页面入口收进同一屏，进入软件后先做判断，再决定下一步动作。',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.62,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.28),
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.monitor_heart_rounded,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      deviceState == null
                          ? '等待设备状态'
                          : _resolveDeviceLabel(deviceState!),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      deviceState == null
                          ? '首页会自动刷新，拿到设备状态后再进入值守判断。'
                          : '${deviceState!.alertTitle} · ${deviceState!.freshnessLabel()}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            _SignalTile(
              icon: Icons.schedule_rounded,
              title: '总览刷新',
              value: '8 秒',
            ),
            _SignalTile(
              icon: Icons.settings_remote_rounded,
              title: '主操作',
              value: '主控台处置',
            ),
            FilledButton.tonalIcon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('立即更新总览'),
            ),
          ],
        ),
      ],
    );
  }
}

class _HomeHeaderBoard extends StatelessWidget {
  const _HomeHeaderBoard({
    required this.deviceStateAsync,
    required this.serviceHealthAsync,
    required this.deviceState,
    required this.serviceHealth,
  });

  final AsyncValue<DeviceStateInfo> deviceStateAsync;
  final AsyncValue<ServiceHealthInfo> serviceHealthAsync;
  final DeviceStateInfo? deviceState;
  final ServiceHealthInfo? serviceHealth;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      _SummaryCard(
        title: '当前设备',
        value: deviceState == null ? '等待上报' : _resolveDeviceLabel(deviceState!),
        supportingText: deviceState == null ? '尚未拿到设备摘要' : '设备状态已进入首页总览',
      ),
      _SummaryCard(
        title: '运行等级',
        value: deviceState?.alertTitle ?? '等待判断',
        supportingText: deviceState == null ? '等待错误码' : '由后端错误码映射得到',
      ),
      _SummaryCard(
        title: '数据新鲜度',
        value: _freshnessLabel(deviceStateAsync, deviceState),
        supportingText: _updatedAtLabel(deviceState),
      ),
      _SummaryCard(
        title: '服务巡检',
        value: _serviceLabel(serviceHealthAsync, serviceHealth),
        supportingText: serviceHealth?.freshnessLabel() ?? '尚未返回巡检结果',
        trailingLabel: 'LED ${deviceState?.ledLabel ?? '--'}',
      ),
    ];

    return Wrap(spacing: 14, runSpacing: 14, children: cards);
  }

  String _freshnessLabel(
    AsyncValue<DeviceStateInfo> value,
    DeviceStateInfo? deviceState,
  ) {
    return value.when(
      loading: () => '同步中',
      error: (_, _) => '同步失败',
      data: (_) => deviceState?.freshnessLabel() ?? '未收到上报',
    );
  }

  String _serviceLabel(
    AsyncValue<ServiceHealthInfo> value,
    ServiceHealthInfo? serviceHealth,
  ) {
    return value.when(
      loading: () => '巡检中',
      error: (_, _) => '巡检异常',
      data: (_) =>
          serviceHealth?.status.trim().toLowerCase() == 'up' ? '服务正常' : '服务异常',
    );
  }

  String _updatedAtLabel(DeviceStateInfo? deviceState) {
    final updatedAt = deviceState?.updatedAtTime;
    if (updatedAt == null) {
      return '未收到最近上报时间';
    }

    String twoDigits(int value) => value.toString().padLeft(2, '0');

    return '最近上报 ${updatedAt.year}-${twoDigits(updatedAt.month)}-${twoDigits(updatedAt.day)} '
        '${twoDigits(updatedAt.hour)}:${twoDigits(updatedAt.minute)}:${twoDigits(updatedAt.second)}';
  }
}

class _SignalTile extends StatelessWidget {
  const _SignalTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.supportingText,
    this.trailingLabel,
  });

  final String title;
  final String value;
  final String supportingText;
  final String? trailingLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: 212,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (trailingLabel == null)
              Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            else
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Text(
                    trailingLabel!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              supportingText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            colorScheme.surfaceContainerLowest.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.22),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: foregroundColor ?? colorScheme.onSurface,
        ),
      ),
    );
  }
}

String _resolveDeviceLabel(DeviceStateInfo deviceState) {
  final name = deviceState.deviceName.trim();
  return name.isEmpty ? deviceState.deviceId : name;
}
