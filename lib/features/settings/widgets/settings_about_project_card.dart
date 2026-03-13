import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/shared/widgets/common_button.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';
import 'package:sickandflutter/shared/widgets/feature_surface.dart';

/// 设置页系统总览入口卡片。
class SettingsAboutProjectCard extends StatelessWidget {
  /// 创建项目说明卡片。
  const SettingsAboutProjectCard({required this.onOpenAbout, super.key});

  /// 打开系统总览页回调。
  final VoidCallback onOpenAbout;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: AppCopy.settingsProjectTitle,
      subtitle: '不清楚怎么操作时，从这里查看使用说明。',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final summary = FeatureInsetPanel(
            padding: const EdgeInsets.all(18),
            borderRadius: 24,
            accentColor: AppPalette.softLavender,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                _AboutHintRow(
                  icon: Icons.route_rounded,
                  title: '查看页面怎么用',
                  description: '帮助页会把总览、值守、视频和我的说清楚。',
                ),
                SizedBox(height: 14),
                _AboutHintRow(
                  icon: Icons.visibility_rounded,
                  title: '只保留常用内容',
                  description: '帮助页只展示你日常会用到的说明。',
                ),
              ],
            ),
          );
          final action = SizedBox(
            width: constraints.maxWidth < 760 ? double.infinity : 220,
            child: CommonButton(
              label: AppCopy.viewAboutProject,
              tone: CommonButtonTone.secondary,
              icon: const Icon(Icons.info_outline),
              onPressed: onOpenAbout,
            ),
          );

          if (constraints.maxWidth < 760) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[summary, const SizedBox(height: 14), action],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: summary),
              const SizedBox(width: 16),
              action,
            ],
          );
        },
      ),
    );
  }
}

class _AboutHintRow extends StatelessWidget {
  const _AboutHintRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppPalette.softLavender.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.52,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
