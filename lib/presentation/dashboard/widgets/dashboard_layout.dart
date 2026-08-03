import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/routes/routes_name.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/domain/repositories_impl/ticket_impl/ticket_impl.dart';
import 'package:tasknest/injection.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/navigation/bottom_nav_bar.dart';
import 'package:tasknest/presentation/navigation/sidebar.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/notification/bloc/notification_bloc.dart';
import 'package:tasknest/presentation/notification/widgets/notification_panel.dart';
import 'package:tasknest/presentation/notification/widgets/notification_toast.dart';

class DashboardLayout extends StatelessWidget {
  final UserModel user;
  final Widget child;
  final bool isWide;
  const DashboardLayout({super.key, required this.user, required this.isWide, required this.child});

  static int selectedIndex(String path) {
    if (path == RouteNames.dashboard) return 0;
    if (path == RouteNames.departmentTickets) return 1;
    if (path == RouteNames.newTicket) return 2;
    if (path == RouteNames.sentSubTickets) return 3;
    if (path == RouteNames.recentActivities) return 4;
    if (path == RouteNames.ticketTypes) return 5;
    if (path == RouteNames.disputes) return 6;
    return 0;
  }

  static void onNav(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RouteNames.dashboard);
      case 1:
        context.go(RouteNames.departmentTickets);
      case 2:
        context.go(RouteNames.newTicket);
      case 3:
        context.go(RouteNames.sentSubTickets);
      case 4:
        context.go(RouteNames.recentActivities);
      case 5:
        context.go(RouteNames.ticketTypes);
      case 6:
        context.go(RouteNames.disputes);
    }
  }

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).matchedLocation;
    final selectedIdx = selectedIndex(path);

    return BlocBuilder<DashboardBloc, DashboardState>(
      buildWhen: (prev, curr) {
        if (curr is! DashboardLoaded || prev is! DashboardLoaded) return false;
        return prev.sidebarOpen != curr.sidebarOpen;
      },
      builder: (context, state) {
        final loaded = state as DashboardLoaded;
        final isMobile = !isWide;

        return BlocProvider<NotificationBloc>(
          create: (_) => NotificationBloc(sl<TicketRepositoryImpl>()),
          child: LiveNotificationShell(
            child: Scaffold(
            backgroundColor: ThemeColors.unifiedBackground,
            drawer: isWide
                ? null
                : Drawer(
                    child: SafeArea(
                      child: Sidebar(
                        user: user,
                        selectedIndex: selectedIdx,
                        onNav: (i) {
                          Scaffold.of(context).closeDrawer();
                          onNav(context, i);
                        },
                      ),
                    ),
                  ),
            body: SafeArea(
              child: isWide
                  ? Row(
                      children: [
                        if (loaded.sidebarOpen)
                          Sidebar(
                            user: user,
                            selectedIndex: selectedIdx,
                            onNav: (i) => onNav(context, i),
                          ),
                        GestureDetector(
                          onTap: () => context.read<DashboardBloc>().add(
                            ToggleSidebar(),
                          ),
                          child: Container(
                            width: 20,
                            color: ThemeColors.unifiedBackground,
                            child: Center(
                              child: Container(
                                width: 16,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: ThemeColors.unifiedSurface,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: ThemeColors.unifiedBorder.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                child: Icon(
                                  loaded.sidebarOpen
                                      ? Icons.chevron_left_rounded
                                      : Icons.chevron_right_rounded,
                                  size: 14,
                                  color: ThemeColors.unifiedTextMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(child: child),
                      ],
                    )
                  : Column(
                      children: [
                        DashboardTopBar(
                          showMenu: true,
                          onMenuTap: () => Scaffold.of(context).openDrawer(),
                        ),
                        Expanded(child: child),
                        if (isMobile)
                          BottomNav(
                            selectedIndex: selectedIdx,
                            onNav: (i) => onNav(context, i),
                          ),
                      ],
                    ),
            ),
          ),
        ),
      );
      },
    );
  }
}

class DashboardTopBar extends StatelessWidget {
  final bool showMenu;
  final VoidCallback? onMenuTap;

  const DashboardTopBar({super.key, this.showMenu = false, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: ThemeColors.unifiedSurface,
        border: Border(
          bottom: BorderSide(color: ThemeColors.unifiedBorder, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          if (showMenu)
            IconButton(
              icon: const Icon(
                Icons.menu_rounded,
                color: ThemeColors.unifiedTextPrimary,
                size: 22,
              ),
              onPressed: onMenuTap,
            ),
          if (showMenu) const SizedBox(width: 4),
          Text(
            ConstStrings.taskify,
            style: const TextStyle(
              color: ThemeColors.unifiedTextPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          BlocSelector<DashboardBloc, DashboardState, int>(
            selector: (state) =>
                state is DashboardLoaded ? state.unreadNotificationCount : 0,
            builder: (context, count) => IconButton(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    color: ThemeColors.unifiedTextMuted,
                    size: 22,
                  ),
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: count > 0
                            ? ThemeColors.unifiedDanger
                            : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () => NotificationPanel.show(context),
            ),
          ),
        ],
      ),
    );
  }
}
