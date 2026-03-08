import 'package:flutter/material.dart';
import 'package:sickandflutter/core/config/env_config.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/features/settings/widgets/settings_setting_row.dart';
import 'package:sickandflutter/shared/models/app_settings.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 设置页服务配置卡片。
class SettingsServiceConfigCard extends StatelessWidget {
  /// 创建服务配置卡片。
  const SettingsServiceConfigCard({
    required this.envConfig,
    required this.settings,
    required this.onEditBaseUrl,
    super.key,
  });

  /// 当前环境配置。
  final EnvConfig envConfig;

  /// 当前应用设置。
  final AppSettings settings;

  /// 修改基础地址回调。
  final Future<void> Function()? onEditBaseUrl;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: AppCopy.settingsServiceConfigTitle,
      subtitle: envConfig.allowRiskySettings
          ? AppCopy.settingsServiceConfigEditable
          : AppCopy.settingsServiceConfigReadonly,
      child: Column(
        children: <Widget>[
          SettingsSettingRow(
            title: AppCopy.settingsBaseUrl,
            value: settings.baseUrl,
            trailing: onEditBaseUrl == null
                ? null
                : TextButton(
                    onPressed: () async {
                      await onEditBaseUrl?.call();
                    },
                    child: const Text(AppCopy.settingsEdit),
                  ),
          ),
          const SizedBox(height: 14),
          SettingsSettingRow(
            title: AppCopy.settingsConnectTimeout,
            value: '${settings.connectTimeoutMs} ms',
          ),
          const SizedBox(height: 14),
          SettingsSettingRow(
            title: AppCopy.settingsReceiveTimeout,
            value: '${settings.receiveTimeoutMs} ms',
          ),
        ],
      ),
    );
  }
}
