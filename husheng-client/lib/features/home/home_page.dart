import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/app/app_workspace_destination.dart';
import 'package:sickandflutter/app/widgets/app_workspace_scaffold.dart';
import 'package:sickandflutter/features/auth/application/current_user_label_provider.dart';
import 'package:sickandflutter/features/home/application/home_overview_device_status_provider.dart';
import 'package:sickandflutter/features/home/widgets/home_device_snapshot_card.dart';
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
            const SizedBox(height: 16),
            HomeDeviceSnapshotCard(
              deviceStateAsync: deviceStateAsync,
              onRefresh: refreshOverview,
            ),
          ],
        ),
      ),
    );
  }
}
