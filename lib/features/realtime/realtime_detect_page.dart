import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/realtime/realtime_detect_controller.dart';
import 'package:sickandflutter/shared/models/device_state_info.dart';
import 'package:sickandflutter/shared/widgets/common_button.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 实时监控页，对齐后端 `index.html` 的设备监控主控台。
class RealtimeDetectPage extends ConsumerStatefulWidget {
  /// 创建实时监控页。
  const RealtimeDetectPage({super.key});

  @override
  ConsumerState<RealtimeDetectPage> createState() => _RealtimeDetectPageState();
}

class _RealtimeDetectPageState extends ConsumerState<RealtimeDetectPage> {
  late final RealtimeDetectController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(realtimeDetectControllerProvider.notifier);
    Future<void>.microtask(_controller.startMonitoring);
  }

  @override
  void dispose() {
    _controller.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(realtimeDetectControllerProvider);
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('实时监控主控台')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _controller.refreshNow,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: <Widget>[
                  _MonitorTopBar(
                    currentUser:
                        authState.session?.user.displayName ??
                        authState.session?.user.account ??
                        '--',
                    state: state,
                    onRefresh: _controller.refreshNow,
                    onToggleAutoRefresh: _controller.setAutoRefreshEnabled,
                  ),
                  const SizedBox(height: 20),
                  _MonitorHeroSection(state: state),
                  const SizedBox(height: 20),
                  if (!state.hasDeviceState && state.isRefreshing)
                    const CommonCard(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      ),
                    )
                  else ...<Widget>[
                    _MetricsSection(deviceState: state.deviceState),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 900;
                        final controls = _MonitorControlsSection(
                          state: state,
                          onToggleLed: _handleToggleLed,
                        );
                        final guide = _StatusGuideSection(
                          deviceState: state.deviceState,
                        );

                        if (!isWide) {
                          return Column(
                            children: <Widget>[
                              controls,
                              const SizedBox(height: 20),
                              guide,
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(child: controls),
                            const SizedBox(width: 20),
                            Expanded(child: guide),
                          ],
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleToggleLed(bool ledOn) async {
    try {
      final message = await _controller.toggleLed(ledOn);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('$error')));
    }
  }
}

class _MonitorTopBar extends StatelessWidget {
  const _MonitorTopBar({
    required this.currentUser,
    required this.state,
    required this.onRefresh,
    required this.onToggleAutoRefresh,
  });

  final String currentUser;
  final RealtimeDetectState state;
  final Future<void> Function() onRefresh;
  final Future<void> Function(bool enabled) onToggleAutoRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CommonCard(
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: <Widget>[
          _TopPill(
            icon: Icons.person_outline_rounded,
            label: '当前用户：$currentUser',
          ),
          _TopPill(
            icon: Icons.cable_rounded,
            label: state.errorMessage == null ? '链路正常' : '链路异常',
            foregroundColor: state.errorMessage == null
                ? const Color(0xFF166534)
                : theme.colorScheme.error,
            backgroundColor: state.errorMessage == null
                ? const Color(0xFFE8F7EB)
                : theme.colorScheme.errorContainer,
          ),
          _TopPill(
            icon: Icons.schedule_rounded,
            label: '轮询间隔：${state.isAutoRefreshEnabled ? '3 秒' : '已暂停自动刷新'}',
          ),
          _TopPill(
            icon: Icons.update_rounded,
            label: '最近同步：${_formatDateTime(state.lastRefreshAt)}',
          ),
          Switch.adaptive(
            value: state.isAutoRefreshEnabled,
            onChanged: (value) {
              onToggleAutoRefresh(value);
            },
          ),
          Text(
            '自动刷新',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          CommonButton(
            label: '立即刷新',
            tone: CommonButtonTone.secondary,
            isLoading: state.isRefreshing,
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              onRefresh();
            },
          ),
        ],
      ),
    );
  }
}

class _TopPill extends StatelessWidget {
  const _TopPill({
    required this.icon,
    required this.label,
    this.foregroundColor,
    this.backgroundColor,
  });

  final IconData icon;
  final String label;
  final Color? foregroundColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveForeground = foregroundColor ?? const Color(0xFF344256);
    final effectiveBackground = backgroundColor ?? const Color(0xFFF3F7FC);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: effectiveBackground,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD8E2EF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 18, color: effectiveForeground),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: effectiveForeground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonitorHeroSection extends StatelessWidget {
  const _MonitorHeroSection({required this.state});

  final RealtimeDetectState state;

  @override
  Widget build(BuildContext context) {
    final deviceState = state.deviceState;
    final palette = _alertPalette(deviceState?.alertLevel);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF081120),
            Color(0xFF12305E),
            Color(0xFF2D7DD6),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 820;
            final summary = _HeroSummary(
              deviceState: deviceState,
              errorMessage: state.errorMessage,
            );
            final banner = _HeroStatusBanner(
              palette: palette,
              deviceState: deviceState,
            );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(flex: 3, child: summary),
                  const SizedBox(width: 20),
                  Expanded(flex: 2, child: banner),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[summary, const SizedBox(height: 20), banner],
            );
          },
        ),
      ),
    );
  }
}

