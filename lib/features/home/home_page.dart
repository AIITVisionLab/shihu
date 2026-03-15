import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/app/app_workspace_destination.dart';
import 'package:sickandflutter/app/routes.dart';
import 'package:sickandflutter/app/widgets/app_workspace_scaffold.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/features/auth/application/current_user_label_provider.dart';
import 'package:sickandflutter/features/home/application/home_overview_device_status_provider.dart';
import 'package:sickandflutter/features/home/widgets/home_action_track_card.dart';
import 'package:sickandflutter/features/home/widgets/home_device_snapshot_card.dart';
import 'package:sickandflutter/features/home/widgets/home_entry_card.dart';
import 'package:sickandflutter/features/home/widgets/home_header_card.dart';

/// 首页，作为培育管理平台的总览入口。
class HomePage extends ConsumerWidget {
  /// 创建首页。
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceStateAsync = ref.watch(homeOverviewDeviceStatusProvider);
    final currentUser = ref.watch(currentUserLabelProvider);

    void refreshOverview() {
      ref.invalidate(homeOverviewDeviceStatusProvider);
    }

    return AppWorkspaceScaffold(
      destination: AppWorkspaceDestination.home,
      title: '总览',
      subtitle: '统一查看当前设备状态、最近同步和常用入口。',
      currentUser: currentUser,
      maxContentWidth: 1120,
      child: SingleChildScrollView(
        padding: resolveWorkspacePagePadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            HomeHeaderCard(
              currentUser: currentUser,
              deviceStateAsync: deviceStateAsync,
              onRefresh: refreshOverview,
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final actionTrack = HomeActionTrackCard(
                  children: <Widget>[
                    HomeEntryCard(
                      stepLabel: '01',
                      icon: Icons.monitor_heart_rounded,
                      title: AppCopy.homeRealtimeTitle,
                      subtitle: '需要处理设备状态、同步与补光时进入。',
                      accentColor: AppPalette.softPine,
                      prominent: true,
                      onTap: () => context.goNamed(AppRoutes.realtimeDetect),
                    ),
                    HomeEntryCard(
                      stepLabel: '02',
                      icon: Icons.videocam_rounded,
                      title: AppCopy.homePreviewTitle,
                      subtitle: '需要确认现场时，直接查看当前可用画面。',
                      accentColor: AppPalette.linenOlive,
                      onTap: () => context.goNamed(AppRoutes.video),
                    ),
                    HomeEntryCard(
                      stepLabel: '03',
                      icon: Icons.settings_rounded,
                      title: AppCopy.homeSettingsTitle,
                      subtitle: '账号、本机偏好和使用帮助都收在这里。',
                      accentColor: AppPalette.softLavender,
                      onTap: () => context.goNamed(AppRoutes.settings),
                    ),
                  ],
                );
                final snapshot = HomeDeviceSnapshotCard(
                  deviceStateAsync: deviceStateAsync,
                  onRefresh: refreshOverview,
                );

                if (constraints.maxWidth < 960) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      actionTrack,
                      const SizedBox(height: 20),
                      snapshot,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(flex: 10, child: actionTrack),
                    const SizedBox(width: 20),
                    Expanded(flex: 12, child: snapshot),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
