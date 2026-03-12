import 'package:flutter/material.dart';
import 'package:sickandflutter/app/routes.dart';

/// 主工作台内的一级导航目的地。
enum AppWorkspaceDestination {
  /// 总览。
  home,

  /// 值守台。
  realtime,

  /// 使用说明。
  about,

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
      case AppWorkspaceDestination.about:
        return '说明';
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
      case AppWorkspaceDestination.about:
        return Icons.info_outline_rounded;
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
      case AppWorkspaceDestination.about:
        return Icons.info_rounded;
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
      case AppWorkspaceDestination.about:
        return AppRoutes.about;
      case AppWorkspaceDestination.settings:
        return AppRoutes.settings;
    }
  }
}
