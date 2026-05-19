import 'package:go_router/go_router.dart';

import 'package:tasknest/core/routes/routes_name.dart';
import 'package:tasknest/data/datasource/localstorage/sharedpreferences.dart';
import 'package:tasknest/presentation/dashboard/dashboard_screen.dart.dart';
import 'package:tasknest/presentation/dashboard/screens/manager_analytics_screen.dart';
import 'package:tasknest/presentation/dashboard/screens/ceo_analytics_screen.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/ticket_detail_screen.dart';

import 'package:tasknest/presentation/login/login_view.dart';

final LocalStorageService storage = LocalStorageService();

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
      builder: (context, state) => const DashboardScreen(),
    ),

    GoRoute(
      path: '/analytics/manager',
      builder: (context, state) => const ManagerAnalyticsScreen(),
    ),

    GoRoute(
      path: '/analytics/ceo',
      builder: (context, state) => const CeoAnalyticsScreen(),
    ),

    GoRoute(
      path: '/ticket/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return TicketDetailScreen(ticketId: id);
      },
    ),
  ],
);
