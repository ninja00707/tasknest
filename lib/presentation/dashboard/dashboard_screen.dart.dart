import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/responsive.dart';
import 'package:tasknest/presentation/dashboard/widgets/navigationbar.dart/bottom_nav_bar.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/create_ticket.dart';
import 'package:tasknest/presentation/dashboard/widgets/dashboard_view.dart';
import 'package:tasknest/presentation/dashboard/widgets/mobile_top_bar.dart';
import 'package:tasknest/presentation/dashboard/widgets/navigationbar.dart/side_bar.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/recent_tickets_view.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/ticket_Listview.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/my_tickets_view.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/transfered_depart_ticket.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

class DashboardScreen extends StatelessWidget {
  final UserModel user;
  const DashboardScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardBloc, DashboardState>(
      listener: (context, state) {
        final currentState = state;
        // _loadUser();
        if (currentState is TicketActionSuccess) {
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
                    currentState.message,
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

        if (currentState is TicketActionError) {
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
                      currentState.message,
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
        final currentState = state;
        DashboardLoaded? loadedState;

        if (currentState is DashboardLoaded) {
          loadedState = currentState;
        } else if (currentState is TicketActionSuccess) {
          loadedState = currentState.previousState;
        } else if (currentState is TicketActionError) {
          loadedState = currentState.previousState;
        }

        // INITIAL VALUE = 0
        final selectedIndex = loadedState?.selectedIndex ?? 0;

        return Scaffold(
          backgroundColor: ThemeColors.unifiedBackground,
          body: SafeArea(
            child: Responsive(
              mobile: Column(
                children: [
                  const MobileTopBar(),
                  Expanded(child: _DashboardBody(state: state)),
                  BottomNav(
                    selectedIndex: selectedIndex,
                    onNav: (i) {
                      context.read<DashboardBloc>().add(
                        SidebarSelectedIndexEvent(sidebarSelectedIndexEvent: i),
                      );
                    },
                  ),
                ],
              ),
              desktop: Row(
                children: [
                  Sidebar(
                    user: user,
                    selectedIndex: selectedIndex,
                    onNav: (i) {
                      context.read<DashboardBloc>().add(
                        SidebarSelectedIndexEvent(sidebarSelectedIndexEvent: i),
                      );
                    },
                  ),
                  Expanded(child: _DashboardBody(state: state)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final DashboardState state;
  const _DashboardBody({required this.state});

  @override
  Widget build(BuildContext context) {
    final currentState = state;
    DashboardLoaded? loadedState;

    if (currentState is DashboardLoaded) {
      loadedState = currentState;
    } else if (currentState is TicketActionSuccess) {
      loadedState = currentState.previousState;
    } else if (currentState is TicketActionError) {
      loadedState = currentState.previousState;
    }

    if (loadedState == null) {
      if (currentState is DashboardError) {
        return Center(child: Text(currentState.message));
      }
      return const Center(
        child: CircularProgressIndicator(color: ThemeColors.unifiedPrimary),
      );
    }

    // Navigation logic is unified within the DashboardLoaded state.
    final currentIndex = loadedState.selectedIndex;

    return _RouteSwitcher(currentIndex: currentIndex, state: loadedState);
  }
}

class _RouteSwitcher extends StatelessWidget {
  final int currentIndex;
  final DashboardLoaded state;

  const _RouteSwitcher({required this.currentIndex, required this.state});

  @override
  Widget build(BuildContext context) {
    final user = state.user;

    switch (currentIndex) {
      case 0:
        return DashboardView(state: state);
      case 1:
        if (user.roleId == 0 || user.roleId == 1) {
          return TicketListView(state: state, user: user);
        } else {
          return MyTicketsView(state: state, user: user);
        }
      case 2:
        return CreateTicketView(user: user);
      case 3:
        if (user.roleId != 0) {
          return TransferedDepartTicket(state: state, user: user);
        } else {
          return const Center(child: Text("Invalid Section"));
        }
      case 4:
        return RecentTicketsView(state: state, userModel: user);
      default:
        return DashboardView(state: state);
    }
  }
}
