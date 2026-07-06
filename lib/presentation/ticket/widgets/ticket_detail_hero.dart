import 'package:flutter/material.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_helpers.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/ticket/widgets/ticket_dept_journey.dart';

class HeroSection extends StatelessWidget {
  final TicketModel ticket;
  const HeroSection({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final priorityColor = ticketPriorityColor(ticket.priority);

    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.unifiedBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: priorityColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          Container(
            height: 5,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ThemeColors.unifiedGradStart,
                  ThemeColors.unifiedGradEnd,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: priorityColor.withOpacity(0.25),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.confirmation_number_rounded,
                        color: priorityColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: ThemeColors.unifiedTextPrimary,
                              letterSpacing: -0.4,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              HeroBadge(
                                icon: Icons.tag_rounded,
                                label: ticket.ticketNumber.isNotEmpty
                                    ? ticket.ticketNumber
                                    : '#${ticket.id}',
                                color: ThemeColors.unifiedTextMuted,
                              ),
                              HeroBadge(
                                icon: ticket.isMultiTaskTicket
                                    ? Icons.dashboard_rounded
                                    : Icons.task_alt_rounded,
                                label: ticket.isMultiTaskTicket
                                    ? ConstStrings.multiTaskLabel
                                    : ticket.isSubTicket
                                    ? ConstStrings.subTicketLabel
                                    : ConstStrings.standardLabel,
                                color: ThemeColors.unifiedSecondary,
                              ),
                              PriorityBadge(priority: ticket.priority),
                              if (ticket.isOverdue)
                                HeroBadge(
                                  icon: Icons.schedule_rounded,
                                  label: ConstStrings.overdue,
                                  color: ThemeColors.unifiedDanger,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (ticket.hasParent) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeColors.unifiedBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ThemeColors.unifiedBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.subdirectory_arrow_right_rounded,
                          size: 14,
                          color: ThemeColors.unifiedTextMuted,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '${ConstStrings.childOf}${ticket.parentTicketNumber ?? '#${ticket.parentTicketId}'} ${ticket.parentTicketTitle ?? ""}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: ThemeColors.unifiedTextMuted,
                              fontStyle: FontStyle.italic,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (ticket.deptJourney.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  DeptJourneySection(journey: ticket.deptJourney),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HeroBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const HeroBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedBackground,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: ThemeColors.unifiedBorder, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: ThemeColors.unifiedTextMuted),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: ThemeColors.unifiedTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class PriorityBadge extends StatelessWidget {
  final String priority;
  const PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (priority.toLowerCase()) {
      case 'urgent':
        color = ThemeColors.unifiedDanger;
      case 'high':
        color = const Color(0xFFEA580C);
      case 'medium':
        color = ThemeColors.unifiedWarning;
      default:
        color = ThemeColors.unifiedPrimary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
