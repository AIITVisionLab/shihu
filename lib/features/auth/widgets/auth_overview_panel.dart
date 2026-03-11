import 'package:flutter/material.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';

/// 认证页说明面板，承接认证链路说明和当前可用能力。
class AuthOverviewPanel extends StatelessWidget {
  /// 创建认证页说明面板。
  const AuthOverviewPanel({
    required this.isMockMode,
    required this.supportsRegister,
    required this.currentDeviceBaseUrl,
    required this.isUsingCustomServiceConfig,
    required this.onFillDemo,
    super.key,
  });

  /// 当前是否为联调登录模式。
  final bool isMockMode;

  /// 当前是否支持真实注册。
  final bool supportsRegister;

  /// 当前设备服务地址。
  final String currentDeviceBaseUrl;

  /// 当前是否使用了自定义服务配置。
  final bool isUsingCustomServiceConfig;

  /// 点击“填充联调账号”后的回调。
  final VoidCallback onFillDemo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x0C172019),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.admin_panel_settings_outlined,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '登录说明',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '这是后台软件的统一认证入口。',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _InfoGroup(
              title: '当前接入',
              items: <_InfoItemData>[
                _InfoItemData(
                  label: '认证方式',
                  value: 'HttpSession + JSESSIONID',
                  footnote: '与 `origin/web` 后端保持一致。',
                ),
                _InfoItemData(
                  label: AppCopy.authDeviceServiceLabel,
                  value: currentDeviceBaseUrl,
                  footnote: isUsingCustomServiceConfig
                      ? AppCopy.authCustomServiceConfigHint
                      : AppCopy.authDefaultServiceConfigHint,
                ),
              ],
            ),
            const SizedBox(height: 18),
            _InfoGroup(
              title: '登录后行为',
              items: const <_InfoItemData>[
                _InfoItemData(
                  label: '会话保持',
                  value: '自动恢复',
                  footnote: '重新打开应用时会先检查当前会话是否仍然有效。',
                ),
                _InfoItemData(
                  label: '进入页面',
                  value: '主控台',
                  footnote: '登录成功后直接进入实时监控主控台。',
                ),
              ],
            ),
            const SizedBox(height: 18),
            _InfoGroup(
              title: isMockMode
                  ? AppCopy.authMockModeTitle
                  : AppCopy.authRegisterPanelTitle,
              items: <_InfoItemData>[
                _InfoItemData(
                  label: isMockMode ? '模式说明' : '注册说明',
                  value: isMockMode ? '演示环境' : '在线开通',
                  footnote: isMockMode
                      ? AppCopy.authMockAccountHint
                      : AppCopy.authRegisterPanelDescription,
                ),
              ],
              trailing: isMockMode
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton.tonalIcon(
                        onPressed: onFillDemo,
                        icon: const Icon(Icons.auto_fix_high_rounded),
                        label: const Text(AppCopy.authFillDemoAccount),
                      ),
                    )
                  : _ModeTagRow(supportsRegister: supportsRegister),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoGroup extends StatelessWidget {
  const _InfoGroup({required this.title, required this.items, this.trailing});

  final String title;
  final List<_InfoItemData> items;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: EdgeInsets.only(
                bottom: item == items.last && trailing == null ? 0 : 14,
              ),
              child: _InfoItem(item: item),
            ),
          ),
          ...(trailing == null ? const <Widget>[] : <Widget>[trailing!]),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.item});

  final _InfoItemData item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          item.label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        SelectableText(
          item.value,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          item.footnote,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _ModeTagRow extends StatelessWidget {
  const _ModeTagRow({required this.supportsRegister});

  final bool supportsRegister;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: <Widget>[
        _TagChip(label: AppCopy.authRestoreChip),
        _TagChip(label: AppCopy.authUnauthorizedChip),
        _TagChip(label: AppCopy.authSessionChip),
        if (supportsRegister) _TagChip(label: AppCopy.authRegisterChip),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

class _InfoItemData {
  const _InfoItemData({
    required this.label,
    required this.value,
    required this.footnote,
  });

  final String label;
  final String value;
  final String footnote;
}
