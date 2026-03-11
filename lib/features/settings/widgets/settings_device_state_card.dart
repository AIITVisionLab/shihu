import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/shared/models/device_state_info.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 设备状态卡片。
class SettingsDeviceStateCard extends StatelessWidget {
  /// 创建设备状态卡片。
  const SettingsDeviceStateCard({
    required this.deviceStateAsync,
    required this.onRefresh,
    required this.onToggleLed,
    super.key,
  });

  /// 设备状态异步对象。
  final AsyncValue<DeviceStateInfo> deviceStateAsync;

  /// 刷新回调。
  final VoidCallback onRefresh;

  /// LED 开关回调。
  final Future<void> Function(DeviceStateInfo state, bool ledOn) onToggleLed;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: '设备状态',
      subtitle: '查看设备实时数据，并在状态完整时提交补光控制。',
      child: deviceStateAsync.when(
        loading: () => const _DeviceStateLoading(),
        error: (error, stackTrace) {
          final message = error is ApiException ? error.message : '$error';
          return _DeviceStateError(message: message, onRefresh: onRefresh);
        },
        data: (state) {
          final deviceLabel = state.deviceName.isEmpty
              ? state.deviceId
              : state.deviceName;
          final (alertBackground, alertForeground) = _statusColors(
            state.alertLevel,
          );
          final tiles = <Widget>[
            _DeviceMetricTile(
              label: '温度',
              value: state.formatMetric(
                state.temperature,
                state.temperatureUnit,
              ),
              supportingText: '设备温度传感器',
            ),
            _DeviceMetricTile(
              label: '湿度',
              value: state.formatMetric(state.humidity, state.humidityUnit),
              supportingText: '设备湿度传感器',
            ),
            _DeviceMetricTile(
              label: '光照',
              value: state.formatMetric(
                state.light,
                state.lightUnit,
                fractionDigits: 0,
              ),
              supportingText: '环境光照强度',
            ),
            _DeviceMetricTile(
              label: 'MQ2',
              value: state.formatMetric(state.mq2, state.mq2Unit),
              supportingText: '气体传感器浓度',
            ),
            _DeviceMetricTile(
              label: '状态码',
              value: state.errorCode == null ? '--' : '${state.errorCode}',
              supportingText: state.alertTitle,
            ),
            _DeviceMetricTile(
              label: 'LED 控制',
              value: state.ledLabel,
              supportingText: state.canControlLed ? '已具备远程控制条件' : '等待设备身份上报',
            ),
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _DeviceOverviewPanel(
                deviceLabel: deviceLabel,
                deviceId: state.deviceId,
                alertTitle: state.alertTitle,
                alertDescription: state.alertDescription,
                updatedAtLabel: _formatDateTime(state.updatedAtTime),
                freshnessLabel: state.freshnessLabel(),
                isFresh: state.isFresh(),
                alertBackground: alertBackground,
                alertForeground: alertForeground,
                canControlLed: state.canControlLed,
                ledOn: state.ledOn ?? false,
                onToggleLed: (value) => onToggleLed(state, value),
                onRefresh: onRefresh,
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 720
                      ? 3
                      : (constraints.maxWidth >= 420 ? 2 : 1);
                  final itemWidth =
                      (constraints.maxWidth - ((columns - 1) * 12)) / columns;

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: tiles
                        .map((tile) => SizedBox(width: itemWidth, child: tile))
                        .toList(growable: false),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DeviceStateLoading extends StatelessWidget {
  const _DeviceStateLoading();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        children: <Widget>[
          CircularProgressIndicator.adaptive(),
          SizedBox(height: 14),
          Text('正在拉取设备状态...'),
        ],
      ),
    );
  }
}

class _DeviceStateError extends StatelessWidget {
  const _DeviceStateError({required this.message, required this.onRefresh});

  final String message;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.error_outline_rounded, color: colorScheme.error),
              const SizedBox(width: 10),
              Text(
                '设备状态获取失败',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('重新拉取'),
          ),
        ],
      ),
    );
  }
}

class _DeviceOverviewPanel extends StatelessWidget {
  const _DeviceOverviewPanel({
    required this.deviceLabel,
    required this.deviceId,
    required this.alertTitle,
    required this.alertDescription,
    required this.updatedAtLabel,
    required this.freshnessLabel,
    required this.isFresh,
    required this.alertBackground,
    required this.alertForeground,
    required this.canControlLed,
    required this.ledOn,
    required this.onToggleLed,
    required this.onRefresh,
  });

  final String deviceLabel;
  final String deviceId;
  final String alertTitle;
  final String alertDescription;
  final String updatedAtLabel;
  final String freshnessLabel;
  final bool isFresh;
  final Color alertBackground;
  final Color alertForeground;
  final bool canControlLed;
  final bool ledOn;
  final ValueChanged<bool> onToggleLed;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.34),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 720;
          final info = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                spacing: 10,
                runSpacing: 10,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  Text(
                    deviceLabel.isEmpty ? '--' : deviceLabel,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: alertBackground,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      alertTitle,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: alertForeground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isFresh
                          ? const Color(0xFFE8F7EB)
                          : const Color(0xFFFFF4E5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      freshnessLabel,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: isFresh
                            ? const Color(0xFF166534)
                            : const Color(0xFFB45309),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                '设备 ID：${deviceId.isEmpty ? '--' : deviceId}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '最近上报：$updatedAtLabel',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                alertDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '设置页每 12 秒自动刷新这张卡片，用来判断当前设备是否还在稳定上报。',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
          final action = Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '补光控制',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  canControlLed ? '设备已允许直接下发 LED 指令。' : '等待后端返回设备身份后再开放控制。',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Switch.adaptive(
                      value: ledOn,
                      onChanged: canControlLed ? onToggleLed : null,
                    ),
                    Text(
                      ledOn ? '当前已开启' : '当前已关闭',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                TextButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('重新同步'),
                ),
              ],
            ),
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[info, const SizedBox(height: 16), action],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: info),
              const SizedBox(width: 16),
              SizedBox(width: 280, child: action),
            ],
          );
        },
      ),
    );
  }
}

class _DeviceMetricTile extends StatelessWidget {
  const _DeviceMetricTile({
    required this.label,
    required this.value,
    required this.supportingText,
  });

  final String label;
  final String value;
  final String supportingText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
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
    );
  }
}

(Color, Color) _statusColors(DeviceAlertLevel level) {
  switch (level) {
    case DeviceAlertLevel.safe:
      return (const Color(0xFFE8F7EB), const Color(0xFF166534));
    case DeviceAlertLevel.warning:
      return (const Color(0xFFFFF4E5), const Color(0xFFB45309));
    case DeviceAlertLevel.danger:
      return (const Color(0xFFFEEBEC), const Color(0xFFB91C1C));
    case DeviceAlertLevel.unknown:
      return (const Color(0xFFE5ECF5), const Color(0xFF475569));
  }
}

String _formatDateTime(DateTime? value) {
  if (value == null) {
    return '--';
  }

  String twoDigits(int input) => input.toString().padLeft(2, '0');

  final year = value.year;
  final month = twoDigits(value.month);
  final day = twoDigits(value.day);
  final hour = twoDigits(value.hour);
  final minute = twoDigits(value.minute);
  final second = twoDigits(value.second);
  return '$year-$month-$day $hour:$minute:$second';
}