class _HeroSummary extends StatelessWidget {
  const _HeroSummary({required this.deviceState, required this.errorMessage});

  final DeviceStateInfo? deviceState;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '后端设备状态主链路',
            style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          deviceState?.deviceName.trim().isNotEmpty == true
              ? deviceState!.deviceName
              : '等待设备状态上报',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          deviceState == null
              ? '当前页面会持续轮询 /api/status。若后端尚未收到设备上报，这里会先显示等待状态。'
              : '当前页面会持续轮询 /api/status，并依据错误码把设备状态映射为正常、预警和告警视图。',
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            _HeroInfoChip(
              label: '设备 ID：${_displayText(deviceState?.deviceId)}',
            ),
            _HeroInfoChip(
              label: '最近上报：${_formatDateTime(deviceState?.updatedAtTime)}',
            ),
            _HeroInfoChip(label: 'LED：${deviceState?.ledLabel ?? '--'}'),
          ],
        ),
        if (errorMessage != null) ...<Widget>[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF3C1218).withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFAB3144)),
            ),
            child: Text(
              errorMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFFFFD5D8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _HeroInfoChip extends StatelessWidget {
  const _HeroInfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
    );
  }
}

class _HeroStatusBanner extends StatelessWidget {
  const _HeroStatusBanner({required this.palette, required this.deviceState});

  final _AlertPalette palette;
  final DeviceStateInfo? deviceState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '运行状态',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: palette.backgroundColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              deviceState?.alertTitle ?? '等待设备上报',
              style: theme.textTheme.titleMedium?.copyWith(
                color: palette.foregroundColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            deviceState?.alertDescription ?? '尚未收到后端的设备状态上报，当前先保持等待视图。',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.7,
            ),
          ),
          const SizedBox(height: 18),
          _StatusMiniRow(label: '错误码', value: _displayErrorCode(deviceState)),
          const SizedBox(height: 12),
          _StatusMiniRow(label: 'LED 状态', value: deviceState?.ledLabel ?? '--'),
          const SizedBox(height: 12),
          _StatusMiniRow(label: '状态来源', value: '/api/status'),
        ],
      ),
    );
  }
}

class _StatusMiniRow extends StatelessWidget {
  const _StatusMiniRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 78,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricsSection extends StatelessWidget {
  const _MetricsSection({required this.deviceState});

  final DeviceStateInfo? deviceState;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      _MetricCard(
        icon: Icons.thermostat_rounded,
        title: '温度',
        value: deviceState?.formatMetric(
          deviceState?.temperature,
          deviceState?.temperatureUnit ?? '°C',
        ),
        helperText: '来自设备温度上报',
      ),
      _MetricCard(
        icon: Icons.water_drop_rounded,
        title: '湿度',
        value: deviceState?.formatMetric(
          deviceState?.humidity,
          deviceState?.humidityUnit ?? '%',
        ),
        helperText: '来自设备湿度上报',
      ),
      _MetricCard(
        icon: Icons.light_mode_rounded,
        title: '光照',
        value: deviceState?.formatMetric(
          deviceState?.light,
          deviceState?.lightUnit ?? 'Lux',
          fractionDigits: 0,
        ),
        helperText: '来自设备光照上报',
      ),
      _MetricCard(
        icon: Icons.sensors_rounded,
        title: 'MQ2',
        value: deviceState?.formatMetric(
          deviceState?.mq2,
          deviceState?.mq2Unit ?? 'ppm',
        ),
        helperText: '来自设备气体传感器上报',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 960;
        final medium = constraints.maxWidth >= 600;
        final columns = isWide ? 4 : (medium ? 2 : 1);
        final itemWidth =
            (constraints.maxWidth - ((columns - 1) * 16)) / columns;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: cards
              .map((item) => SizedBox(width: itemWidth, child: item))
              .toList(growable: false),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.helperText,
  });

