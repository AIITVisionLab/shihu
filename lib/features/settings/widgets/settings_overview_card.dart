import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/features/device/application/device_status_view_data.dart';
import 'package:sickandflutter/features/device/domain/device_status.dart';
import 'package:sickandflutter/features/settings/widgets/settings_setting_row.dart';
import 'package:sickandflutter/shared/widgets/feature_surface.dart';

/// 设置页设备概览卡片。
class SettingsOverviewCard extends StatelessWidget {
  /// 创建设备概览卡片。
  const SettingsOverviewCard({
    required this.currentUser,
    required this.deviceStateAsync,
    super.key,
  });

  /// 当前用户名称。
  final String currentUser;

  /// 当前设备状态。
  final AsyncValue<DeviceStatus> deviceStateAsync;

  @override
  Widget build(BuildContext context) {
    return deviceStateAsync.when(
      loading: () => const _OverviewLoadingState(),
      error: (error, stackTrace) => const _OverviewErrorState(),
      data: (deviceState) {
        final viewData = DeviceStatusViewData.fromState(deviceState);

        return FeatureHeroCard(
          padding: const EdgeInsets.all(28),
          borderRadius: 36,
          accentColor: AppPalette.softPine,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final lead = _OverviewLead(
                deviceName: _resolveDeviceLabel(deviceState),
                alertTitle: viewData.alertTitle,
                alertDescription: viewData.alertDescription,
              );
              final board = _OverviewBoard(
                currentUser: currentUser,
                alertTitle: viewData.alertTitle,
                lastSync: _formatDateTime(deviceState.updatedAtTime),
                freshnessLabel: viewData.freshnessLabel,
                ledLabel: viewData.ledLabel,
              );

              if (constraints.maxWidth < 940) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[lead, const SizedBox(height: 18), board],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(flex: 11, child: lead),
                  const SizedBox(width: 20),
                  Expanded(flex: 10, child: board),
                ],
              );
            },
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) {
      return '未收到设备上报';
    }

    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.year}-$month-$day $hour:$minute';
  }
}

class _OverviewLoadingState extends StatelessWidget {
  const _OverviewLoadingState();

  @override
  Widget build(BuildContext context) {
    return FeatureHeroCard(
      padding: const EdgeInsets.all(28),
      borderRadius: 36,
      accentColor: AppPalette.softPine,
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(child: CircularProgressIndicator.adaptive()),
      ),
    );
  }
}

class _OverviewErrorState extends StatelessWidget {
  const _OverviewErrorState();

  @override
  Widget build(BuildContext context) {
    return FeatureHeroCard(
      padding: const EdgeInsets.all(28),
      borderRadius: 36,
      accentColor: AppPalette.softPine,
      child: const SettingsSettingRow(title: '当前状态', value: '设备信息暂不可用'),
    );
  }
}

class _OverviewLead extends StatelessWidget {
  const _OverviewLead({
    required this.deviceName,
    required this.alertTitle,
    required this.alertDescription,
  });

  final String deviceName;
  final String alertTitle;
  final String alertDescription;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          AppCopy.settingsOverviewTitle,
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.primary,
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
        Text(
          alertDescription,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.58,
          ),
        ),
        const SizedBox(height: 18),
        FeatureInsetPanel(
          padding: const EdgeInsets.all(18),
          borderRadius: 26,
          accentColor: AppPalette.mistMint,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppPalette.mistMint.withValues(alpha: 0.26),
                  borderRadius: BorderRadius.circular(18),
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
                      alertTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '先确认当前设备和最近同步，再处理下面的设置。',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OverviewBoard extends StatelessWidget {
  const _OverviewBoard({
    required this.currentUser,
    required this.alertTitle,
    required this.lastSync,
    required this.freshnessLabel,
    required this.ledLabel,
  });

  final String currentUser;
  final String alertTitle;
  final String lastSync;
  final String freshnessLabel;
  final String ledLabel;

  @override
  Widget build(BuildContext context) {
    return FeatureInsetPanel(
      padding: const EdgeInsets.all(18),
      borderRadius: 28,
      accentColor: AppPalette.softLavender,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 360 ? 2 : 1;
          final itemWidth =
              (constraints.maxWidth - ((columns - 1) * 12)) / columns;
          final items = <({String title, String value})>[
            (title: '当前账号', value: currentUser == '--' ? '未登录' : currentUser),
            (title: '当前状态', value: alertTitle),
            (title: '最近同步', value: lastSync),
            (title: '数据状态', value: freshnessLabel),
            (title: '补光状态', value: ledLabel),
          ];

          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: items
                .map(
                  (item) => SizedBox(
                    width: itemWidth,
                    child: SettingsSettingRow(
                      title: item.title,
                      value: item.value,
                    ),
                  ),
                )
                .toList(growable: false),
          );
        },
      ),
    );
  }
}

String _resolveDeviceLabel(DeviceStatus state) {
  final deviceName = state.deviceName.trim();
  if (deviceName.isNotEmpty) {
    return deviceName;
  }

  return '当前设备';
}
