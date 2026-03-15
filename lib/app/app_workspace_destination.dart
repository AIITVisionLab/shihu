import 'package:flutter/material.dart';
import 'package:sickandflutter/app/app_palette.dart';
import 'package:sickandflutter/app/routes.dart';

/// 主工作台内的一级导航目的地。
enum AppWorkspaceDestination {
  /// 总览。
  home,

  /// 值守台。
  realtime,

  /// 视频中心。
  video,

  /// 我的。
  settings,
}

/// 为一级导航目的地补充显示信息和路由映射。
extension AppWorkspaceDestinationX on AppWorkspaceDestination {
  /// 导航标签。
  String get label {
    switch (this) {
      case AppWorkspaceDestination.home:
        return '总览';
      case AppWorkspaceDestination.realtime:
        return '值守';
      case AppWorkspaceDestination.video:
        return '视频';
      case AppWorkspaceDestination.settings:
        return '我的';
    }
  }

  /// 未选中图标。
  IconData get icon {
    switch (this) {
      case AppWorkspaceDestination.home:
        return Icons.dashboard_outlined;
      case AppWorkspaceDestination.realtime:
        return Icons.monitor_heart_outlined;
      case AppWorkspaceDestination.video:
        return Icons.videocam_outlined;
      case AppWorkspaceDestination.settings:
        return Icons.settings_outlined;
    }
  }

  /// 选中图标。
  IconData get selectedIcon {
    switch (this) {
      case AppWorkspaceDestination.home:
        return Icons.dashboard_rounded;
      case AppWorkspaceDestination.realtime:
        return Icons.monitor_heart_rounded;
      case AppWorkspaceDestination.video:
        return Icons.videocam_rounded;
      case AppWorkspaceDestination.settings:
        return Icons.settings_rounded;
    }
  }

  /// 目标路由名称。
  String get routeName {
    switch (this) {
      case AppWorkspaceDestination.home:
        return AppRoutes.home;
      case AppWorkspaceDestination.realtime:
        return AppRoutes.realtimeDetect;
      case AppWorkspaceDestination.video:
        return AppRoutes.video;
      case AppWorkspaceDestination.settings:
        return AppRoutes.settings;
    }
  }

  /// 导航专用的辅助底色。
  Color get accentColor {
    switch (this) {
      case AppWorkspaceDestination.home:
        return AppPalette.mistMint;
      case AppWorkspaceDestination.realtime:
        return AppPalette.softPine;
      case AppWorkspaceDestination.video:
        return AppPalette.linenOlive;
      case AppWorkspaceDestination.settings:
        return AppPalette.softLavender;
    }
  }

  /// 导航顺序编码。
  String get sectionCode {
    switch (this) {
      case AppWorkspaceDestination.home:
        return '01';
      case AppWorkspaceDestination.realtime:
        return '02';
      case AppWorkspaceDestination.video:
        return '03';
      case AppWorkspaceDestination.settings:
        return '04';
    }
  }
}
