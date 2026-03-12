import 'package:flutter/material.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/shared/widgets/common_button.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

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
      subtitle: '需要确认平台定位、业务闭环或指标目标时，从这里进入系统概览。',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final summary = Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerLowest.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Text(
              '聚焦环境监测、风险预警、远程调控和排障链路，不再把说明页做成宣传页。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
          final action = CommonButton(
            label: AppCopy.viewAboutProject,
            tone: CommonButtonTone.secondary,
            icon: const Icon(Icons.info_outline),
            onPressed: onOpenAbout,
          );

          if (constraints.maxWidth < 760) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[summary, const SizedBox(height: 14), action],
            );
          }

          return Row(
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
