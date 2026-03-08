import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/core/utils/platform_utils.dart';
import 'package:sickandflutter/features/history/history_repository.dart';
import 'package:sickandflutter/features/settings/service_health_repository.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';
import 'package:sickandflutter/shared/models/app_enums.dart';
import 'package:sickandflutter/shared/models/service_health_info.dart';
import 'package:sickandflutter/shared/widgets/common_button.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';
import 'package:sickandflutter/shared/widgets/loading_view.dart';

/// 设置页，负责展示环境信息和管理本地配置。
class SettingsPage extends ConsumerWidget {
  /// 创建设置页。
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsControllerProvider);
    final packageInfo = ref.watch(packageInfoProvider).asData?.value;
    final envConfig = ref.watch(envConfigProvider);
    final serviceHealthAsync = ref.watch(serviceHealthProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: SafeArea(
        child: settingsAsync.when(
          loading: () => const LoadingView(message: '正在加载设置...'),
          error: (error, stackTrace) => Center(child: Text('设置加载失败：$error')),
          data: (settings) {
            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: <Widget>[
                    CommonCard(
                      title: '运行环境',
                      child: Column(
                        children: <Widget>[
                          _SettingRow(
                            title: '环境类型',
                            value: settings.buildFlavor.label,
                          ),
                          const SizedBox(height: 12),
                          _SettingRow(
                            title: '当前平台',
                            value: currentPlatformLabel(),
                          ),
                          const SizedBox(height: 12),
                          _SettingRow(
                            title: '应用版本',
                            value: packageInfo == null
                                ? '--'
                                : '${packageInfo.version}+${packageInfo.buildNumber}',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    CommonCard(
                      title: '服务配置',
                      subtitle: envConfig.allowRiskySettings
                          ? '开发和测试环境允许调整服务地址。'
                          : '正式环境默认隐藏高风险配置项。',
                      child: Column(
                        children: <Widget>[
                          _SettingRow(
                            title: 'Base URL',
                            value: settings.baseUrl,
                            trailing: envConfig.allowRiskySettings
                                ? TextButton(
                                    onPressed: () async {
                                      final nextValue =
                                          await _showBaseUrlDialog(
                                            context,
                                            initialValue: settings.baseUrl,
                                          );
                                      if (nextValue == null ||
                                          nextValue.isEmpty) {
                                        return;
                                      }

                                      await ref
                                          .read(
                                            settingsControllerProvider.notifier,
                                          )
                                          .updateBaseUrl(nextValue);
                                    },
                                    child: const Text('修改'),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 12),
                          _SettingRow(
                            title: '连接超时',
                            value: '${settings.connectTimeoutMs} ms',
                          ),
                          const SizedBox(height: 12),
                          _SettingRow(
                            title: '接收超时',
                            value: '${settings.receiveTimeoutMs} ms',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    CommonCard(
                      title: '服务健康检查',
                      subtitle: '用于联调和排障，可手动刷新当前服务状态。',
                      child: _ServiceHealthSection(
                        healthAsync: serviceHealthAsync,
                        onRefresh: () => ref.invalidate(serviceHealthProvider),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CommonCard(
                      title: '本地数据',
                      child: Column(
                        children: <Widget>[
                          CommonButton(
                            label: '清空历史记录',
                            tone: CommonButtonTone.danger,
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: const Text('清空历史记录'),
                                  content: const Text('该操作不可恢复，是否继续？'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => Navigator.of(
                                        dialogContext,
                                      ).pop(false),
                                      child: const Text('取消'),
                                    ),
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.of(dialogContext).pop(true),
                                      child: const Text('确认'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed != true) {
                                return;
                              }

                              await ref
                                  .read(historyControllerProvider.notifier)
                                  .clearAll();
                              if (!context.mounted) {
                                return;
                              }
                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  const SnackBar(content: Text('历史记录已清空。')),
                                );
                            },
                          ),
                          const SizedBox(height: 12),
                          CommonButton(
                            label: '恢复默认设置',
                            tone: CommonButtonTone.secondary,
                            icon: const Icon(Icons.restart_alt_rounded),
                            onPressed: () async {
                              await ref
                                  .read(settingsControllerProvider.notifier)
                                  .reset();
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    CommonCard(
                      title: '项目说明',
                      child: CommonButton(
                        label: '查看关于项目',
                        tone: CommonButtonTone.secondary,
                        icon: const Icon(Icons.info_outline),
                        onPressed: () => context.pushNamed(AppRoutes.about),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<String?> _showBaseUrlDialog(
    BuildContext context, {
    required String initialValue,
  }) async {
    final controller = TextEditingController(text: initialValue);

    return showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('修改 Base URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '例如：http://127.0.0.1:8080',
          ),
          autofocus: true,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}

class _ServiceHealthSection extends StatelessWidget {
  const _ServiceHealthSection({
    required this.healthAsync,
    required this.onRefresh,
  });

  final AsyncValue<ServiceHealthInfo> healthAsync;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return healthAsync.when(
      loading: () => Row(
        children: <Widget>[
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '正在检查服务状态...',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
      error: (error, stackTrace) {
        final message = error is ApiException
            ? error.message
            : '服务健康检查失败：$error';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            CommonButton(
              label: '重新检查',
              tone: CommonButtonTone.secondary,
              icon: const Icon(Icons.refresh_rounded),
              onPressed: onRefresh,
            ),
          ],
        );
      },
      data: (healthInfo) {
        return Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                _StatusBadge(
                  label: _serviceStatusLabel(healthInfo.status),
                  color: _serviceStatusColor(healthInfo.status),
                ),
                const SizedBox(width: 10),
                _StatusBadge(
                  label: _modelStatusLabel(healthInfo.modelStatus),
                  color: _modelStatusColor(healthInfo.modelStatus),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('刷新'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _SettingRow(title: '服务名称', value: healthInfo.serviceName),
            const SizedBox(height: 12),
            _SettingRow(title: '服务版本', value: healthInfo.serviceVersion),
            const SizedBox(height: 12),
            _SettingRow(
              title: '服务时间',
              value: _formatServerTime(healthInfo.serverTime),
            ),
          ],
        );
      },
    );
  }

  String _serviceStatusLabel(String value) {
    switch (value.trim().toLowerCase()) {
      case 'up':
        return '服务正常';
      case 'down':
        return '服务不可用';
      default:
        return '服务未知';
    }
  }

  String _modelStatusLabel(String value) {
    switch (value.trim().toLowerCase()) {
      case 'ready':
        return '模型就绪';
      case 'loading':
        return '模型加载中';
      case 'error':
        return '模型异常';
      default:
        return '模型未知';
    }
  }

  Color _serviceStatusColor(String value) {
    switch (value.trim().toLowerCase()) {
      case 'up':
        return const Color(0xFF2E7D32);
      case 'down':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color _modelStatusColor(String value) {
    switch (value.trim().toLowerCase()) {
      case 'ready':
        return const Color(0xFF2E7D32);
      case 'loading':
        return const Color(0xFFEF6C00);
      case 'error':
        return const Color(0xFFC62828);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _formatServerTime(String rawValue) {
    final dateTime = DateTime.tryParse(rawValue);
    if (dateTime == null) {
      return rawValue.isEmpty ? '--' : rawValue;
    }

    final localDateTime = dateTime.toLocal();
    final month = localDateTime.month.toString().padLeft(2, '0');
    final day = localDateTime.day.toString().padLeft(2, '0');
    final hour = localDateTime.hour.toString().padLeft(2, '0');
    final minute = localDateTime.minute.toString().padLeft(2, '0');
    final second = localDateTime.second.toString().padLeft(2, '0');
    return '${localDateTime.year}-$month-$day $hour:$minute:$second';
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.title, required this.value, this.trailing});

  final String title;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              SelectableText(value),
            ],
          ),
        ),
        if (trailing != null) ...<Widget>[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
