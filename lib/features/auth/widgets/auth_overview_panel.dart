import 'package:flutter/material.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';

/// 登录页辅助面板，仅在演示环境或异常服务地址时显示。
class AuthOverviewPanel extends StatelessWidget {
  /// 创建登录页辅助面板。
  const AuthOverviewPanel({
    required this.isMockMode,
    required this.currentDeviceBaseUrl,
    required this.isUsingCustomServiceConfig,
    required this.canResetServiceConfig,
    required this.onFillDemo,
    required this.onResetServiceConfig,
    super.key,
  });

  /// 当前是否为联调登录模式。
  final bool isMockMode;

  /// 当前设备服务地址。
  final String currentDeviceBaseUrl;

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
      currentDeviceBaseUrl: currentDeviceBaseUrl,
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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 360;

          return isCompact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _NoticeHeader(
                      icon: Icons.auto_awesome_rounded,
                      title: '演示环境',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '当前页面使用演示账号入口。',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: onFillDemo,
                      icon: const Icon(Icons.auto_fix_high_rounded),
                      label: const Text(AppCopy.authFillDemoAccount),
                    ),
                  ],
                )
              : Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _NoticeHeader(
                            icon: Icons.auto_awesome_rounded,
                            title: '演示环境',
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '当前页面使用演示账号入口。',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.tonalIcon(
                      onPressed: onFillDemo,
                      icon: const Icon(Icons.auto_fix_high_rounded),
                      label: const Text(AppCopy.authFillDemoAccount),
                    ),
                  ],
                );
        },
      ),
    );
  }
}

class _ServiceNoticeCard extends StatelessWidget {
  const _ServiceNoticeCard({
    required this.currentDeviceBaseUrl,
    required this.isUsingCustomServiceConfig,
    required this.canResetServiceConfig,
    required this.onResetServiceConfig,
  });

  final String currentDeviceBaseUrl;
  final bool isUsingCustomServiceConfig;
  final bool canResetServiceConfig;
  final Future<void> Function() onResetServiceConfig;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final title = isUsingCustomServiceConfig ? '地址已改动' : '默认地址已恢复';
    final description = isUsingCustomServiceConfig
        ? '如果这不是你的操作，请先恢复默认值再继续登录。'
        : '当前已经恢复到默认服务地址，可以继续登录。';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.58,
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: SelectableText(
              currentDeviceBaseUrl,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
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
