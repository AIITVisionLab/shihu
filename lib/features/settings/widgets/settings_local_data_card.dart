import 'package:flutter/material.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/shared/widgets/common_button.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 设置页本地数据卡片。
class SettingsLocalDataCard extends StatelessWidget {
  /// 创建本地数据卡片。
  const SettingsLocalDataCard({
    required this.onClearHistory,
    required this.onResetSettings,
    super.key,
  });

  /// 清空历史记录回调。
  final Future<void> Function() onClearHistory;

  /// 恢复默认设置回调。
  final Future<void> Function() onResetSettings;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: AppCopy.settingsLocalDataTitle,
      subtitle: AppCopy.settingsLocalDataSubtitle,
      child: Column(
        children: <Widget>[
          CommonButton(
            label: AppCopy.settingsClearHistory,
            tone: CommonButtonTone.danger,
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await onClearHistory();
            },
          ),
          const SizedBox(height: 12),
          CommonButton(
            label: AppCopy.settingsResetDefaults,
            tone: CommonButtonTone.secondary,
            icon: const Icon(Icons.restart_alt_rounded),
            onPressed: () async {
              await onResetSettings();
            },
          ),
        ],
      ),
    );
  }
}
