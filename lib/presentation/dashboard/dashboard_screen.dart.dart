import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/widgets/navigationbar.dart/bottom_nav_bar.dart';
import 'package:tasknest/presentation/dashboard/widgets/mobile_top_bar.dart';
import 'package:tasknest/presentation/dashboard/widgets/navigationbar.dart/side_bar.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

class DashboardScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 768;

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
                  Text(state.message!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
                  Flexible(child: Text(state.message!, style: const TextStyle(color: Colors.white))),
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
            body: Center(child: Text(state.message!)),
          );
        }

        final path = GoRouterState.of(context).matchedLocation;
        final selectedIndex = _selectedIndex(path);

        return Scaffold(
          backgroundColor: ThemeColors.unifiedBackground,
          body: SafeArea(
            child: isWide
                ? Row(
                    children: [
                      Sidebar(
                        user: user,
                        selectedIndex: selectedIndex,
                        onNav: (i) => _onNav(context, i),
                      ),
                      Expanded(child: child ?? const SizedBox.shrink()),
                    ],
                  )
                : Column(
                    children: [
                      const MobileTopBar(),
                      Expanded(child: child ?? const SizedBox.shrink()),
                      BottomNav(
                        selectedIndex: selectedIndex,
                        onNav: (i) => _onNav(context, i),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
