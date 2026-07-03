import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/ticket/widgets/ticket_list.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';

import 'package:tasknest/presentation/ticket/bloc/ticket_state.dart'
    hide TicketDetailLoaded;
import 'package:tasknest/presentation/dashboard/widgets/dashboard_view.dart';
import 'package:tasknest/presentation/ticket/crud/create/create_ticket.dart';
import 'package:tasknest/presentation/ticket/widgets/ticket_Listview.dart';
import 'package:tasknest/presentation/ticket/widgets/ticket_type_section_screen.dart';
import 'package:tasknest/presentation/login/models/auth_response_model.dart';

DashboardLoaded? _tryResolve(DashboardState s) {
  if (s is DashboardLoaded) return s;
  if (s is DashboardActionError) return s.previousState;
  if (s is DashboardActionSuccess) return s.previousState;
  if (s is TicketDetailLoaded) return s.previousState;
  return null;
}

bool _isTicketProcessing(TicketState s) => s is TicketActionInProgress;

Widget _loading() => const Center(
  child: CircularProgressIndicator(color: ThemeColors.unifiedPrimary),
);

class DashboardViewContent extends StatelessWidget {
  final UserModel user;
  const DashboardViewContent({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final loaded = _tryResolve(state);
        if (loaded == null) return _loading();
        return DashboardView(state: loaded, user: user);
      },
    );
  }
}

class DepartmentTicketsContent extends StatelessWidget {
  final UserModel user;
  const DepartmentTicketsContent({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final loaded = _tryResolve(state);
        if (loaded == null) return _loading();
        if (user.roleId == 0 || user.roleId == 1 || user.roleId == 3) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: TicketListView(state: loaded, user: user),
          );
        }
        final myTickets = loaded.tickets
            .where((t) => t.assignedToId == user.id)
            .toList();
        return TicketListWidget(
          tickets: myTickets,
          config: TicketListConfig.myTickets(user: user),
        );
      },
    );
  }
}

class NewTicketContent extends StatelessWidget {
  final UserModel user;
  const NewTicketContent({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return CreateTicketView(user: user);
  }
}

class SentSubTicketsContent extends StatelessWidget {
  final UserModel user;
  const SentSubTicketsContent({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final loaded = _tryResolve(state);
        if (loaded == null) return _loading();
        if (user.roleId == 0 || user.roleId == 3) {
          return const Center(child: Text('Invalid Section'));
        }
        return TicketListWidget(
          tickets: loaded.sentTickets,
          config: TicketListConfig.sentSubTickets(user: user),
        );
      },
    );
  }
}

class RecentActivitiesContent extends StatelessWidget {
  final UserModel user;
  const RecentActivitiesContent({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final loaded = _tryResolve(state);
        if (loaded == null) return _loading();
        final recent = [...loaded.tickets]
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return TicketListWidget(
          tickets: recent,
          config: TicketListConfig.recentActivity(),
        );
      },
    );
  }
}

class TicketTypesContent extends StatelessWidget {
  final UserModel user;
  const TicketTypesContent({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        final loaded = _tryResolve(state);
        if (loaded == null) return _loading();
        return TicketTypeSectionScreen(state: loaded, user: user);
      },
    );
  }
}
