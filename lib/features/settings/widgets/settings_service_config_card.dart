import 'package:flutter/material.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/config/service_endpoint_resolver.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/shared/models/app_settings.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 设置页服务配置卡片。
class SettingsServiceConfigCard extends StatelessWidget {
  /// 创建服务配置卡片。
  const SettingsServiceConfigCard({
    required this.envConfig,
    required this.settings,
    required this.serviceEndpoints,
    required this.onEditBaseUrl,
    super.key,
  });

  /// 当前环境配置。
  final EnvConfig envConfig;

  /// 当前设置。
  final AppSettings settings;

  /// 当前实际生效的服务端点。
  final ResolvedServiceEndpoints serviceEndpoints;

  /// 修改基础地址回调。
  final Future<void> Function()? onEditBaseUrl;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: AppCopy.settingsServiceConfigTitle,
      subtitle: envConfig.allowRiskySettings
          ? AppCopy.settingsServiceConfigEditable
          : AppCopy.settingsServiceConfigReadonly,
      child: Column(
        children: <Widget>[
          _ConfigPanel(
            icon: Icons.dns_rounded,
            title: AppCopy.settingsDeviceBaseUrl,
            value: serviceEndpoints.deviceBaseUrl,
            supportingText: '这是当前前端实际命中的设备服务根地址。',
            trailing: onEditBaseUrl == null
                ? null
                : TextButton.icon(
                    onPressed: () async {
                      await onEditBaseUrl?.call();
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text(AppCopy.settingsEdit),
                  ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 620;
              final connect = _ConfigPanel(
                icon: Icons.timer_outlined,
                title: AppCopy.settingsConnectTimeout,
                value: '${settings.connectTimeoutMs} ms',
                supportingText: '建立连接阶段的超时阈值。',
              );
              final receive = _ConfigPanel(
                icon: Icons.downloading_rounded,
                title: AppCopy.settingsReceiveTimeout,
                value: '${settings.receiveTimeoutMs} ms',
                supportingText: '等待服务响应体返回的超时阈值。',
              );

              if (isCompact) {
                return Column(
                  children: <Widget>[
                    connect,
                    const SizedBox(height: 12),
                    receive,
                  ],
                );
              }

              return Row(
                children: <Widget>[
                  Expanded(child: connect),
                  const SizedBox(width: 12),
                  Expanded(child: receive),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ConfigPanel extends StatelessWidget {
  const _ConfigPanel({
    required this.icon,
    required this.title,
    required this.value,
    required this.supportingText,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String value;
  final String supportingText;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.32),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 420 && trailing != null;
          final content = Row(
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
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      value,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      supportingText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                content,
                const SizedBox(height: 12),
                trailing!,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: content),
              if (trailing != null) ...<Widget>[
                const SizedBox(width: 12),
                trailing!,
              ],
            ],
          );
        },
      ),
    );
  }
}
