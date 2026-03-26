import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/features/device/application/device_status_view_data.dart';
import 'package:sickandflutter/features/device/domain/device_status.dart';

/// 首页 Hero 左侧导语区。
class HomeHeaderLead extends StatelessWidget {
  /// 创建首页 Hero 左侧导语区。
  const HomeHeaderLead({
    required this.deviceStatus,
    required this.viewData,
    required this.onRefresh,
    super.key,
  });

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
    final title = viewData?.alertTitle ?? '等待设备状态';
    final description =
        viewData?.alertDescription ?? '设备接入后，这里会显示当前判断、同步状态和补光建议。';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '当前值守基线',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.secondary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
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
              description,
              style:
                  (isCompact
                          ? theme.textTheme.bodySmall
                          : theme.textTheme.bodyMedium)
                      ?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.56,
                      ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
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
                HomeHeaderQuickPill(
                  icon: Icons.lightbulb_outline_rounded,
                  label: deviceStatus == null ? '补光待同步' : viewData!.ledLabel,
                  accentColor: AppPalette.softLavender,
                ),
                HomeHeaderActionPill(onPressed: onRefresh),
              ],
            ),
          ],
        );
      },
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
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: (accentColor ?? colorScheme.surfaceContainerHigh).withValues(
          alpha: 0.2,
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.62),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 15, color: accentColor ?? colorScheme.primary),
          const SizedBox(width: 7),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// 首页 Hero 刷新操作标签。
class HomeHeaderActionPill extends StatelessWidget {
  /// 创建首页 Hero 刷新操作标签。
  const HomeHeaderActionPill({required this.onPressed, super.key});

  /// 点击回调。
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: AppPalette.blendOnPaper(
              AppPalette.pineGreen,
              opacity: 0.14,
              base: colorScheme.surfaceContainerLowest,
            ),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppPalette.pineGreen.withValues(alpha: 0.24),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.refresh_rounded, size: 15, color: AppPalette.deepPine),
              const SizedBox(width: 7),
              Text(
                '刷新总览',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppPalette.deepPine,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
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
