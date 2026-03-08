import 'package:flutter/material.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 设置页运行环境概览卡片。
class SettingsOverviewCard extends StatelessWidget {
  /// 创建运行环境概览卡片。
  const SettingsOverviewCard({
    required this.buildFlavorLabel,
    required this.platformLabel,
    required this.versionLabel,
    super.key,
  });

  /// 当前构建环境文案。
  final String buildFlavorLabel;

  /// 当前运行平台文案。
  final String platformLabel;

  /// 当前应用版本文案。
  final String versionLabel;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: AppCopy.settingsOverviewTitle,
      subtitle: AppCopy.settingsOverviewSubtitle,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cardWidth = _responsiveCardWidth(
            maxWidth: constraints.maxWidth,
            minWidth: 220,
          );

          return Wrap(
            spacing: 14,
            runSpacing: 14,
            children: <Widget>[
              _OverviewMetricCard(
                width: cardWidth,
                title: AppCopy.settingsEnvironmentType,
                value: buildFlavorLabel,
                icon: Icons.layers_rounded,
              ),
              _OverviewMetricCard(
                width: cardWidth,
                title: AppCopy.settingsCurrentPlatform,
                value: platformLabel,
                icon: Icons.devices_rounded,
              ),
              _OverviewMetricCard(
                width: cardWidth,
                title: AppCopy.settingsAppVersion,
                value: versionLabel,
                icon: Icons.verified_outlined,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OverviewMetricCard extends StatelessWidget {
  const _OverviewMetricCard({
    required this.width,
    required this.title,
    required this.value,
    required this.icon,
  });

  final double width;
  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 14),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(value, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}

double _responsiveCardWidth({
  required double maxWidth,
  required double minWidth,
}) {
  if (maxWidth < minWidth * 2 + 14) {
    return maxWidth;
  }

  return (maxWidth - 14) / 2;
}
