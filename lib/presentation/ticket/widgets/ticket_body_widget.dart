import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_helpers.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/ticket/widgets/ticket_card.dart';
import 'filter_bar_widget.dart';
import 'empty_state_widget.dart';

// ══════════════════════════════════════════════════════════════════════════════
// TICKET BODY — now sorted by urgency and grouped by status for clarity
// ══════════════════════════════════════════════════════════════════════════════
class TicketBody extends StatelessWidget {
  final DashboardLoaded state;
  final UserModel user;

  const TicketBody({super.key, required this.state, required this.user});

  static const List<String> _statusFlow = [
    'open',
    'in_progress',
    'completed',
    'closed',
  ];

  static int _priorityWeight(String? p) {
    switch ((p ?? '').toLowerCase()) {
      case 'urgent':
        return 0;
      case 'high':
        return 1;
      case 'medium':
        return 2;
      case 'low':
        return 3;
      default:
        return 4;
    }
  }

  static int _statusWeight(String? s) {
    final idx = _statusFlow.indexOf(s ?? '');
    return idx == -1 ? _statusFlow.length : idx;
  }

  /// Tickets are never lost — only re-ordered. Urgent/high priority surfaces
  /// first, then earlier-stage statuses (open before closed), so the most
  /// actionable work is always at the top.
  List<TicketModel> _sorted(List<TicketModel> tickets) {
    final list = List<TicketModel>.from(tickets);
    list.sort((a, b) {
      final p = _priorityWeight(
        a.priority,
      ).compareTo(_priorityWeight(b.priority));
      if (p != 0) return p;
      return _statusWeight(a.status).compareTo(_statusWeight(b.status));
    });
    return list;
  }

  static String _statusLabel(String s) {
    switch (s) {
      case 'open':
        return 'Open';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'closed':
        return 'Closed';
      default:
        return s.replaceAll('_', ' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasFilters =
        state.filterStatus != null ||
        state.filterPriority != null;

    final allSorted = _sorted(state.tickets);

    if (allSorted.isEmpty) {
      return EmptyState(
        filterActive: hasFilters,
        onClear: () {
          context.read<DashboardBloc>().add(
            FilterTickets(status: null, priority: null, teamOnly: state.filterTeam),
          );
        },
      );
    }

    // Group by status only in the default (unfiltered) view, so every ticket
    // sits under a clear, labeled section instead of one long jumbled list.
    final Map<String, List<TicketModel>> grouped = {};
    if (!hasFilters) {
      for (final t in allSorted) {
        grouped.putIfAbsent(t.status, () => []).add(t);
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1200
            ? 3
            : constraints.maxWidth > 700
            ? 2
            : 1;
        const spacing = 12.0;
        const padding = 16.0;
        final cardWidth =
            (constraints.maxWidth -
                padding * 2 -
                spacing * (crossAxisCount - 1)) /
            crossAxisCount;

        Widget buildGrid(List<TicketModel> tickets) {
          return GridView.builder(
            itemCount: tickets.length,
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
            ),
            itemBuilder: (context, index) {
              return SizedBox(
                width: cardWidth,
                child: TicketCard(ticket: tickets[index], user: user),
              );
            },
          );
        }

        return Padding(
          padding: const EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Result summary strip (filtered view) ────────
              if (hasFilters) ...[
                ResultSummary(state: state, count: allSorted.length),
                const SizedBox(height: 12),
                buildGrid(allSorted),
              ] else
                // ── Grouped-by-status sections (default view) ──
                for (final status in _statusFlow)
                  if ((grouped[status]?.isNotEmpty ?? false))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StatusSectionHeader(
                            status: status,
                            label: _statusLabel(status),
                            count: grouped[status]!.length,
                          ),
                          const SizedBox(height: 10),
                          buildGrid(grouped[status]!),
                        ],
                      ),
                    ),

              if (state.totalPages > 1)
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PageBtn(
                        icon: Icons.chevron_left_rounded,
                        label: 'Previous',
                        disabled: state.currentPage <= 1,
                        onTap: () {
                          if (state.currentPage > 1) {
                            context.read<DashboardBloc>().add(
                              LoadDashboard(page: state.currentPage - 1),
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeColors.unifiedSurface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: ThemeColors.unifiedBorder),
                        ),
                        child: Text(
                          'Page ${state.currentPage} of ${state.totalPages}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: ThemeColors.unifiedTextPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      PageBtn(
                        icon: Icons.chevron_right_rounded,
                        label: 'Next',
                        disabled: state.currentPage >= state.totalPages,
                        onTap: () {
                          if (state.currentPage < state.totalPages) {
                            context.read<DashboardBloc>().add(
                              LoadDashboard(page: state.currentPage + 1),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ── Status section header (groups tickets visually) ────────────────────────────
class StatusSectionHeader extends StatelessWidget {
  final String status;
  final String label;
  final int count;
  const StatusSectionHeader({
    super.key,
    required this.status,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final color = ticketStatusColor(status);
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: ThemeColors.unifiedTextPrimary,
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            color: ThemeColors.unifiedBorder.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

// ── Result summary ────────────────────────────────────────────────────────────
class ResultSummary extends StatelessWidget {
  final DashboardLoaded state;
  final int count;
  const ResultSummary({super.key, required this.state, this.count = 0});

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (state.filterStatus != null) {
      parts.add(state.filterStatus!.replaceAll('_', ' ').toUpperCase());
    }
    if (state.filterPriority != null) {
      parts.add('${state.filterPriority!.toUpperCase()} PRIORITY');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ThemeColors.unifiedBorder, width: 1.5),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.filter_alt_rounded,
            size: 14,
            color: ThemeColors.unifiedPrimary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Showing $count result${count == 1 ? '' : 's'}'
              ' · ${parts.join(' · ')}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ThemeColors.unifiedTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
