import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/core/constants/app_constants.dart';
import 'package:sickandflutter/features/settings/settings_controller.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 首页，承载项目定位说明和主功能入口。
class HomePage extends ConsumerWidget {
  /// 创建首页。
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version =
        ref.watch(packageInfoProvider).asData?.value.version ?? '--';

    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: <Widget>[
                _HeroCard(version: version),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: <Widget>[
                    _HomeEntryCard(
                      icon: Icons.image_search_rounded,
                      title: '开始识别',
                      subtitle: '选择石斛叶片图片，走通单图识别主链路。',
                      onTap: () => context.pushNamed(AppRoutes.detect),
                    ),
                    _HomeEntryCard(
                      icon: Icons.videocam_rounded,
                      title: '实时监测',
                      subtitle: '预留摄像头识别链路，下一轮接入实时帧处理。',
                      onTap: () => context.pushNamed(AppRoutes.realtimeDetect),
                    ),
                    _HomeEntryCard(
                      icon: Icons.history_rounded,
                      title: '历史记录',
                      subtitle: '查看本地保存的识别结果与详情。',
                      onTap: () => context.pushNamed(AppRoutes.history),
                    ),
                    _HomeEntryCard(
                      icon: Icons.settings_rounded,
                      title: '设置',
                      subtitle: '管理服务地址、环境信息和本地数据。',
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
  const _HeroCard({required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFF2E7D32), Color(0xFF74A75D)],
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
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '跨平台识别演示',
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
              '当前基线已接入主题、路由、设置持久化、真实单图识别、本地历史记录和服务健康检查。下一轮继续补实时识别链路即可。',
              style: textTheme.titleMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.94),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                _Pill(label: '版本 $version'),
                const _Pill(label: 'Material 3'),
                const _Pill(label: 'Flutter Riverpod'),
                const _Pill(label: '本地历史记录'),
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
        color: Colors.white.withValues(alpha: 0.16),
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
    final cardWidth = width > 900 ? 520.0 : double.infinity;

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
                width: 52,
                height: 52,
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
