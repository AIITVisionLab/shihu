import 'package:flutter/material.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';

/// 登录页辅助面板，仅在演示环境或异常服务地址时显示。
class AuthOverviewPanel extends StatelessWidget {
  /// 创建登录页辅助面板。
  const AuthOverviewPanel({
    required this.isMockMode,
    required this.isUsingCustomServiceConfig,
    required this.canResetServiceConfig,
    required this.onFillDemo,
    required this.onResetServiceConfig,
    super.key,
  });

  /// 当前是否为联调登录模式。
  final bool isMockMode;

  /// 当前是否使用了自定义服务配置。
  final bool isUsingCustomServiceConfig;

  /// 当前是否允许恢复默认服务配置。
  final bool canResetServiceConfig;

  /// 点击“填充联调账号”后的回调。
  final VoidCallback onFillDemo;

  /// 恢复默认服务配置。
  final Future<void> Function() onResetServiceConfig;

  @override
  Widget build(BuildContext context) {
    if (isMockMode) {
      return _MockAccessCard(onFillDemo: onFillDemo);
    }

    return _ServiceNoticeCard(
      isUsingCustomServiceConfig: isUsingCustomServiceConfig,
      canResetServiceConfig: canResetServiceConfig,
      onResetServiceConfig: onResetServiceConfig,
    );
  }
}

class _MockAccessCard extends StatelessWidget {
  const _MockAccessCard({required this.onFillDemo});

  final VoidCallback onFillDemo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _NoticeHeader(icon: Icons.auto_awesome_rounded, title: '体验模式'),
        const SizedBox(height: 8),
        Text(
          '可以一键填入演示账号，先看完整界面，再决定是否继续登录。',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.tonalIcon(
          onPressed: onFillDemo,
          icon: const Icon(Icons.auto_fix_high_rounded),
          label: const Text(AppCopy.authFillDemoAccount),
        ),
      ],
    );
  }
}

class _ServiceNoticeCard extends StatelessWidget {
  const _ServiceNoticeCard({
    required this.isUsingCustomServiceConfig,
    required this.canResetServiceConfig,
    required this.onResetServiceConfig,
  });

  final bool isUsingCustomServiceConfig;
  final bool canResetServiceConfig;
  final Future<void> Function() onResetServiceConfig;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final title = isUsingCustomServiceConfig ? '已切换到其他服务' : '当前使用默认服务';
    final description = isUsingCustomServiceConfig
        ? '如果这不是你主动切换的，可以先恢复默认配置，再继续登录。'
        : '当前正在使用标准连接配置，可以直接继续登录。';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _NoticeHeader(icon: Icons.info_outline_rounded, title: title),
        const SizedBox(height: 8),
        Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            _StatusPill(
              icon: isUsingCustomServiceConfig
                  ? Icons.swap_horiz_rounded
                  : Icons.check_circle_outline_rounded,
              label: isUsingCustomServiceConfig ? '已改动' : '默认配置',
            ),
            if (canResetServiceConfig)
              const _StatusPill(
                icon: Icons.restart_alt_rounded,
                label: '可一键恢复',
              ),
          ],
        ),
        if (canResetServiceConfig) ...<Widget>[
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () async {
              await onResetServiceConfig();
            },
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Text(AppCopy.authResetServiceConfig),
          ),
        ],
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.44),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoticeHeader extends StatelessWidget {
  const _NoticeHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
