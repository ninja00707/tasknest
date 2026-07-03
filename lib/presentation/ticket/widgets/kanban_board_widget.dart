import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_helpers.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/dashboard/widgets/priority_badges.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/login/models/auth_response_model.dart';

// ══════════════════════════════════════════════════════════════════════════════
// KANBAN BOARD VIEW (Trello-like columns by status) — now priority-sorted too
// ══════════════════════════════════════════════════════════════════════════════
class KanbanBoard extends StatelessWidget {
  final DashboardLoaded state;
  final UserModel user;
  const KanbanBoard({required this.state, required this.user});

  static const _statuses = ['open', 'in_progress', 'completed', 'closed'];

  static Color _columnColor(String status) {
    switch (status) {
      case 'open':
        return const Color(0xFF22C55E);
      case 'in_progress':
        return const Color(0xFF3B82F6);
      case 'completed':
        return const Color(0xFF10B981);
      case 'closed':
        return const Color(0xFF6B7280);
      default:
        return Colors.grey;
    }
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
        return s;
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final all = state.filteredTickets;
    final grouped = <String, List<TicketModel>>{};
    for (final s in _statuses) {
      final list = all.where((t) => t.status == s).toList()
        ..sort(
          (a, b) => _priorityWeight(
            a.priority,
          ).compareTo(_priorityWeight(b.priority)),
        );
      grouped[s] = list;
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _statuses.map((status) {
          final tickets = grouped[status]!;
          return KanbanColumn(
            status: status,
            label: _statusLabel(status),
            color: _columnColor(status),
            tickets: tickets,
            user: user,
          );
        }).toList(),
      ),
    );
  }
}

// ── Kanban column ─────────────────────────────────────────────────────────────
class KanbanColumn extends StatelessWidget {
  final String status;
  final String label;
  final Color color;
  final List<TicketModel> tickets;
  final UserModel user;

  const KanbanColumn({
    required this.status,
    required this.label,
    required this.color,
    required this.tickets,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          // ── Column header ──────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(13),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${tickets.length}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Ticket list ────────────────────────────────────
          Expanded(
            child: tickets.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'No tickets',
                        style: TextStyle(
                          fontSize: 12,
                          color: color.withOpacity(0.4),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                    itemCount: tickets.length,
                    itemBuilder: (context, i) =>
                        KanbanCard(ticket: tickets[i], user: user),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Kanban card ────────────────────────────────────────────────────────────────
class KanbanCard extends StatelessWidget {
  final TicketModel ticket;
  final UserModel user;
  const KanbanCard({required this.ticket, required this.user});

  @override
  Widget build(BuildContext context) {
    final pColor = ticketPriorityColor(ticket.priority);
    return GestureDetector(
      onTap: () => context.push('/ticket/${ticket.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border(left: BorderSide(color: pColor, width: 3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ticket number + priority
            Row(
              children: [
                Flexible(
                  child: Text(
                    ticket.ticketNumber.isNotEmpty
                        ? ticket.ticketNumber
                        : '#${ticket.id}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF9CA3AF),
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: pColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Title
            Text(
              ticket.title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Bottom row: assignee + dept
            Row(
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  size: 11,
                  color: ThemeColors.unifiedTextMuted.withOpacity(0.6),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    ticket.assignedToName ?? 'Unassigned',
                    style: TextStyle(
                      fontSize: 10,
                      color: ThemeColors.unifiedTextMuted.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