  final IconData icon;
  final String title;
  final String? value;
  final String helperText;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            value ?? '--',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(helperText, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _MonitorControlsSection extends StatelessWidget {
  const _MonitorControlsSection({
    required this.state,
    required this.onToggleLed,
  });

  final RealtimeDetectState state;
  final Future<void> Function(bool ledOn) onToggleLed;

  @override
  Widget build(BuildContext context) {
    final deviceState = state.deviceState;

    return CommonCard(
      title: '运行明细与远程控制',
      subtitle: '设备状态来自 /api/status，LED 开关通过 /api/ops/led 提交。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _ControlRow(
            icon: Icons.memory_rounded,
            label: '设备名称',
            value: _displayText(deviceState?.deviceName),
          ),
          const SizedBox(height: 12),
          _ControlRow(
            icon: Icons.badge_rounded,
            label: '设备 ID',
            value: _displayText(deviceState?.deviceId),
          ),
          const SizedBox(height: 12),
          _ControlRow(
            icon: Icons.error_outline_rounded,
            label: '错误码',
            value: _displayErrorCode(deviceState),
          ),
          const SizedBox(height: 12),
          _ControlRow(
            icon: Icons.update_rounded,
            label: '更新时间',
            value: _formatDateTime(deviceState?.updatedAtTime),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FB),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD8E2EF)),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'LED 补光控制',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        deviceState == null
                            ? '当前还没有设备状态，暂时无法下发控制命令。'
                            : '后端返回 202 Accepted 后，前端会继续刷新并等待状态回写。',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Switch.adaptive(
                  value: deviceState?.ledOn ?? false,
                  onChanged: deviceState == null || state.isSubmittingLed
                      ? null
                      : (value) {
                          onToggleLed(value);
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlRow extends StatelessWidget {
  const _ControlRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3EAF4)),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusGuideSection extends StatelessWidget {
  const _StatusGuideSection({required this.deviceState});

  final DeviceStateInfo? deviceState;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: '状态说明',
      subtitle: '这一组说明与后端静态控制台保持一致，用于解释错误码展示语义。',
      child: Column(
        children: <Widget>[
          _GuideItem(
            icon: Icons.verified_outlined,
            title: '错误码 0',
            description: '系统运行正常，设备状态处于安全区间，可继续观察实时数据。',
            isActive: deviceState?.errorCode == 0,
          ),
          const SizedBox(height: 14),
          _GuideItem(
            icon: Icons.warning_amber_rounded,
            title: '错误码 1',
            description: '系统进入预警状态，建议人工复核当前设备环境和控制策略。',
            isActive: deviceState?.errorCode == 1,
          ),
          const SizedBox(height: 14),
          _GuideItem(
            icon: Icons.gpp_bad_rounded,
            title: '错误码 2',
            description: '系统进入严重告警状态，应优先处理设备异常或环境风险。',
            isActive: deviceState?.errorCode == 2,
          ),
          const SizedBox(height: 14),
          _GuideItem(
            icon: Icons.help_outline_rounded,
            title: '其他情况',
            description: '当前前端按未知状态展示，用于覆盖后端尚未定义或未返回的错误码。',
            isActive:
                deviceState == null ||
                deviceState?.alertLevel == DeviceAlertLevel.unknown,
          ),
        ],
      ),
    );
  }
}

class _GuideItem extends StatelessWidget {
  const _GuideItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.isActive,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive ? const Color(0xFF93C5FD) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFDBEAFE) : Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF2563EB)),
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
                const SizedBox(height: 6),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertPalette {
  const _AlertPalette({
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final Color backgroundColor;
  final Color foregroundColor;
}

_AlertPalette _alertPalette(DeviceAlertLevel? level) {
  switch (level) {
    case DeviceAlertLevel.safe:
      return const _AlertPalette(
        backgroundColor: Color(0xFFE8F7EB),
        foregroundColor: Color(0xFF166534),
      );
    case DeviceAlertLevel.warning:
      return const _AlertPalette(
        backgroundColor: Color(0xFFFFF4E5),
        foregroundColor: Color(0xFFB45309),
      );
    case DeviceAlertLevel.danger:
      return const _AlertPalette(
        backgroundColor: Color(0xFFFEEBEC),
        foregroundColor: Color(0xFFB91C1C),
      );
    case DeviceAlertLevel.unknown:
    case null:
      return const _AlertPalette(
        backgroundColor: Color(0xFFE5ECF5),
        foregroundColor: Color(0xFF475569),
      );
  }
}

String _displayText(String? value) {
  final normalizedValue = value?.trim() ?? '';
  return normalizedValue.isEmpty ? '--' : normalizedValue;
}

String _displayErrorCode(DeviceStateInfo? deviceState) {
  final errorCode = deviceState?.errorCode;
  if (errorCode == null) {
    return '--';
  }
  return '$errorCode';
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
