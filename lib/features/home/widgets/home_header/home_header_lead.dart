import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/features/device/application/device_status_view_data.dart';
import 'package:sickandflutter/features/device/domain/device_status.dart';
import 'package:sickandflutter/shared/widgets/feature_surface.dart';

/// 首页 Hero 左侧导语区。
class HomeHeaderLead extends StatelessWidget {
  /// 创建首页 Hero 左侧导语区。
  const HomeHeaderLead({
    required this.currentUser,
    required this.deviceStatus,
    required this.viewData,
    required this.onRefresh,
    super.key,
  });

  /// 当前用户。
  final String currentUser;

  /// 当前设备状态。
  final DeviceStatus? deviceStatus;

  /// 当前设备展示派生。
  final DeviceStatusViewData? viewData;

  /// 手动刷新回调。
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final deviceName = deviceStatus == null
        ? '等待设备连接'
        : resolveHomeDeviceLabel(deviceStatus!);
    final hasUser = currentUser.trim().isNotEmpty && currentUser != '--';
    final title = viewData?.alertTitle ?? '等待设备状态';
    final description =
        viewData?.alertDescription ?? '设备接入后，这里会显示当前判断、同步状态和补光建议。';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (hasUser) ...<Widget>[
          HomeHeaderMetaPill(label: currentUser),
          const SizedBox(height: 16),
        ],
        Text(
          '当前值守基线',
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.secondary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
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
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            HomeHeaderQuickPill(
              icon: Icons.sensors_outlined,
              label: deviceName,
              accentColor: AppPalette.softPine,
            ),
            HomeHeaderQuickPill(
              icon: Icons.timeline_rounded,
              label: deviceStatus == null
                  ? '等待第一条设备上报'
                  : viewData!.freshnessLabel,
              accentColor: AppPalette.mistMint,
            ),
          ],
        ),
        const SizedBox(height: 22),
        FeatureInsetPanel(
          padding: const EdgeInsets.all(20),
          borderRadius: 26,
          accentColor: AppPalette.mistMint,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final overview = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '当前基线',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    deviceName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    deviceStatus == null
                        ? '设备接入后会在这里补全状态、同步和处理建议。'
                        : viewData!.alertDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.58,
                    ),
                  ),
                ],
              );
              final actionGroup = Wrap(
                spacing: 12,
                runSpacing: 12,
                children: <Widget>[
                  FilledButton.icon(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('刷新总览'),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest.withValues(
                        alpha: 0.88,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.72,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.route_rounded,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '先看值守台',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              if (constraints.maxWidth < 560) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    overview,
                    const SizedBox(height: 16),
                    actionGroup,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: overview),
                  const SizedBox(width: 18),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: actionGroup,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 首页 Hero 轻量标签。
class HomeHeaderQuickPill extends StatelessWidget {
  /// 创建首页 Hero 轻量标签。
  const HomeHeaderQuickPill({
    required this.icon,
    required this.label,
    this.accentColor,
    super.key,
  });

  /// 图标。
  final IconData icon;

  /// 文案。
  final String label;

  /// 强调色。
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: (accentColor ?? colorScheme.surfaceContainerHigh).withValues(
          alpha: 0.24,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.72),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: accentColor ?? colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// 首页 Hero 用户标签。
class HomeHeaderMetaPill extends StatelessWidget {
  /// 创建首页 Hero 用户标签。
  const HomeHeaderMetaPill({required this.label, super.key});

  /// 文案。
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceBright.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.72),
        ),
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

/// 解析首页要显示的设备名称。
String resolveHomeDeviceLabel(DeviceStatus status) {
  final deviceName = status.deviceName.trim();
  if (deviceName.isNotEmpty) {
    return deviceName;
  }

  return '当前设备';
}
