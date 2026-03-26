import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/app/app_workspace_destination.dart';

/// 切换一级工作台导航。
void navigateToWorkspaceDestination(
  BuildContext context,
  AppWorkspaceDestination nextDestination,
) {
  final shellState = StatefulNavigationShell.maybeOf(context);
  final targetIndex = AppWorkspaceDestination.values.indexOf(nextDestination);

  if (shellState != null) {
    if (shellState.currentIndex == targetIndex) {
      return;
    }
    shellState.goBranch(targetIndex);
    return;
  }

  context.goNamed(nextDestination.routeName);
}
