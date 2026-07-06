import 'package:flutter/material.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/widgets/dashboard_stats_section.dart';

class ManagerDashboardBody extends StatelessWidget {
  final DashboardLoaded state;
  final bool isWide;
  const ManagerDashboardBody({
    super.key,
    required this.state,
    required this.isWide,
  });

  @override
  Widget build(BuildContext context) {
    return DashboardStatsSection(s: state.stats, isWide: isWide);
  }
}
