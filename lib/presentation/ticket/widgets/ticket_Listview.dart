import 'package:flutter/material.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/login/models/auth_response_model.dart';
import 'search_bar_widget.dart';
import 'filter_bar_widget.dart';
import 'ticket_body_widget.dart';
import 'kanban_board_widget.dart';

class TicketListView extends StatefulWidget {
  final DashboardLoaded state;
  final UserModel user;

  const TicketListView({super.key, required this.state, required this.user});

  @override
  State<TicketListView> createState() => _TicketListViewState();
}

class _TicketListViewState extends State<TicketListView> {
  bool _boardView = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchBarWidget(state: widget.state),
        FilterBarWidget(
          state: widget.state,
          boardView: _boardView,
          onToggleView: () => setState(() => _boardView = !_boardView),
        ),
        if (_boardView)
          KanbanBoard(state: widget.state, user: widget.user)
        else
          TicketBody(state: widget.state, user: widget.user),
      ],
    );
  }
}
