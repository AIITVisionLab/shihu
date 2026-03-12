import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/shared/models/device_state_info.dart';

/// 首页顶部总览卡片。
class HomeHeaderCard extends StatelessWidget {
  /// 创建首页顶部总览卡片。
  const HomeHeaderCard({
    required this.currentUser,
    required this.deviceStateAsync,
    required this.onRefresh,
    super.key,
  });

  /// 当前用户。
  final String currentUser;

  /// 当前设备状态。
  final AsyncValue<DeviceStateInfo> deviceStateAsync;

  /// 手动刷新回调。
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final deviceState = deviceStateAsync.asData?.value;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colorScheme.surfaceContainerHigh.withValues(alpha: 0.96),
            colorScheme.surfaceContainer.withValues(alpha: 0.98),
          ],
        ),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final board = _SummaryBoard(deviceState: deviceState);
          final lead = _HomeHeaderLead(
            currentUser: currentUser,
            deviceState: deviceState,
            onRefresh: onRefresh,
          );

          if (constraints.maxWidth < 900) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[lead, const SizedBox(height: 16), board],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(flex: 12, child: lead),
              const SizedBox(width: 18),
              Expanded(flex: 7, child: board),
            ],
          );
        },
      ),
    );
  }
}

class _HomeHeaderLead extends StatelessWidget {
  const _HomeHeaderLead({
    required this.currentUser,
    required this.deviceState,
    required this.onRefresh,
  });

  final String currentUser;
  final DeviceStateInfo? deviceState;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final deviceName = deviceState == null
        ? '等待设备连接'
        : _resolveDeviceLabel(deviceState!);
    final hasUser = currentUser.trim().isNotEmpty && currentUser != '--';
    final title = deviceState?.alertTitle ?? '等待设备状态';
    final description =
        deviceState?.alertDescription ?? '设备接入后会自动显示当前状态，你只需要从这里进入下一步。';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (hasUser) _MetaPill(label: currentUser),
        if (hasUser) const SizedBox(height: 16),
        Text(
          title,
          style: theme.textTheme.headlineLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.58,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.monitor_heart_rounded,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      deviceName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      deviceState == null
                          ? '等待第一条设备上报。'
                          : deviceState!.freshnessLabel(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.tonalIcon(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('刷新总览'),
        ),
      ],
    );
  }
}

class _SummaryBoard extends StatelessWidget {
  const _SummaryBoard({required this.deviceState});

  final DeviceStateInfo? deviceState;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _SummaryCard(
          title: '最近同步',
          value: deviceState == null ? '等待数据' : deviceState!.freshnessLabel(),
        ),
        const SizedBox(height: 12),
        _SummaryCard(
          title: '补光状态',
          value: deviceState == null ? '待同步' : deviceState!.ledLabel,
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
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
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}

String _resolveDeviceLabel(DeviceStateInfo state) {
  final deviceName = state.deviceName.trim();
  if (deviceName.isNotEmpty) {
    return deviceName;
  }

  final deviceId = state.deviceId.trim();
  if (deviceId.isNotEmpty) {
    return deviceId;
  }

  return '未命名设备';
}
