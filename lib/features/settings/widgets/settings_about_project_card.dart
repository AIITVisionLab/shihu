import 'package:flutter/material.dart';
import 'package:sickandflutter/core/constants/app_copy.dart';
import 'package:sickandflutter/shared/widgets/common_button.dart';
import 'package:sickandflutter/shared/widgets/common_card.dart';

/// 设置页系统总览入口卡片。
class SettingsAboutProjectCard extends StatelessWidget {
  /// 创建项目说明卡片。
  const SettingsAboutProjectCard({required this.onOpenAbout, super.key});

  /// 打开系统总览页回调。
  final VoidCallback onOpenAbout;

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      title: AppCopy.settingsProjectTitle,
      child: CommonButton(
        label: AppCopy.viewAboutProject,
        tone: CommonButtonTone.secondary,
        icon: const Icon(Icons.info_outline),
        onPressed: onOpenAbout,
      ),
    );
  }
}
