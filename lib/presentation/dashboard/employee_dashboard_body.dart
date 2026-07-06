import 'package:flutter/material.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/ticket/widgets/ticket_Listview.dart';

class EmployeeDashboardBody extends StatelessWidget {
  final DashboardLoaded state;
  final UserModel user;
  const EmployeeDashboardBody({
    super.key,
    required this.state,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return TicketListView(state: state, user: user);
  }
}
