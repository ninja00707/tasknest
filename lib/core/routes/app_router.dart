import 'package:go_router/go_router.dart';

import 'package:tasknest/core/routes/routes_name.dart';
import 'package:tasknest/data/datasource/localstorage/sharedpreferences.dart';
import 'package:tasknest/presentation/dashboard/dashboard_screen.dart.dart';
import 'package:tasknest/presentation/dashboard/screens/manager_analytics_screen.dart';
import 'package:tasknest/presentation/dashboard/screens/ceo_analytics_screen.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/ticket_detail_screen.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

import 'package:tasknest/presentation/login/login_view.dart';

final LocalStorageService storage = LocalStorageService();
UserModel? _user;
final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.login,

  redirect: (context, state) async {
    final token = await storage.getToken();

    final loggedIn = token != null && token.isNotEmpty;

    final isLoginRoute = state.matchedLocation == RouteNames.login;

    // If NOT logged in
    if (!loggedIn && !isLoginRoute) {
      return RouteNames.login;
    }
    _user = await storage.getUser();
    // If already logged in
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
      builder: (context, state) => DashboardScreen(user: _user!),
    ),

    GoRoute(
      path: RouteNames.analyticsManager,
      builder: (context, state) => ManagerAnalyticsScreen(user: _user),
    ),

    GoRoute(
      path: RouteNames.analyticsCeo,
      builder: (context, state) => CeoAnalyticsScreen(user: _user!),
    ),

    GoRoute(
      path: RouteNames.ticketDetail,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return TicketDetailScreen(ticketId: id, user: _user!);
      },
    ),
  ],
);
