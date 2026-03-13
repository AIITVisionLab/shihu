import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/features/about/about_page.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/auth/login_page.dart';
import 'package:sickandflutter/features/home/home_page.dart';
import 'package:sickandflutter/features/realtime/realtime_detect_page.dart';
import 'package:sickandflutter/features/settings/settings_page.dart';
import 'package:sickandflutter/features/splash/splash_page.dart';
import 'package:sickandflutter/features/video/video_page.dart';

/// 全局路由配置入口。
final appRouterProvider = Provider<GoRouter>((ref) {
  final authRefreshListenable = _AuthRouterRefreshListenable(ref);
  ref.onDispose(authRefreshListenable.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splashPath,
    refreshListenable: authRefreshListenable,
    redirect: (context, state) => redirectForAuth(
      authState: ref.read(authControllerProvider),
      matchedLocation: state.matchedLocation,
    ),
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splashPath,
        name: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.loginPath,
        name: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.aboutPath,
        name: AppRoutes.about,
        builder: (context, state) => const AboutPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _WorkspaceShellHost(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.homePath,
                name: AppRoutes.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.realtimeDetectPath,
                name: AppRoutes.realtimeDetect,
                builder: (context, state) => const RealtimeDetectPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.videoPath,
                name: AppRoutes.video,
                builder: (context, state) => const VideoPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.settingsPath,
                name: AppRoutes.settings,
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// 工作台一级导航的保活式壳层宿主。
class _WorkspaceShellHost extends StatelessWidget {
  const _WorkspaceShellHost({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) => navigationShell;
}

/// 把 Riverpod 认证状态变化转成 `GoRouter` 可消费的刷新信号。
class _AuthRouterRefreshListenable extends ChangeNotifier {
  _AuthRouterRefreshListenable(this._ref) {
    _subscription = _ref.listen<AuthState>(
      authControllerProvider,
      (_, _) => notifyListeners(),
      fireImmediately: true,
    );
  }

  final Ref _ref;
  ProviderSubscription<AuthState>? _subscription;

  @override
  void dispose() {
    _subscription?.close();
    super.dispose();
  }
}

/// 应用路由名和路径常量。
final class AppRoutes {
  /// 启动页路由名。
  static const String splash = 'splash';

  /// 登录页路由名。
  static const String login = 'login';

  /// 首页路由名。
  static const String home = 'home';

  /// 实时监控页路由名。
  static const String realtimeDetect = 'realtimeDetect';

  /// 设置页路由名。
  static const String settings = 'settings';

  /// 视频中心路由名。
  static const String video = 'video';

  /// 关于页路由名。
  static const String about = 'about';

  /// 启动页路由路径。
  static const String splashPath = '/';

  /// 登录页路由路径。
  static const String loginPath = '/login';

  /// 首页路由路径。
  static const String homePath = '/home';

  /// 实时监控页路由路径。
  static const String realtimeDetectPath = '/realtime-detect';

  /// 设置页路由路径。
  static const String settingsPath = '/settings';

  /// 视频中心路由路径。
  static const String videoPath = '/video';

  /// 关于页路由路径。
  static const String aboutPath = '/about';
}

/// 根据当前登录态决定路由跳转结果。
String? redirectForAuth({
  required AuthState authState,
  required String matchedLocation,
}) {
  const publicLocations = <String>{
    AppRoutes.splashPath,
    AppRoutes.loginPath,
    AppRoutes.aboutPath,
  };

  if (matchedLocation == AppRoutes.splashPath) {
    return null;
  }

  if (authState.isBootstrapping) {
    return null;
  }

  final isLogin = matchedLocation == AppRoutes.loginPath;
  final isPublic = publicLocations.contains(matchedLocation);

  if (authState.isAuthenticated) {
    if (isLogin) {
      return AppRoutes.realtimeDetectPath;
    }
    return null;
  }

  if (!isPublic) {
    return AppRoutes.loginPath;
  }

  return null;
}
