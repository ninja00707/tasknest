import 'package:flutter/material.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/common_section_headers.dart';
import 'package:tasknest/presentation/dashboard/widgets/priority_status_cards.dart';
import 'package:tasknest/presentation/dashboard/widgets/resolution_metrics.dart';
import 'package:tasknest/presentation/dashboard/widgets/stats_grid.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

class DashboardStatsSection extends StatelessWidget {
  final DashboardStats s;
  final bool isWide;
  final double screenWidth;
  const DashboardStatsSection({super.key, required this.s, required this.isWide, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CommaonSectionHeader(
          icon: Icons.bar_chart_rounded,
          title: ConstStrings.overview,
        ),
        const SizedBox(height: 12),
        StatsGrid(s: s, isWide: isWide, screenWidth: screenWidth),
        const SizedBox(height: 28),
        CommaonSectionHeader(
          icon: Icons.av_timer_rounded,
          title: ConstStrings.resolutionMetrics,
        ),
        const SizedBox(height: 12),
        ResolutionMetricsRow(s: s, isWide: isWide),
        const SizedBox(height: 28),
        CommaonSectionHeader(
          icon: Icons.flag_outlined,
          title: ConstStrings.priorityBreakdown,
        ),
        const SizedBox(height: 12),
        isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: PriorityCard(s: s)),
                  const SizedBox(width: 16),
                  Expanded(child: StatusSummaryCard(s: s)),
                ],
              )
            : Column(
                children: [
                  PriorityCard(s: s),
                  const SizedBox(height: 16),
                  StatusSummaryCard(s: s),
                ],
              ),
      ],
    );
  }
}
