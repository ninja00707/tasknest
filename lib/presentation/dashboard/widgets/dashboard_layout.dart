import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/navigation/bottom_nav_bar.dart';
import 'package:tasknest/presentation/navigation/sidebar.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/ticket/widgets/notification_panel.dart';
import 'package:tasknest/presentation/ticket/widgets/notification_toast.dart';

class DashboardLayout extends StatelessWidget {
  final UserModel user;
  final Widget child;
  const DashboardLayout({super.key, required this.user, required this.child});

  static int selectedIndex(String path) {
    if (path == '/dashboard') return 0;
    if (path == '/departmentTickets') return 1;
    if (path == '/newTicket') return 2;
    if (path == '/sent_sub_tickets') return 3;
    if (path == '/recent_activities') return 4;
    if (path == '/ticket_types') return 5;
    return 0;
  }

  static void onNav(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
      case 1:
        context.go('/departmentTickets');
      case 2:
        context.go('/newTicket');
      case 3:
        context.go('/sent_sub_tickets');
      case 4:
        context.go('/recent_activities');
      case 5:
        context.go('/ticket_types');
    }
  }

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).matchedLocation;
    final selectedIdx = selectedIndex(path);

    return BlocBuilder<DashboardBloc, DashboardState>(
      buildWhen: (prev, curr) {
        if (curr is! DashboardLoaded || prev is! DashboardLoaded) return false;
        return prev.sidebarOpen != curr.sidebarOpen || prev.isWide != curr.isWide;
      },
      builder: (context, state) {
        final loaded = state as DashboardLoaded;
        final isWide = loaded.isWide;
        final isMobile = !isWide;

        return LiveNotificationShell(
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
                          onTap: () => context.read<DashboardBloc>().add(ToggleSidebar()),
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
                                    color: ThemeColors.unifiedBorder.withValues(alpha: 0.5),
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
        gradient: LinearGradient(
          colors: [ThemeColors.unifiedGradStart, ThemeColors.unifiedGradEnd],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          if (showMenu)
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: onMenuTap,
            ),
          if (showMenu) const SizedBox(width: 4),
          Text(
            ConstStrings.taskify,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
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
                  const Icon(Icons.notifications_outlined, color: Colors.white),
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: count > 0 ? ThemeColors.unifiedDanger : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
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
