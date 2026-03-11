import 'package:flutter/material.dart';
import 'package:sickandflutter/app/routes.dart';

/// 主工作台内的一级导航目的地。
enum AppWorkspaceDestination {
  /// 监测总览。
  home,

  /// 实时监控主控台。
  realtime,

  /// 系统概览。
  about,

  /// 运维设置。
  settings,
}

/// 为一级导航目的地补充显示信息和路由映射。
extension AppWorkspaceDestinationX on AppWorkspaceDestination {
  /// 导航标签。
  String get label {
    switch (this) {
      case AppWorkspaceDestination.home:
        return '监测总览';
      case AppWorkspaceDestination.realtime:
        return '主控台';
      case AppWorkspaceDestination.about:
        return '系统概览';
      case AppWorkspaceDestination.settings:
        return '运维设置';
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
