import 'package:flutter/material.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 首页能力概览卡片。
class HomeCapabilityCard extends StatelessWidget {
  /// 创建首页能力概览卡片。
  const HomeCapabilityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: '值守范围',
      subtitle: '当前版本只保留已经对接后端的后台能力，不展示未接通模块。',
      child: Column(
        children: const <Widget>[
          _CapabilityRow(
            icon: Icons.lock_outline_rounded,
            title: '账号值守',
            description: '登录、注册、会话恢复和安全退出。',
          ),
          SizedBox(height: 14),
          _CapabilityRow(
            icon: Icons.monitor_heart_outlined,
            title: '环境监测',
            description: '查看温湿度、光照、MQ2、错误码和上报时间。',
          ),
          SizedBox(height: 14),
          _CapabilityRow(
            icon: Icons.toggle_on_outlined,
            title: '补光执行',
            description: '在主控台和设置页下发 LED 控制并等待回写。',
          ),
          SizedBox(height: 14),
          _CapabilityRow(
            icon: Icons.rule_folder_outlined,
            title: '运行巡检',
            description: '检查服务健康、当前设置和本机记住账号。',
          ),
        ],
      ),
    );
  }
}

class _CapabilityRow extends StatelessWidget {
  const _CapabilityRow({
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
        color: colorScheme.surfaceContainerLow.withValues(alpha: 0.46),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
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
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withValues(alpha: 0.62),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '可用',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
