import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/model/ticketmodel.dart';
import 'package:tasknest/presentation/dashboard/widgets/priority_badges.dart';
import 'package:tasknest/presentation/dashboard/widgets/status_badges.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/ticket_action.dart';

class TicketCard extends StatelessWidget {
  final TicketModel ticket;
  const TicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final isTransferred = ticket.transferredFromCode != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ticket.isOverdue
              ? ThemeColors.unifiedDanger.withOpacity(0.4)
              : ThemeColors.unifiedBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 3,
            decoration: BoxDecoration(
              color: _priorityColor(ticket.priority),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '#${ticket.id}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: ThemeColors.unifiedTextMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (ticket.isOverdue)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeColors.unifiedDanger.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'OVERDUE',
                          style: TextStyle(
                            fontSize: 10,
                            color: ThemeColors.unifiedDanger,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    if (isTransferred) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeColors.unifiedWarning.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'SENT FROM ${ticket.transferredFromCode}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: ThemeColors.unifiedWarning,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    PriorityBadge(priority: ticket.priority),
                    const SizedBox(width: 6),
                    StatusBadge(status: ticket.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  ticket.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: ThemeColors.unifiedTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ticket.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: ThemeColors.unifiedTextMuted,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.arrow_upward_rounded,
                      size: 13,
                      color: ThemeColors.unifiedPrimary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      ticket.createdByDeptCode,
                      style: const TextStyle(
                        fontSize: 12,
                        color: ThemeColors.unifiedTextMuted,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 13,
                      color: ThemeColors.unifiedSecondary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      ticket.assignedDeptCode,
                      style: const TextStyle(
                        fontSize: 12,
                        color: ThemeColors.unifiedTextMuted,
                      ),
                    ),
                    if (ticket.assignedToName != null) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.person_outline,
                        size: 13,
                        color: ThemeColors.unifiedTextMuted,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        ticket.assignedToName!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ThemeColors.unifiedTextMuted,
                        ),
                      ),
                    ],
                    const Spacer(),
                    TicketActions(ticket: ticket),
                  ],
                ),
                if (isTransferred) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.sync_alt_rounded,
                        size: 13,
                        color: ThemeColors.unifiedWarning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Transferred from ${ticket.transferredFromCode}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ThemeColors.unifiedWarning,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'urgent':
        return ThemeColors.unifiedDanger;
      case 'high':
        return const Color(0xFFEA580C);
      case 'medium':
        return ThemeColors.unifiedWarning;
      default:
        return ThemeColors.unifiedPrimary;
    }
  }
}
