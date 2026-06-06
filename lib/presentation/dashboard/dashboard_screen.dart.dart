import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/widgets/navigationbar.dart/bottom_nav_bar.dart';
import 'package:tasknest/presentation/dashboard/widgets/navigationbar.dart/side_bar.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/notification_toast.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/notification_panel.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

class DashboardScreen extends StatefulWidget {
  final UserModel user;
  final Widget? child;
  const DashboardScreen({super.key, required this.user, this.child});

  static int _selectedIndex(String path) {
    if (path == '/dashboard') return 0;
    if (path == '/departmentTickets') return 1;
    if (path == '/newTicket') return 2;
    if (path == '/sent_sub_tickets') return 3;
    if (path == '/recent_activities') return 4;
    if (path == '/ticket_types') return 5;
    return 0;
  }

  static void _onNav(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/dashboard'); break;
      case 1: context.go('/departmentTickets'); break;
      case 2: context.go('/newTicket'); break;
      case 3: context.go('/sent_sub_tickets'); break;
      case 4: context.go('/recent_activities'); break;
      case 5: context.go('/ticket_types'); break;
    }
  }

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onNavCloseDrawer(int index) {
    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
    }
    DashboardScreen._onNav(context, index);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width <= 768;
    final isWeb = width > 1024;

    final bloc = context.read<DashboardBloc>();
    if (bloc.state is DashboardInitial) bloc.add(LoadDashboard());

    return BlocConsumer<DashboardBloc, DashboardState>(
      listener: (context, state) {
        if (state is DashboardActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: ThemeColors.unifiedPrimary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(state.message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          );
        }
        if (state is DashboardActionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: ThemeColors.unifiedDanger,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Flexible(child: Text(state.message, style: const TextStyle(color: Colors.white))),
                ],
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if ((state is DashboardLoading || state is DashboardInitial) &&
            state is! AnalyticsLoading) {
          return Scaffold(
            backgroundColor: ThemeColors.unifiedBackground,
            body: const Center(
              child: CircularProgressIndicator(color: ThemeColors.unifiedPrimary),
            ),
          );
        }

        if (state is DashboardError) {
          return Scaffold(
            backgroundColor: ThemeColors.unifiedBackground,
            body: Center(child: Text(state.message)),
          );
        }

        final path = GoRouterState.of(context).matchedLocation;
        final selectedIndex = DashboardScreen._selectedIndex(path);

        // ── Shared sidebar for drawer (mobile + tablet) ──────────────
        final drawerSidebar = Sidebar(
          user: widget.user,
          selectedIndex: selectedIndex,
          onNav: _onNavCloseDrawer,
        );

        // ── Shared content body wrapped in LiveNotificationShell ─────
        Widget bodyContent = LiveNotificationShell(
          child: SafeArea(
            child: isWeb
                ? Row(
                    children: [
                      // Inline sidebar (always visible on web)
                      Sidebar(
                        user: widget.user,
                        selectedIndex: selectedIndex,
                        onNav: (i) => DashboardScreen._onNav(context, i),
                      ),
                      Expanded(child: widget.child ?? const SizedBox.shrink()),
                    ],
                  )
                : Column(
                    children: [
                      // Top bar with hamburger menu
                      DashboardTopBar(
                        showMenu: true,
                        onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                      ),
                      Expanded(child: widget.child ?? const SizedBox.shrink()),
                      // Bottom navigation only on mobile
                      if (isMobile)
                        BottomNav(
                          selectedIndex: selectedIndex,
                          onNav: (i) => DashboardScreen._onNav(context, i),
                        ),
                    ],
                  ),
          ),
        );

        // ── Wrap in Scaffold with drawer for mobile/tablet ───────────
        return Scaffold(
          key: isWeb ? null : _scaffoldKey,
          backgroundColor: ThemeColors.unifiedBackground,
          drawer: isWeb ? null : drawerSidebar,
          body: bodyContent,
        );
      },
    );
  }
}

class DashboardTopBar extends StatelessWidget {
  final bool showMenu;
  final VoidCallback? onMenuTap;

  const DashboardTopBar({
    super.key,
    this.showMenu = false,
    this.onMenuTap,
  });

  static const String _title = 'Taskify';

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
          const Text(
            _title,
            style: TextStyle(
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
                  if (count > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: ThemeColors.unifiedDanger,
                          shape: BoxShape.circle,
                        ),
                        constraints:
                            const BoxConstraints(minWidth: 18, minHeight: 18),
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
