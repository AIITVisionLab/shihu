import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/features/device/application/device_status_view_data.dart';
import 'package:sickandflutter/features/device/domain/device_status.dart';
import 'package:sickandflutter/features/home/widgets/home_snapshot/home_snapshot_metrics.dart';
import 'package:sickandflutter/features/home/widgets/home_snapshot/home_snapshot_summary.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 首页设备快照卡片。
class HomeDeviceSnapshotCard extends StatelessWidget {
  /// 创建首页设备快照卡片。
  const HomeDeviceSnapshotCard({
    required this.deviceStateAsync,
    required this.onRefresh,
    super.key,
  });

  /// 设备状态异步值。
  final AsyncValue<DeviceStatus> deviceStateAsync;

  /// 刷新回调。
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: '环境速览',
      subtitle: '把当前指标收在一处，需要处理时再进入值守台。',
      padding: const EdgeInsets.all(18),
      accentColor: AppPalette.mistMint,
      headerIcon: Icons.analytics_outlined,
      headerTag: '状态快照',
      child: deviceStateAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(child: CircularProgressIndicator.adaptive()),
        ),
        error: (error, stackTrace) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('监测数据获取失败：$error'),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('重新同步'),
            ),
          ],
        ),
        data: (deviceState) {
          final viewData = DeviceStatusViewData.fromState(deviceState);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LayoutBuilder(
                builder: (context, constraints) {
                  final summary = HomeSnapshotSummary(
                    deviceState: deviceState,
                    viewData: viewData,
                    onRefresh: onRefresh,
                  );
                  final metrics = HomeSnapshotMetrics(viewData: viewData);

                  if (constraints.maxWidth < 860) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        summary,
                        const SizedBox(height: 14),
                        metrics,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(flex: 7, child: summary),
                      const SizedBox(width: 16),
                      Expanded(flex: 8, child: metrics),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
