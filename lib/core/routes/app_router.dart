import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/routes/routes_name.dart';
import 'package:tasknest/core/routes/ticket_type_grid_args.dart';
import 'package:tasknest/data/datasource/localstorage/sharedpreferences.dart';
import 'package:tasknest/presentation/admin/presentation/screens/admin_shell_screen.dart';
import 'package:tasknest/presentation/dashboard/dashboard_screen.dart.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/routed_screens.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/ticket_detail_screen.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/ticket_type_grid_screen.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';
import 'package:tasknest/presentation/login/signup_screen.dart';

import 'package:tasknest/presentation/login/login_view.dart';

final LocalStorageService storage = LocalStorageService();
UserModel? _user;
final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.login,

  redirect: (context, state) async {
    final token = await storage.getToken();

    final loggedIn = token != null && token.isNotEmpty;

    final isLoginRoute = state.matchedLocation == RouteNames.login;

    if (!loggedIn && !isLoginRoute) {
      return RouteNames.login;
    }
    _user = await storage.getUser();
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

    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),

    // Dashboard shell — sidebar persists, only content swaps, URL updates
    ShellRoute(
      builder: (context, state, child) => DashboardScreen(
        user: _user!,
        child: child,
      ),
      routes: [
        GoRoute(
          path: RouteNames.dashboard,
          builder: (context, state) => DashboardViewContent(user: _user!),
        ),
        GoRoute(
          path: RouteNames.departmentTickets,
          builder: (context, state) =>
              DepartmentTicketsContent(user: _user!),
        ),
        GoRoute(
          path: RouteNames.newTicket,
          builder: (context, state) => NewTicketContent(user: _user!),
        ),
        GoRoute(
          path: RouteNames.sentSubTickets,
          builder: (context, state) =>
              SentSubTicketsContent(user: _user!),
        ),
        GoRoute(
          path: RouteNames.recentActivities,
          builder: (context, state) =>
              RecentActivitiesContent(user: _user!),
        ),
        GoRoute(
          path: RouteNames.ticketTypes,
          builder: (context, state) => TicketTypesContent(user: _user!),
        ),
      ],
    ),

    // Standalone pages (no sidebar)
    GoRoute(
      path: RouteNames.ticketDetail,
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return TicketDetailScreen(ticketId: id, user: _user!);
      },
    ),

    GoRoute(
      path: RouteNames.ticketTypeGrid,
      builder: (context, state) {
        final args = state.extra as TicketTypeGridArgs;
        return TicketTypeGridScreen(
          tickets: args.tickets,
          title: args.title,
          user: args.user,
        );
      },
    ),

    GoRoute(
      path: RouteNames.admin,
      builder: (context, state) => AdminShellScreen(user: _user!),
    ),
  ],
);
