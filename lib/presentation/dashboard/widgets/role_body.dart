import 'package:flutter/material.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/ceo_dashboard_body.dart';
import 'package:tasknest/presentation/dashboard/employee_dashboard_body.dart';
import 'package:tasknest/presentation/dashboard/manager_dashboard_body.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';

class RoleBody extends StatelessWidget {
  final DashboardLoaded state;
  final UserModel user;
  const RoleBody({super.key, required this.state, required this.user});

  @override
  Widget build(BuildContext context) {
    switch (user.roleId) {
      case 0:
        return CeoDashboardBody(state: state, isWide: state.isWide);
      case 1:
      case 3:
        return ManagerDashboardBody(state: state, isWide: state.isWide);
      default:
        return EmployeeDashboardBody(state: state, user: user);
    }
  }
}
