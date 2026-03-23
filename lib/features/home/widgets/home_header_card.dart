import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/features/device/application/device_status_view_data.dart';
import 'package:sickandflutter/features/device/domain/device_status.dart';
import 'package:sickandflutter/features/home/widgets/home_header/home_header_lead.dart';
import 'package:sickandflutter/features/home/widgets/home_header/home_summary_board.dart';
import 'package:sickandflutter/shared/widgets/feature_surface.dart';
import 'package:sickandflutter/shared/widgets/workspace_layout.dart';

/// 首页顶部总览卡片。
class HomeHeaderCard extends StatelessWidget {
  /// 创建首页顶部总览卡片。
  const HomeHeaderCard({
    required this.currentUser,
    required this.deviceStateAsync,
    required this.onRefresh,
    super.key,
  });

  /// 当前用户。
  final String currentUser;

  /// 当前设备状态。
  final AsyncValue<DeviceStatus> deviceStateAsync;

  /// 手动刷新回调。
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final deviceStatus = deviceStateAsync.asData?.value;
    final viewData = deviceStatus == null
        ? null
        : DeviceStatusViewData.fromState(deviceStatus);

    return FeatureHeroCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 28,
      accentColor: AppPalette.pineGreen,
      child: WorkspaceTwoPane(
        breakpoint: 980,
        gap: 16,
        stackSpacing: 16,
        secondaryWidthFactor: 0.32,
        primary: HomeHeaderLead(
          deviceStatus: deviceStatus,
          viewData: viewData,
          onRefresh: onRefresh,
        ),
        secondary: HomeSummaryBoard(
          deviceStatus: deviceStatus,
          viewData: viewData,
        ),
      ),
    );
  }
}
