// ── Ticket List View ──────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_card.dart';

class TicketListView extends StatelessWidget {
  final DashboardLoaded state;
  const TicketListView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final statuses = ['All', 'open', 'in_progress', 'completed', 'closed'];
    final priorities = ['All', 'urgent', 'high', 'medium', 'low'];

    return Column(
      children: [
        // Filter bar
        Container(
          color: ThemeColors.unifiedSurface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              // Status filter
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: statuses.map((s) {
                      final active =
                          (s == 'All' && state.filterStatus == null) ||
                          s == state.filterStatus;
                      return GestureDetector(
                        onTap: () => context.read<DashboardBloc>().add(
                          FilterTickets(
                            status: s == 'All' ? null : s,
                            priority: state.filterPriority,
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: active
                                ? const LinearGradient(
                                    colors: [
                                      ThemeColors.unifiedGradStart,
                                      ThemeColors.unifiedGradEnd,
                                    ],
                                  )
                                : null,
                            color: active
                                ? null
                                : ThemeColors.unifiedBackground,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: active
                                  ? Colors.transparent
                                  : ThemeColors.unifiedBorder,
                            ),
                          ),
                          child: Text(
                            s == 'All'
                                ? 'All'
                                : s.replaceAll('_', ' ').toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: active
                                  ? Colors.white
                                  : ThemeColors.unifiedTextMuted,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Ticket list
        Expanded(
          child: state.tickets.isEmpty
              ? const Center(
                  child: Text(
                    'No tickets found.',
                    style: TextStyle(color: ThemeColors.unifiedTextMuted),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.tickets.length,
                  itemBuilder: (_, i) => TicketCard(ticket: state.tickets[i]),
                ),
        ),
      ],
    );
  }
}
