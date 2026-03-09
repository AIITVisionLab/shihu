import 'package:flutter/material.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 认证页说明面板，承接认证链路说明和当前可用能力。
class AuthOverviewPanel extends StatelessWidget {
  /// 创建认证页说明面板。
  const AuthOverviewPanel({
    required this.isMockMode,
    required this.supportsRegister,
    required this.onFillDemo,
    super.key,
  });

  /// 当前是否为演示登录模式。
  final bool isMockMode;

  /// 当前是否支持真实注册。
  final bool supportsRegister;

  /// 点击“填充演示账号”后的回调。
  final VoidCallback onFillDemo;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CommonCard(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  colorScheme.primaryContainer.withValues(alpha: 0.9),
                  colorScheme.secondaryContainer.withValues(alpha: 0.92),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.hub_rounded,
                  size: 36,
                  color: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: 18),
                Text(
                  '设备监控认证工作台',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppCopy.authLoginOverview,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.65,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    _OverviewChip(
                      icon: Icons.layers_outlined,
                      label: AppCopy.authRestoreChip,
                    ),
                    _OverviewChip(
                      icon: Icons.security_update_good_outlined,
                      label: AppCopy.authUnauthorizedChip,
                    ),
                    _OverviewChip(
                      icon: Icons.cookie_outlined,
                      label: AppCopy.authTokenChip,
                    ),
                    if (supportsRegister)
                      _OverviewChip(
                        icon: Icons.person_add_alt_1_rounded,
                        label: AppCopy.authRegisterChip,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _OverviewSection(
            icon: Icons.device_hub_outlined,
            title: '统一服务来源',
            description:
                '认证与设备能力统一映射到当前线上设备服务，链路围绕登录、注册、会话检查、设备状态、补光控制和健康检查展开。',
          ),
          const SizedBox(height: 16),
          const _OverviewSection(
            icon: Icons.design_services_outlined,
            title: '软件工作台',
            description:
                '认证流程、状态反馈和工作台信息集中收敛在同一入口里，确保账号开通、登录恢复和失败提示都能在一页内闭环完成。',
          ),
          const SizedBox(height: 16),
          _OverviewSection(
            icon: isMockMode
                ? Icons.science_outlined
                : Icons.account_circle_outlined,
            title: isMockMode
                ? AppCopy.authMockModeTitle
                : AppCopy.authRegisterPanelTitle,
            description: isMockMode
                ? AppCopy.authMockAccountHint
                : AppCopy.authRegisterPanelDescription,
            footer: isMockMode
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.tonalIcon(
                      onPressed: onFillDemo,
                      icon: const Icon(Icons.auto_fix_high_rounded),
                      label: const Text(AppCopy.authFillDemoAccount),
                    ),
                  )
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '登录成功后会直接进入实时监控主控台，并依据 `/api/check-login` 的结果决定是否恢复访问。',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _OverviewChip extends StatelessWidget {
  const _OverviewChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({
    required this.icon,
    required this.title,
    required this.description,
    this.footer,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.36),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: colorScheme.secondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.65,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (footer != null) ...<Widget>[
                  const SizedBox(height: 14),
                  footer!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
