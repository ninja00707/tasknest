import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/dashboard/widgets/priority_badges.dart';
import 'package:tasknest/presentation/dashboard/widgets/status_badges.dart';

class TicketGridCard extends StatelessWidget {
  final TicketModel ticket;
  const TicketGridCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final color = _ticketTypeColor(ticket);

    return GestureDetector(
      onTap: () => context.push('/ticket/${ticket.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeColors.unifiedSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: ticket.isOverdue
                ? ThemeColors.unifiedDanger.withValues(alpha: 0.35)
                : color.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.3)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              ticket.ticketNumber.isNotEmpty
                                  ? ticket.ticketNumber
                                  : '#${ticket.id}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: ThemeColors.unifiedTextMuted,
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (ticket.isStandardTicket)
                              _GridFlag(
                                label: 'STANDARD',
                                fg: ThemeColors.unifiedPrimary,
                                icon: Icons.article_rounded,
                              )
                            else if (ticket.isMultiTaskTicket)
                              _GridFlag(
                                label: 'MULTI TASK',
                                fg: const Color(0xFF7C3AED),
                                icon: Icons.hub_rounded,
                              ),
                            if (ticket.children.isNotEmpty)
                              _GridFlag(
                                label: 'SUB',
                                fg: const Color(0xFFD97706),
                                icon: Icons.account_tree_rounded,
                              ),
                          ],
                        ),
                      ),
                      PriorityBadge(priority: ticket.priority),
                      const SizedBox(width: 4),
                      StatusBadge(status: ticket.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (ticket.deptJourney.isNotEmpty) ...[
                    _GridJourney(journey: ticket.deptJourney),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    ticket.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: ThemeColors.unifiedTextPrimary,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (ticket.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      ticket.description,
                      style: const TextStyle(
                        fontSize: 11,
                        color: ThemeColors.unifiedTextMuted,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (ticket.isSubTicket && ticket.departmentCount > 1) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '${ticket.overallProgress}%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF7C3AED),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: ticket.overallProgress / 100,
                              minHeight: 4,
                              backgroundColor: const Color(0xFFEDE9FE),
                              valueColor: const AlwaysStoppedAnimation(
                                Color(0xFF7C3AED),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ] else ...[
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      Icon(
                        Icons.arrow_upward_rounded,
                        size: 11,
                        color: ThemeColors.unifiedPrimary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        ticket.createdByDeptCode,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: ThemeColors.unifiedTextMuted,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 11,
                        color: ThemeColors.unifiedSecondary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        ticket.assignedDeptCode,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: ThemeColors.unifiedTextMuted,
                        ),
                      ),
                      if (ticket.assignedToName != null) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.person_outline_rounded,
                          size: 11,
                          color: ThemeColors.unifiedTextMuted,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            ticket.assignedToName!,
                            style: const TextStyle(
                              fontSize: 10,
                              color: ThemeColors.unifiedTextMuted,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _ticketTypeColor(TicketModel t) {
  if (t.isMultiTaskTicket) return const Color(0xFF7C3AED);
  if (t.children.isNotEmpty) return const Color(0xFFD97706);
  return ThemeColors.unifiedPrimary;
}

class _GridFlag extends StatelessWidget {
  final String label;
  final Color fg;
  final IconData icon;
  const _GridFlag({required this.label, required this.fg, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: fg),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: fg,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _GridJourney extends StatelessWidget {
  final List<dynamic> journey;
  const _GridJourney({required this.journey});

  Color _roleColor(String role) {
    switch (role) {
      case 'ORIGIN':
        return ThemeColors.unifiedPrimary;
      case 'CURRENT':
        return ThemeColors.unifiedSecondary;
      case 'TRANSFER':
        return ThemeColors.unifiedWarning;
      default:
        return ThemeColors.unifiedTextMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Row(
        children: List.generate(journey.length, (index) {
          final dept = journey[index] as Map<String, dynamic>;
          final role = (dept['role'] ?? 'LINK').toString();
          final c = _roleColor(role);
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (index > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Icon(
                    Icons.chevron_right,
                    size: 12,
                    color: ThemeColors.unifiedTextMuted.withValues(alpha: 0.4),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  role,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    color: c,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
