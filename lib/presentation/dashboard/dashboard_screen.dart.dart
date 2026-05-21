import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/data/datasource/localstorage/sharedpreferences.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/screens/ceo_analytics_screen.dart';
import 'package:tasknest/presentation/dashboard/screens/manager_analytics_screen.dart';
import 'package:tasknest/presentation/dashboard/widgets/navigationbar.dart/bottom_nav_bar.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/create_ticket.dart';
import 'package:tasknest/presentation/dashboard/widgets/dashboard_view.dart';
import 'package:tasknest/presentation/dashboard/widgets/mobile_top_bar.dart';
import 'package:tasknest/presentation/dashboard/widgets/navigationbar.dart/side_bar.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/recent_tickets_view.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/ticket_Listview.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/my_tickets_view.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

class DashboardScreen extends StatelessWidget {
  final UserModel user;
  const DashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 768;

    context.read<DashboardBloc>().add(LoadDashboard());

    return BlocConsumer<DashboardBloc, DashboardState>(
      listener: (context, state) {
        // _loadUser();
        if (state is TicketActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: ThemeColors.unifiedPrimary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              content: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    state.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is TicketActionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: ThemeColors.unifiedDanger,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              content: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        DashboardLoaded? loadedState;

        if (state is DashboardLoaded) {
          loadedState = state;
        } else if (state is TicketActionSuccess) {
          loadedState = state.previousState;
        } else if (state is TicketActionError) {
          loadedState = state.previousState;
        }

        // INITIAL VALUE = 0
        final selectedIndex = loadedState?.selectedIndex ?? 0;

        return Scaffold(
          backgroundColor: ThemeColors.unifiedBackground,

          body: SafeArea(
            child: isWide
                ? Row(
                    children: [
                      Sidebar(
                        user: user,
                        selectedIndex: selectedIndex,
                        onNav: (i) {
                          context.read<DashboardBloc>().add(
                            SidebarSelectedIndexEvent(
                              sidebarSelectedIndexEvent: i,
                            ),
                          );
                        },
                      ),

                      Expanded(child: _buildBody(state, selectedIndex, user)),
                    ],
                  )
                : Column(
                    children: [
                      const MobileTopBar(),

                      Expanded(child: _buildBody(state, selectedIndex, user)),

                      BottomNav(
                        selectedIndex: selectedIndex,
                        onNav: (i) {
                          context.read<DashboardBloc>().add(
                            SidebarSelectedIndexEvent(
                              sidebarSelectedIndexEvent: i,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildBody(DashboardState state, int selectedIndex, UserModel user) {
    DashboardLoaded? loadedState;

    if (state is DashboardLoaded) {
      loadedState = state;
    } else if (state is TicketActionSuccess) {
      loadedState = state.previousState;
    } else if (state is TicketActionError) {
      loadedState = state.previousState;
    }

    // Allow the body to build if we are in analytics states,
    // as those screens handle their own loading/error indicators internally.
    if ((state is DashboardLoading || state is DashboardInitial) &&
        state is! AnalyticsLoading) {
      return const Center(
        child: CircularProgressIndicator(color: ThemeColors.unifiedPrimary),
      );
    }

    if (state is DashboardError) {
      return Center(child: Text(state.message));
    }

    if (loadedState == null &&
        state is! AnalyticsLoading &&
        state is! ManagerAnalyticsLoaded &&
        state is! CeoAnalyticsLoaded) {
      return const Center(child: Text("Something went wrong"));
    }

    // Determine current index, defaulting to the loadedState or inferring from specialized analytics states
    final currentIndex =
        loadedState?.selectedIndex ??
        (state is AnalyticsLoading ||
                state is ManagerAnalyticsLoaded ||
                state is CeoAnalyticsLoaded
            ? 4
            : 0);

    switch (currentIndex) {
      case 0:
        return DashboardView(state: loadedState!, user: user);
      case 1:
        return TicketListView(state: loadedState!, user: user);
      case 2:
        return CreateTicketView(user: user);
      case 3:
        return RecentTicketsView(state: loadedState!);
      case 4:
        // Dispatch the correct analytics event based on user role
        if (user.roleId == 1) return ManagerAnalyticsScreen(user: user);
        if (user.roleId == 0) return CeoAnalyticsScreen(user: user);
        return const Center(
          child: Text("Access Denied: Analytics"),
        ); // Fallback for non-manager/CEO
      case 5:
        return MyTicketsView(state: loadedState!, user: user);

      default:
        return DashboardView(state: loadedState!, user: user);
    }
  }
}
