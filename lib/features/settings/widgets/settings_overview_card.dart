import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/features/device/application/device_status_view_data.dart';
import 'package:sickandflutter/features/device/domain/device_status.dart';
import 'package:sickandflutter/features/settings/widgets/settings_setting_row.dart';
import 'package:sickandflutter/shared/widgets/feature_surface.dart';
import 'package:sickandflutter/shared/widgets/workspace_layout.dart';

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
          padding: const EdgeInsets.all(18),
          borderRadius: 30,
          accentColor: AppPalette.softPine,
          child: WorkspaceTwoPane(
            breakpoint: 1020,
            primary: _OverviewLead(
              deviceName: _resolveDeviceLabel(deviceState),
              alertTitle: viewData.alertTitle,
              alertDescription: viewData.alertDescription,
              freshnessLabel: viewData.freshnessLabel,
            ),
            secondary: _OverviewBoard(
              currentUser: currentUser,
              alertTitle: viewData.alertTitle,
              lastSync: _formatDateTime(deviceState.updatedAtTime),
              freshnessLabel: viewData.freshnessLabel,
              ledLabel: viewData.ledLabel,
            ),
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
      padding: const EdgeInsets.all(18),
      borderRadius: 30,
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
      padding: const EdgeInsets.all(18),
      borderRadius: 30,
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
    required this.freshnessLabel,
  });

  final String deviceName;
  final String alertTitle;
  final String alertDescription;
  final String freshnessLabel;

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
          style: theme.textTheme.headlineSmall?.copyWith(
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
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            _OverviewPill(label: '当前状态', value: alertTitle),
            _OverviewPill(label: '数据状态', value: freshnessLabel),
          ],
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
          final gap = 10.0;
          final itemWidth =
              (constraints.maxWidth - ((columns - 1) * gap)) / columns;
          final items = <({String title, String value, Color accentColor})>[
            (
              title: '当前账号',
              value: currentUser == '--' ? '未登录' : currentUser,
              accentColor: AppPalette.softLavender,
            ),
            (
              title: '最近同步',
              value: lastSync,
              accentColor: AppPalette.linenOlive,
            ),
            (
              title: '数据状态',
              value: freshnessLabel,
              accentColor: AppPalette.softPine,
            ),
            (title: '补光状态', value: ledLabel, accentColor: AppPalette.mistMint),
          ];

          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: items
                .map(
                  (item) => SizedBox(
                    width: itemWidth,
                    child: _OverviewBoardTile(
                      title: item.title,
                      value: item.value,
                      accentColor: item.accentColor,
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

class _OverviewPill extends StatelessWidget {
  const _OverviewPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.14)),
      ),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
          children: <InlineSpan>[
            TextSpan(text: '$label  '),
            TextSpan(
              text: value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewBoardTile extends StatelessWidget {
  const _OverviewBoardTile({
    required this.title,
    required this.value,
    required this.accentColor,
  });

  final String title;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return FeatureSummaryTile(
      label: title,
      value: value,
      accentColor: accentColor,
      padding: const EdgeInsets.all(14),
      borderRadius: 20,
      shadow: false,
    );
  }
}
