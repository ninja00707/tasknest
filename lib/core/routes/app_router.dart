import 'package:go_router/go_router.dart';
import 'package:tasknest/core/routes/auth.guard.dart';
import 'package:tasknest/core/routes/routes_name.dart';
import 'package:tasknest/presentation/dashboard/dashboard_screen.dart.dart';
import 'package:tasknest/presentation/login/login_view.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.login,

  redirect: (context, state) {
    final loggedIn = AuthGuard.isLoggedIn;
    final isLoginRoute = state.matchedLocation == RouteNames.login;

    // If not logged in → always go login
    if (!loggedIn && !isLoginRoute) {
      return RouteNames.login;
    }

    // If already logged in → prevent login screen
    if (loggedIn && isLoginRoute) {
      return RouteNames.dashboard;
    }

    return null;
  },

  routes: [
    GoRoute(
      path: RouteNames.login,
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: RouteNames.dashboard,
      builder: (context, state) => const DashboardScreen(),
    ),
  ],
);
