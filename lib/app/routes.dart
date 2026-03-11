import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sickandflutter/features/about/about_page.dart';
import 'package:sickandflutter/features/auth/auth_controller.dart';
import 'package:sickandflutter/features/auth/login_page.dart';
import 'package:sickandflutter/features/home/home_page.dart';
import 'package:sickandflutter/features/realtime/realtime_detect_page.dart';
import 'package:sickandflutter/features/settings/settings_page.dart';
import 'package:sickandflutter/features/splash/splash_page.dart';

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
        path: AppRoutes.homePath,
        name: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.loginPath,
        name: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.realtimeDetectPath,
        name: AppRoutes.realtimeDetect,
        builder: (context, state) => const RealtimeDetectPage(),
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
