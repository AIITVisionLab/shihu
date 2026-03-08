import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/features/about/about_page.dart';
import 'package:sickandflutter/features/detect/detect_page.dart';
import 'package:sickandflutter/features/history/history_page.dart';
import 'package:sickandflutter/features/home/home_page.dart';
import 'package:sickandflutter/features/realtime/realtime_detect_page.dart';
import 'package:sickandflutter/features/result/result_page.dart';
import 'package:sickandflutter/features/settings/settings_page.dart';
import 'package:sickandflutter/features/splash/splash_page.dart';

/// 全局路由配置入口。
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splashPath,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splashPath,
        name: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.homePath,
        name: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.detectPath,
        name: AppRoutes.detect,
        builder: (context, state) => const DetectPage(),
      ),
      GoRoute(
        path: AppRoutes.realtimeDetectPath,
        name: AppRoutes.realtimeDetect,
        builder: (context, state) => const RealtimeDetectPage(),
      ),
      GoRoute(
        path: AppRoutes.resultPath,
        name: AppRoutes.result,
        builder: (context, state) {
          final payload = state.extra;
          if (payload is! ResultPagePayload) {
            return const _RouteErrorPage(message: '结果页缺少必要参数。');
          }

          return ResultPage(payload: payload);
        },
      ),
      GoRoute(
        path: AppRoutes.historyPath,
        name: AppRoutes.history,
        builder: (context, state) => const HistoryPage(),
      ),
      GoRoute(
        path: AppRoutes.settingsPath,
        name: AppRoutes.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.aboutPath,
        name: AppRoutes.about,
        builder: (context, state) => const AboutPage(),
      ),
    ],
  );
});

/// 应用路由名和路径常量。
final class AppRoutes {
  /// 启动页路由名。
  static const String splash = 'splash';

  /// 首页路由名。
  static const String home = 'home';

  /// 单图识别页路由名。
  static const String detect = 'detect';

  /// 实时识别页路由名。
  static const String realtimeDetect = 'realtimeDetect';

  /// 结果页路由名。
  static const String result = 'result';

  /// 历史记录页路由名。
  static const String history = 'history';

  /// 设置页路由名。
  static const String settings = 'settings';

  /// 关于页路由名。
  static const String about = 'about';

  /// 启动页路由路径。
  static const String splashPath = '/';

  /// 首页路由路径。
  static const String homePath = '/home';

  /// 单图识别页路由路径。
  static const String detectPath = '/detect';

  /// 实时识别页路由路径。
  static const String realtimeDetectPath = '/realtime-detect';

  /// 结果页路由路径。
  static const String resultPath = '/result';

  /// 历史记录页路由路径。
  static const String historyPath = '/history';

  /// 设置页路由路径。
  static const String settingsPath = '/settings';

  /// 关于页路由路径。
  static const String aboutPath = '/about';
}

class _RouteErrorPage extends StatelessWidget {
  const _RouteErrorPage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('路由错误')),
      body: Center(child: Text(message)),
    );
  }
}
