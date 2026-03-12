import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/core/network/api_exception.dart';
import 'package:sickandflutter/features/settings/widgets/settings_setting_row.dart';
import 'package:sickandflutter/shared/models/service_health_info.dart';
import 'package:sickandflutter/shared/widgets/common_button.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 设置页服务健康检查卡片。
class SettingsServiceHealthCard extends StatelessWidget {
  /// 创建服务健康检查卡片。
  const SettingsServiceHealthCard({
    required this.healthAsync,
    required this.onRefresh,
    super.key,
  });

  /// 健康检查异步状态。
  final AsyncValue<ServiceHealthInfo> healthAsync;

  /// 刷新回调。
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: AppCopy.settingsHealthTitle,
      subtitle: AppCopy.settingsHealthSubtitle,
      child: _ServiceHealthSection(
        healthAsync: healthAsync,
        onRefresh: onRefresh,
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
              AppCopy.settingsCheckingHealth,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
      error: (error, stackTrace) {
        final message = error is ApiException
            ? error.message
            : AppCopy.settingsHealthCheckFailed(error);
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
              label: AppCopy.settingsRecheck,
              tone: CommonButtonTone.secondary,
              icon: const Icon(Icons.refresh_rounded),
              onPressed: onRefresh,
            ),
          ],
        );
      },
      data: (healthInfo) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 540 ? 2 : 1;
                final itemWidth =
                    (constraints.maxWidth - ((columns - 1) * 12)) / columns;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: <Widget>[
                        _StatusBadge(
                          label: _serviceStatusLabel(healthInfo.status),
                          color: _serviceStatusColor(healthInfo.status),
                        ),
                        _StatusBadge(
                          label: healthInfo.freshnessLabel(),
                          color: healthInfo.isRecentlyChecked()
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFB45309),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: <Widget>[
                        SizedBox(
                          width: itemWidth,
                          child: SettingsSettingRow(
                            title: AppCopy.settingsHealthResponse,
                            value: healthInfo.responseText,
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: SettingsSettingRow(
                            title: AppCopy.settingsHealthCheckedAt,
                            value: _formatServerTime(healthInfo.checkedAt),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            CommonButton(
              label: AppCopy.refresh,
              tone: CommonButtonTone.secondary,
              icon: const Icon(Icons.refresh_rounded),
              onPressed: onRefresh,
            ),
          ],
        );
      },
    );
  }

  String _serviceStatusLabel(String value) {
    switch (value.trim().toLowerCase()) {
      case 'up':
        return AppCopy.settingsServiceUp;
      case 'down':
        return AppCopy.settingsServiceDown;
      default:
        return AppCopy.settingsServiceUnknown;
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
