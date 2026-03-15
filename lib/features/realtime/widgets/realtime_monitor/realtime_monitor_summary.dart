import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/features/device/application/device_status_view_data.dart';
import 'package:sickandflutter/features/device/domain/device_status.dart';
import 'package:sickandflutter/features/realtime/realtime_detect_controller.dart';
import 'package:sickandflutter/features/realtime/realtime_view_utils.dart';
import 'package:sickandflutter/shared/widgets/feature_surface.dart';

/// 值守 Hero 左侧摘要区。
class RealtimeMonitorSummary extends StatelessWidget {
  /// 创建值守 Hero 左侧摘要区。
  const RealtimeMonitorSummary({
    required this.state,
    required this.deviceStatus,
    required this.viewData,
    required this.errorMessage,
    required this.onRefresh,
    required this.onToggleAutoRefresh,
    super.key,
  });

  /// 值守状态。
  final RealtimeDetectState state;

  /// 当前设备状态。
  final DeviceStatus? deviceStatus;

  /// 当前设备展示派生。
  final DeviceStatusViewData? viewData;

  /// 错误信息。
  final String? errorMessage;

  /// 手动刷新回调。
  final Future<void> Function() onRefresh;

  /// 自动刷新开关回调。
  final Future<void> Function(bool enabled) onToggleAutoRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final deviceName = deviceStatus?.deviceName.trim().isNotEmpty == true
        ? deviceStatus!.deviceName
        : '等待设备状态上报';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            _RealtimeMetaChip(
              icon: Icons.monitor_heart_rounded,
              label: state.isAutoRefreshEnabled ? '自动更新中' : '手动刷新',
            ),
            _RealtimeMetaChip(
              icon: Icons.sensors_outlined,
              label: deviceStatus == null ? '等待设备接入' : '设备在线',
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          '当前值守',
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.secondary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          deviceName,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(
            deviceStatus == null ? '系统正在等待设备状态。' : '先看当前判断和最近同步，再决定是否处理补光。',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.58,
            ),
          ),
        ),
        const SizedBox(height: 18),
        FeatureInsetPanel(
          padding: const EdgeInsets.all(18),
          borderRadius: 26,
          accentColor: AppPalette.mistMint,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 640;
              final summary = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '当前判断',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    viewData?.alertTitle ?? '等待状态返回',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    deviceStatus == null
                        ? '设备接入后会在这里显示当前判断。'
                        : viewData!.alertDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.56,
                    ),
                  ),
                ],
              );
              final facts = _RealtimeFactGrid(
                deviceStatus: deviceStatus,
                viewData: viewData,
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    summary,
                    const SizedBox(height: 16),
                    facts,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(flex: 9, child: summary),
                  const SizedBox(width: 16),
                  Expanded(flex: 8, child: facts),
                ],
              );
            },
          ),
        ),
        if (errorMessage != null) ...<Widget>[
          const SizedBox(height: 16),
          FeatureInsetPanel(
            padding: const EdgeInsets.all(14),
            borderRadius: 18,
            backgroundColor: colorScheme.errorContainer,
            accentColor: colorScheme.error,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.error_outline_rounded,
                  color: colorScheme.onErrorContainer,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onErrorContainer,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        RealtimeHeroActionStrip(
          state: state,
          onRefresh: onRefresh,
          onToggleAutoRefresh: onToggleAutoRefresh,
        ),
      ],
    );
  }
}

class _RealtimeFactGrid extends StatelessWidget {
  const _RealtimeFactGrid({required this.deviceStatus, required this.viewData});

  final DeviceStatus? deviceStatus;
  final DeviceStatusViewData? viewData;

  @override
  Widget build(BuildContext context) {
    final facts = <({String label, String value, Color accent})>[
      (
        label: '最近同步',
        value: formatRealtimeTimestamp(deviceStatus?.updatedAtTime),
        accent: AppPalette.softPine,
      ),
      (
        label: '补光状态',
        value: viewData?.ledLabel ?? '待同步',
        accent: AppPalette.softLavender,
      ),
      (
        label: '状态判断',
        value: viewData?.alertTitle ?? '等待状态',
        accent: AppPalette.linenOlive,
      ),
      (
        label: '当前温度',
        value: viewData?.temperatureLabel ?? '--',
        accent: AppPalette.mistMint,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 320 ? 2 : 1;
        final itemWidth =
            (constraints.maxWidth - ((columns - 1) * 12)) / columns;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: facts
              .map(
                (item) => SizedBox(
                  width: itemWidth,
                  child: RealtimeFactTile(
                    label: item.label,
                    value: item.value,
                    accentColor: item.accent,
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

/// 值守 Hero 摘要指标项。
class RealtimeFactTile extends StatelessWidget {
  /// 创建值守 Hero 摘要指标项。
  const RealtimeFactTile({
    required this.label,
    required this.value,
    required this.accentColor,
    super.key,
  });

  /// 标题。
  final String label;

  /// 值文案。
  final String value;

  /// 强调色。
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FeatureInsetPanel(
      padding: const EdgeInsets.all(14),
      borderRadius: 18,
      accentColor: accentColor,
      shadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// 值守 Hero 操作条。
class RealtimeHeroActionStrip extends StatelessWidget {
  /// 创建值守 Hero 操作条。
  const RealtimeHeroActionStrip({
    required this.state,
    required this.onRefresh,
    required this.onToggleAutoRefresh,
    super.key,
  });

  /// 值守状态。
  final RealtimeDetectState state;

  /// 手动刷新回调。
  final Future<void> Function() onRefresh;

  /// 自动刷新开关回调。
  final Future<void> Function(bool enabled) onToggleAutoRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FeatureInsetPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: 22,
      accentColor: AppPalette.softLavender,
      shadow: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final summary = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '值守节奏',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '保持自动更新，必要时再手动刷新，不把操作放在页面最前面。',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.52,
                ),
              ),
            ],
          );

          final controls = Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLowest.withValues(
                    alpha: 0.92,
                  ),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Switch.adaptive(
                      value: state.isAutoRefreshEnabled,
                      onChanged: onToggleAutoRefresh,
                    ),
                    Text(
                      state.isAutoRefreshEnabled ? '自动更新中' : '已暂停自动更新',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: onRefresh,
                icon: state.isRefreshing
                    ? SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      )
                    : const Icon(Icons.refresh_rounded),
                label: Text(state.isRefreshing ? '刷新中' : '刷新'),
              ),
              RealtimeSyncChip(state: state),
            ],
          );

          if (constraints.maxWidth < 760) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[summary, const SizedBox(height: 12), controls],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: summary),
              const SizedBox(width: 16),
              Flexible(child: controls),
            ],
          );
        },
      ),
    );
  }
}

class _RealtimeMetaChip extends StatelessWidget {
  const _RealtimeMetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppPalette.softPine.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// 值守同步状态标签。
class RealtimeSyncChip extends StatelessWidget {
  /// 创建值守同步状态标签。
  const RealtimeSyncChip({required this.state, super.key});

  /// 值守状态。
  final RealtimeDetectState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final label = state.lastRefreshAt == null
        ? '等待同步'
        : state.isAutoRefreshEnabled
        ? '自动更新中'
        : '已停止自动更新';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppPalette.linenOlive.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
