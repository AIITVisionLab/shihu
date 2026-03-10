import 'package:flutter/material.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 首页能力概览卡片。
class HomeCapabilityCard extends StatelessWidget {
  /// 创建首页能力概览卡片。
  const HomeCapabilityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonCard(
      title: '当前可用能力',
      subtitle: '以下链路已经稳定接入统一服务，可直接用于日常值守与排障。',
      child: Column(
        children: <Widget>[
          _CapabilityRow(
            icon: Icons.lock_outline_rounded,
            title: '认证会话',
            description: '支持登录、账号开通、会话校验与安全退出，保证设备权限按账号闭环管理。',
          ),
          SizedBox(height: 14),
          _CapabilityRow(
            icon: Icons.monitor_heart_outlined,
            title: '设备监控',
            description: '统一呈现设备名称、温湿度、光照、MQ2、告警等级、补光状态和最近更新时间。',
          ),
          SizedBox(height: 14),
          _CapabilityRow(
            icon: Icons.toggle_on_outlined,
            title: '运维控制',
            description: '支持补光控制、状态回写等待与服务健康巡检，减少来回切页操作。',
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.34),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 340;
          final iconBox = Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: colorScheme.primary),
          );
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[iconBox, const SizedBox(height: 14), content],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              iconBox,
              const SizedBox(width: 16),
              Expanded(child: content),
            ],
          );
        },
      ),
    );
  }
}
