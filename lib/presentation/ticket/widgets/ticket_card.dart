import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_helpers.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/dashboard/widgets/priority_badges.dart';
import 'package:tasknest/presentation/dashboard/widgets/status_badges.dart';
import 'package:tasknest/presentation/ticket/widgets/ticket_action.dart';
import 'package:tasknest/presentation/ticket/widgets/ticket_card_base.dart';

class TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final UserModel user;
  final Function()? onTap;
  const TicketCard({
    super.key,
    required this.ticket,
    required this.user,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = ticketPriorityColor(ticket.priority);

    Color tileBg;
    switch (ticket.priority.toLowerCase()) {
      case 'urgent':
        tileBg = ThemeColors.unifiedDanger.withOpacity(0.06);
        break;
      case 'high':
        tileBg = const Color(0xFFEA580C).withOpacity(0.05);
        break;
      case 'medium':
        tileBg = ThemeColors.unifiedWarning.withOpacity(0.06);
        break;
      default:
        tileBg = ThemeColors.unifiedAccent.withOpacity(0.04);
    }

    return GestureDetector(
      onTap: onTap ?? () => context.push('/ticket/${ticket.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: tileBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ticket.isOverdue
                ? ThemeColors.unifiedDanger.withOpacity(0.35)
                : color.withOpacity(0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Left priority stripe ──────────────────────────────────
              Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [color, color.withOpacity(0.4)],
                  ),
                ),
              ),

              // ── Card body ─────────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Row 1: ID + flags + badges ───────────────────
                      Row(
                        children: [
                          IdChip(
                            label: ticket.ticketNumber.isNotEmpty
                                ? ticket.ticketNumber
                                : '#${ticket.id}',
                          ),
                          const SizedBox(width: 8),
                          if (ticket.isStandardTicket)
                            FlagChip(
                              label: 'STANDARD',
                              bg: ThemeColors.unifiedPrimary.withOpacity(0.08),
                              fg: ThemeColors.unifiedPrimary,
                              icon: Icons.article_rounded,
                            )
                          else if (ticket.isMultiTaskTicket)
                            FlagChip(
                              label: 'MULTI TASK',
                              bg: const Color(0xFFEDE9FE),
                              fg: const Color(0xFF7C3AED),
                              icon: Icons.hub_rounded,
                            ),
                          if (ticket.children.isNotEmpty)
                            FlagChip(
                              label: 'SUB',
                              bg: const Color(0xFFFEF3C7),
                              fg: const Color(0xFFD97706),
                              icon: Icons.account_tree_rounded,
                            ),
                          const Spacer(),
                          PriorityBadge(priority: ticket.priority),
                          const SizedBox(width: 6),
                          StatusBadge(status: ticket.status),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ── Row: Department Journey (Futuristic Path) ──────
                      if (ticket.deptJourney.isNotEmpty) ...[
                        DeptJourneySection(journey: ticket.deptJourney),
                        const SizedBox(height: 16),
                      ],

                      // ── Row 2: Title & Lineage ─────────────────────────
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (ticket.hasParent)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.subdirectory_arrow_right_rounded,
                                    size: 13,
                                    color: ThemeColors.unifiedTextMuted
                                        .withOpacity(0.6),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'CHILD OF ${ticket.parentTicketNumber ?? "#${ticket.parentTicketId}"} ${ticket.parentTicketTitle ?? ""}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: ThemeColors.unifiedTextMuted,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Text(
                            ticket.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: ThemeColors.unifiedTextPrimary,
                              letterSpacing: -0.3,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            ticket.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: ThemeColors.unifiedTextMuted,
                              height: 1.45,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // ── Row 4: Timeline / Stats ──────────────────────
                      if (ticket.isSubTicket) ...[
                        SubTicketProgressSection(ticket: ticket, user: user),
                        const SizedBox(height: 12),
                        Container(
                          height: 1,
                          color: ThemeColors.unifiedBorder.withOpacity(0.6),
                        ),
                        const SizedBox(height: 10),
                      ] else ...[
                        Container(
                          height: 1,
                          color: ThemeColors.unifiedBorder.withOpacity(0.6),
                        ),
                        const SizedBox(height: 10),
                      ],

                      // ── Row 5: Nested Child Tickets (One Card View) ──
                      if (ticket.children.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        ChildTicketsList(children: ticket.children, user: user),
                      ],

                      const SizedBox(height: 16),

                      // ── Row 6: Meta Info ─────────────────────────────
                      Row(
                        children: [
                          // MetaChip(
                          //   icon: Icons.arrow_upward_rounded,
                          //   iconColor: ThemeColors.unifiedPrimary,
                          //   label: ticket.createdByDeptCode,
                          // ),
                          if (!ticket.isSubTicket) ...[
                            MetaDivider(),
                            MetaChip(
                              icon: Icons.arrow_forward_rounded,
                              iconColor: ThemeColors.unifiedSecondary,
                              label: ticket.assignedDeptCode,
                            ),
                            if (ticket.assignedToName != null) ...[
                              MetaDivider(),
                              MetaChip(
                                icon: Icons.person_outline_rounded,
                                iconColor: ThemeColors.unifiedTextMuted,
                                label: ticket.assignedToName!,
                              ),
                              if (ticket.assignedToReportsToName != null) ...[
                                const SizedBox(width: 4),
                                // Text(
                                //   '→ ${ticket.assignedToReportsToName}',
                                //   style: const TextStyle(
                                //     fontSize: 10,
                                //     fontWeight: FontWeight.w500,
                                //     color: ThemeColors.unifiedTextMuted,
                                //   ),
                                // ),
                              ],
                            ],
                          ] else ...[
                            // MetaDivider(),
                            // MetaChip(
                            //   icon: Icons.groups_outlined,
                            //   iconColor: const Color(0xFF7C3AED),
                            //   label:
                            //       '${ticket.departmentCount} dept${ticket.departmentCount == 1 ? '' : 's'}',
                            // ),
                          ],
                          const Spacer(),
                          TicketActions(ticket: ticket, user: user),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
