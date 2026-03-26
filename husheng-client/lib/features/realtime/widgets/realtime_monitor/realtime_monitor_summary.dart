import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/features/device/application/device_status_view_data.dart';
import 'package:sickandflutter/features/device/domain/device_status.dart';
import 'package:sickandflutter/features/realtime/realtime_detect_controller.dart';
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
    final summaryText = deviceStatus == null
        ? '系统正在等待设备状态。'
        : viewData!.alertDescription;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 620;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: 8,
              runSpacing: 8,
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
            const SizedBox(height: 10),
            Text(
              deviceName,
              style:
                  (isCompact
                          ? theme.textTheme.titleLarge
                          : theme.textTheme.headlineSmall)
                      ?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                        height: 1.12,
                      ),
            ),
            const SizedBox(height: 6),
            Text(
              summaryText,
              style:
                  (isCompact
                          ? theme.textTheme.bodySmall
                          : theme.textTheme.bodyMedium)
                      ?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.54,
                      ),
            ),
            const SizedBox(height: 12),
            _RealtimeFactGrid(deviceStatus: deviceStatus, viewData: viewData),
            if (errorMessage != null) ...<Widget>[
              const SizedBox(height: 12),
              FeatureInsetPanel(
                padding: const EdgeInsets.all(12),
                borderRadius: 16,
                backgroundColor: colorScheme.errorContainer,
                accentColor: colorScheme.error,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      Icons.error_outline_rounded,
                      color: colorScheme.onErrorContainer,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onErrorContainer,
                          height: 1.48,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            RealtimeHeroActionStrip(
              state: state,
              onRefresh: onRefresh,
              onToggleAutoRefresh: onToggleAutoRefresh,
            ),
          ],
        );
      },
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
        value: viewData?.freshnessLabel ?? '等待同步',
        accent: AppPalette.linenOlive,
      ),
      (
        label: '补光状态',
        value: viewData?.ledLabel ?? '待同步',
        accent: AppPalette.softLavender,
      ),
      (
        label: '状态判断',
        value: viewData?.alertTitle ?? '等待状态',
        accent: AppPalette.mistMint,
      ),
      (
        label: '当前温度',
        value: viewData?.temperatureLabel ?? '--',
        accent: AppPalette.softPine,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = switch (constraints.maxWidth) {
          >= 720 => 4,
          >= 360 => 2,
          _ => 1,
        };
        final gap = 8.0;
        final itemWidth =
            (constraints.maxWidth - ((columns - 1) * gap)) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
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
    return FeatureSummaryTile(
      label: label,
      value: value,
      accentColor: accentColor,
      padding: const EdgeInsets.all(12),
      borderRadius: 18,
      shadow: false,
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
      padding: const EdgeInsets.all(12),
      borderRadius: 18,
      accentColor: AppPalette.mistMint,
      shadow: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final summary = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '值守节奏',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '保持自动更新，必要时再手动刷新。',
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
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: AppPalette.blendOnPaper(
                    AppPalette.mistMint,
                    opacity: 0.12,
                    base: colorScheme.surfaceContainerLowest,
                  ),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppPalette.mistMint.withValues(alpha: 0.2),
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
                      state.isAutoRefreshEnabled ? '自动更新中' : '已暂停自动更新',
                      style: theme.textTheme.labelMedium?.copyWith(
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
              children: <Widget>[summary, const SizedBox(height: 10), controls],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppPalette.blendOnPaper(
          AppPalette.softPine,
          opacity: 0.12,
          base: colorScheme.surfaceContainerLowest,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppPalette.softPine.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 15, color: colorScheme.primary),
          const SizedBox(width: 7),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
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
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: AppPalette.linenOlive.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
