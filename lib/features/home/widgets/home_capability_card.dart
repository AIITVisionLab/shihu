import 'package:flutter/material.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 首页能力概览卡片。
class HomeCapabilityCard extends StatelessWidget {
  /// 创建首页能力概览卡片。
  const HomeCapabilityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <({IconData icon, String title, String description})>[
      (
        icon: Icons.lock_outline_rounded,
        title: '账号值守',
        description: '登录、注册、会话恢复和安全退出。',
      ),
      (
        icon: Icons.monitor_heart_outlined,
        title: '环境监测',
        description: '查看温湿度、光照、MQ2、错误码和上报时间。',
      ),
      (
        icon: Icons.toggle_on_outlined,
        title: '补光执行',
        description: '在主控台和设置页下发 LED 控制并等待回写。',
      ),
      (
        icon: Icons.rule_folder_outlined,
        title: '运行巡检',
        description: '检查服务健康、当前设置和本机记住账号。',
      ),
    ];

    return CommonCard(
      title: '值守范围',
      subtitle: '首页只保留已经接通的后台能力。',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 720 ? 2 : 1;
          final itemWidth =
              (constraints.maxWidth - ((columns - 1) * 14)) / columns;

          return Wrap(
            spacing: 14,
            runSpacing: 14,
            children: items
                .map(
                  (item) => SizedBox(
                    width: itemWidth,
                    child: _CapabilityTile(
                      icon: item.icon,
                      title: item.title,
                      description: item.description,
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

class _CapabilityTile extends StatelessWidget {
  const _CapabilityTile({
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
