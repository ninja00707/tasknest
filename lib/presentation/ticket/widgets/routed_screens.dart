import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/constant/scroll_to_load_more.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/ticket/widgets/ticket_list.dart';
import 'package:tasknest/presentation/ticket/widgets/bloc/ticket_list_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/widgets/dashboard_view.dart';
import 'package:tasknest/presentation/create_ticket_module/create_ticket_module.dart';
import 'package:tasknest/presentation/ticket/widgets/ticket_Listview.dart';
import 'package:tasknest/presentation/ticket/widgets/ticket_type_section_screen.dart';

DashboardLoaded? _tryResolve(DashboardState s) {
  if (s is DashboardLoaded) return s;
  if (s is DashboardActionError) return s.previousState;
  if (s is DashboardActionSuccess) return s.previousState;
  if (s is TicketDetailLoaded) return s.previousState;
  return null;
}

Widget _loading() => const Center(
  child: CircularProgressIndicator(color: ThemeColors.unifiedPrimary),
);

class DashboardViewContent extends StatelessWidget {
  final UserModel user;
  const DashboardViewContent({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      buildWhen: (prev, curr) => prev != curr,
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
      buildWhen: (prev, curr) => prev != curr,
      builder: (context, state) {
        final loaded = _tryResolve(state);
        if (loaded == null) return _loading();
        if (user.roleId == 0 || user.roleId == 1 || user.roleId == 3) {
          return ScrollToLoadMore(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: TicketListView(state: loaded, user: user),
            ),
          );
        }
        final myTickets = loaded.tickets
            .where((t) => t.assignedToId == user.id)
            .toList();
        return BlocProvider(
          create: (_) => TicketListBloc(
            tickets: myTickets,
            config: TicketListConfig.myTickets(user: user),
            isWide: loaded.isWide,
            screenWidth: loaded.screenWidth,
          ),
          child: TicketListBody(config: TicketListConfig.myTickets(user: user)),
        );
      },
    );
  }
}

class NewTicketContent extends StatelessWidget {
  final UserModel user;
  final int? projectId;
  const NewTicketContent({super.key, required this.user, this.projectId});

  @override
  Widget build(BuildContext context) {
    return CreateTicketView(user: user, initialProjectId: projectId);
  }
}

class SentSubTicketsContent extends StatelessWidget {
  final UserModel user;
  const SentSubTicketsContent({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      buildWhen: (prev, curr) => prev != curr,
      builder: (context, state) {
        final loaded = _tryResolve(state);
        if (loaded == null) return _loading();
        if (user.roleId == 0 || user.roleId == 3) {
          return const Center(child: Text(ConstStrings.invalidSection));
        }
        return BlocProvider(
          create: (_) => TicketListBloc(
            tickets: loaded.sentTickets,
            config: TicketListConfig.sentSubTickets(user: user),
            isWide: loaded.isWide,
            screenWidth: loaded.screenWidth,
          ),
          child: TicketListBody(config: TicketListConfig.sentSubTickets(user: user)),
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
      buildWhen: (prev, curr) => prev != curr,
      builder: (context, state) {
        final loaded = _tryResolve(state);
        if (loaded == null) return _loading();
        return TicketTypeSectionScreen(state: loaded, user: user);
      },
    );
  }
}
