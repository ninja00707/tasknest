import 'package:flutter/material.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/ticket/widgets/filter_bar_widget.dart';
import 'package:tasknest/presentation/ticket/widgets/kanban_board_widget.dart';
import 'package:tasknest/presentation/ticket/widgets/search_bar_widget.dart';

class TicketListView extends StatelessWidget {
  final DashboardLoaded state;
  final UserModel user;

  const TicketListView({super.key, required this.state, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchBarWidget(state: state),
        FilterBarWidget(state: state),
        KanbanBoard(state: state, user: user),
      ],
    );
  }
}
