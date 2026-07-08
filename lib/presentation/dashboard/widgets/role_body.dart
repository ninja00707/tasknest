import 'package:flutter/material.dart';
import 'package:tasknest/core/constant/const_dep.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/employee_dashboard_body.dart';
import 'package:tasknest/presentation/dashboard/widgets/dashboard_stats_section.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';

class RoleBody extends StatelessWidget {
  final DashboardLoaded state;
  final UserModel user;
  const RoleBody({super.key, required this.state, required this.user});

  @override
  Widget build(BuildContext context) {
    switch (user.roleId) {
      case roleCEO:
      case roleManager:
      case roleDeveloper:
        return DashboardStatsSection(s: state.stats, isWide: state.isWide);
      default:
        return EmployeeDashboardBody(state: state, user: user);
    }
  }
}
