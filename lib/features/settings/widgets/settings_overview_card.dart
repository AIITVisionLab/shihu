import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/features/settings/widgets/settings_setting_row.dart';
import 'package:sickandflutter/shared/models/device_state_info.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 设置页设备概览卡片。
class SettingsOverviewCard extends StatelessWidget {
  /// 创建设备概览卡片。
  const SettingsOverviewCard({
    required this.versionLabel,
    required this.deviceStateAsync,
    super.key,
  });

  /// 当前应用版本文案。
  final String versionLabel;

  /// 当前设备状态。
  final AsyncValue<DeviceStateInfo> deviceStateAsync;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: AppCopy.settingsOverviewTitle,
      subtitle: AppCopy.settingsOverviewSubtitle,
      child: deviceStateAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(child: CircularProgressIndicator.adaptive()),
        ),
        error: (error, stackTrace) =>
            SettingsSettingRow(title: '当前状态', value: '设备信息暂不可用'),
        data: (deviceState) => Column(
          children: <Widget>[
            SettingsSettingRow(
              title: '设备名称',
              value: deviceState.deviceName.trim().isEmpty
                  ? deviceState.deviceId
                  : deviceState.deviceName,
            ),
            const SizedBox(height: 14),
            SettingsSettingRow(title: '当前状态', value: deviceState.alertTitle),
            const SizedBox(height: 14),
            SettingsSettingRow(
              title: '最近同步',
              value: _formatDateTime(deviceState.updatedAtTime),
            ),
            if (versionLabel != '--') ...<Widget>[
              const SizedBox(height: 14),
              SettingsSettingRow(
                title: AppCopy.settingsAppVersion,
                value: versionLabel,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) {
      return '未收到设备上报';
    }

    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.year}-$month-$day $hour:$minute';
  }
}
