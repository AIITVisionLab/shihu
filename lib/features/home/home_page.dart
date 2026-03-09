import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/settings/device_state_repository.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';
import 'package:sickandflutter/shared/models/device_state_info.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 首页，作为培育管理平台的总览入口。
class HomePage extends ConsumerWidget {
  /// 创建首页。
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version =
        ref.watch(packageInfoProvider).asData?.value.version ?? '--';
    final authState = ref.watch(authControllerProvider);
    final deviceStateAsync = ref.watch(deviceStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: <Widget>[
                _HeroCard(
                  version: version,
                  currentUser:
                      authState.session?.user.displayName ??
                      authState.session?.user.account ??
                      '--',
                ),
                const SizedBox(height: 20),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 920;
                    final snapshot = _DeviceSnapshotCard(
                      deviceStateAsync: deviceStateAsync,
                      onRefresh: () => ref.invalidate(deviceStateProvider),
                    );
                    const capabilities = _CapabilityCard();

                    if (!isWide) {
                      return Column(
                        children: <Widget>[
                          capabilities,
                          const SizedBox(height: 20),
                          snapshot,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Expanded(child: capabilities),
                        const SizedBox(width: 20),
                        Expanded(child: snapshot),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: <Widget>[
                    _HomeEntryCard(
                      icon: Icons.monitor_heart_rounded,
                      title: AppCopy.homeRealtimeTitle,
                      subtitle: AppCopy.homeRealtimeSubtitle,
                      onTap: () => context.pushNamed(AppRoutes.realtimeDetect),
                    ),
                    _HomeEntryCard(
                      icon: Icons.image_search_rounded,
                      title: AppCopy.homeDetectTitle,
                      subtitle: AppCopy.homeDetectSubtitle,
                      onTap: () => context.pushNamed(AppRoutes.detect),
                    ),
                    _HomeEntryCard(
                      icon: Icons.history_rounded,
                      title: AppCopy.homeHistoryTitle,
                      subtitle: AppCopy.homeHistorySubtitle,
                      onTap: () => context.pushNamed(AppRoutes.history),
                    ),
                    _HomeEntryCard(
                      icon: Icons.settings_rounded,
                      title: AppCopy.homeSettingsTitle,
                      subtitle: AppCopy.homeSettingsSubtitle,
                      onTap: () => context.pushNamed(AppRoutes.settings),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.version, required this.currentUser});

  final String version;
  final String currentUser;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF081120),
            Color(0xFF12305E),
            Color(0xFF3AA6FF),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                AppCopy.homeCrossPlatformDemo,
                style: textTheme.labelLarge?.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              AppConstants.appName,
              style: textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppCopy.homeOverview,
              style: textTheme.titleMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.94),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                _Pill(label: AppCopy.homeVersionPill(version)),
                _Pill(label: '当前用户 $currentUser'),
                const _Pill(label: 'Spring Boot Session 登录'),
                const _Pill(label: '设备状态轮询'),
                const _Pill(label: 'LED 远程控制'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

class _CapabilityCard extends StatelessWidget {
  const _CapabilityCard();

  @override
  Widget build(BuildContext context) {
    return const CommonCard(
      title: '当前后端能力',
      subtitle: '以下能力已经在工作区后端中确认存在，并由 Flutter 前端直接对接。',
      child: Column(
        children: <Widget>[
          _CapabilityRow(
            icon: Icons.lock_outline_rounded,
            title: '登录会话',
            description:
                '通过 /api/login、/api/check-login 和 /api/logout 维护 HttpSession + Cookie 登录态。',
          ),
          SizedBox(height: 14),
          _CapabilityRow(
            icon: Icons.monitor_heart_outlined,
            title: '设备监控',
            description: '通过 /api/status 获取设备名称、环境数据、错误码、LED 状态和更新时间。',
          ),
          SizedBox(height: 14),
          _CapabilityRow(
            icon: Icons.toggle_on_outlined,
            title: '远程控制与排障',
            description: '通过 /api/ops/led 提交 LED 指令，并在设置页通过 /api/health 做健康检查。',
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2EAF4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 14),
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
                const SizedBox(height: 6),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceSnapshotCard extends StatelessWidget {
  const _DeviceSnapshotCard({
    required this.deviceStateAsync,
    required this.onRefresh,
  });

  final AsyncValue<DeviceStateInfo> deviceStateAsync;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: '设备摘要',
      subtitle: '首页直接展示当前设备上报快照，完整监控和控制请进入主控台。',
      child: deviceStateAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(child: CircularProgressIndicator.adaptive()),
        ),
        error: (error, stackTrace) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('设备状态获取失败：$error'),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('重新拉取'),
            ),
          ],
        ),
        data: (deviceState) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    deviceState.deviceName.trim().isEmpty
                        ? deviceState.deviceId
                        : deviceState.deviceName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _SnapshotStatusChip(deviceState: deviceState),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '最近上报：${_formatDateTime(deviceState.updatedAtTime)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                _MetricPill(
                  label:
                      '温度 ${deviceState.formatMetric(deviceState.temperature, deviceState.temperatureUnit)}',
                ),
                _MetricPill(
                  label:
                      '湿度 ${deviceState.formatMetric(deviceState.humidity, deviceState.humidityUnit)}',
                ),
                _MetricPill(
                  label:
                      '光照 ${deviceState.formatMetric(deviceState.light, deviceState.lightUnit, fractionDigits: 0)}',
                ),
                _MetricPill(
                  label:
                      'MQ2 ${deviceState.formatMetric(deviceState.mq2, deviceState.mq2Unit)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SnapshotStatusChip extends StatelessWidget {
  const _SnapshotStatusChip({required this.deviceState});

  final DeviceStateInfo deviceState;

  @override
  Widget build(BuildContext context) {
    final colors = _chipColors(deviceState.alertLevel);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        deviceState.alertTitle,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: colors.$2,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F7FC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCE6F2)),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

class _HomeEntryCard extends StatelessWidget {
  const _HomeEntryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cardWidth = width > 920 ? 540.0 : double.infinity;

    return SizedBox(
      width: cardWidth,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: CommonCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.arrow_forward_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

(Color, Color) _chipColors(DeviceAlertLevel level) {
  switch (level) {
    case DeviceAlertLevel.safe:
      return (const Color(0xFFE8F7EB), const Color(0xFF166534));
    case DeviceAlertLevel.warning:
      return (const Color(0xFFFFF4E5), const Color(0xFFB45309));
    case DeviceAlertLevel.danger:
      return (const Color(0xFFFEEBEC), const Color(0xFFB91C1C));
    case DeviceAlertLevel.unknown:
      return (const Color(0xFFE5ECF5), const Color(0xFF475569));
  }
}

String _formatDateTime(DateTime? value) {
  if (value == null) {
    return '--';
  }

  String twoDigits(int input) => input.toString().padLeft(2, '0');

  final year = value.year;
  final month = twoDigits(value.month);
  final day = twoDigits(value.day);
  final hour = twoDigits(value.hour);
  final minute = twoDigits(value.minute);
  final second = twoDigits(value.second);
  return '$year-$month-$day $hour:$minute:$second';
}
