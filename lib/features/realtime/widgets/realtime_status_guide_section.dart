import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/features/device/domain/device_status.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 实时监控页处理建议区。
class RealtimeStatusGuideSection extends StatelessWidget {
  /// 创建实时监控页处理建议区。
  const RealtimeStatusGuideSection({required this.deviceState, super.key});

  /// 当前设备状态。
  final DeviceStatus? deviceState;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: '处理建议',
      subtitle: '把当前状态翻译成更直接的处理优先级，值守时直接按优先级看。',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 720 ? 2 : 1;
          final itemWidth =
              (constraints.maxWidth - ((columns - 1) * 14)) / columns;

          return Wrap(
            spacing: 14,
            runSpacing: 14,
            children: <Widget>[
              SizedBox(
                width: itemWidth,
                child: _GuideItem(
                  icon: Icons.verified_outlined,
                  title: '正常',
                  description: '继续观察实时数据，暂时不需要额外处理。',
                  accentColor: AppPalette.softPine,
                  isActive: deviceState?.errorCode == 0,
                ),
              ),
              SizedBox(
                width: itemWidth,
                child: _GuideItem(
                  icon: Icons.warning_amber_rounded,
                  title: '注意',
                  description: '建议尽快人工复核，确认环境是否继续变化。',
                  accentColor: AppPalette.linenOlive,
                  isActive: deviceState?.errorCode == 1,
                ),
              ),
              SizedBox(
                width: itemWidth,
                child: _GuideItem(
                  icon: Icons.gpp_bad_rounded,
                  title: '严重',
                  description: '优先处理当前异常，避免继续影响设备运行。',
                  accentColor: const Color(0xFFCE9A90),
                  isActive: deviceState?.errorCode == 2,
                ),
              ),
              SizedBox(
                width: itemWidth,
                child: _GuideItem(
                  icon: Icons.help_outline_rounded,
                  title: '待确认',
                  description: '当前状态还不明确，先继续观察并等待下一次同步。',
                  accentColor: AppPalette.softLavender,
                  isActive:
                      deviceState == null ||
                      deviceState?.alertLevel == DeviceAlertLevel.unknown,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GuideItem extends StatelessWidget {
  const _GuideItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
    required this.isActive,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            isActive
                ? accentColor.withValues(alpha: 0.24)
                : colorScheme.surfaceContainerLowest.withValues(alpha: 0.96),
            colorScheme.surfaceContainerLow.withValues(alpha: 0.94),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isActive
              ? accentColor.withValues(alpha: 0.6)
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: isActive
            ? <BoxShadow>[
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.12),
                  blurRadius: 22,
                  offset: const Offset(0, 12),
                ),
              ]
            : const <BoxShadow>[],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: accentColor),
              ),
              const Spacer(),
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest.withValues(
                      alpha: 0.92,
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '当前',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.56,
            ),
          ),
        ],
      ),
    );
  }
}
