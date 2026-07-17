import 'package:flutter/material.dart';
import 'package:tasknest/core/constant/common_status.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_section_container.dart';
import 'package:tasknest/core/theme/common_text.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/ticket/widgets/card_detailing_widget/common_baged.dart';
import 'package:tasknest/presentation/ticket/widgets/ticket_card_base.dart';

class TicketDetailHeader extends StatelessWidget {
  final TicketModel ticket;
  const TicketDetailHeader({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    // final priorityColor = ticketPriorityColor(ticket.priority);
    // final statusColor = ticketStatusColor(ticket.status);

    return Container(
      decoration: BoxDecoration(
        color: CommonStatus.ticketStatusColor(
          ticket.status,
        ).withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.unifiedBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: CommonStatus.ticketStatusColor(
              ticket.status,
            ).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: CommonStatus.ticketPriorityColor(ticket.priority),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.ticketNumber.isNotEmpty
                        ? '#${ticket.ticketNumber}'
                        : '#${ticket.id}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: ThemeColors.unifiedTextMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  CommonText(
                    ticket.title,
                    customeStyle: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: ThemeColors.unifiedTextPrimary,
                      letterSpacing: -0.4,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      CommonBadge(
                        label: ticket.isMultiTaskTicket
                            ? ConstStrings.multiTaskLabel
                            : ticket.isSubTicket
                            ? ConstStrings.subTicketLabel
                            : ConstStrings.standardLabel,
                        color: ThemeColors.navyAccentLight,
                      ),
                      //Ticket PriorityBadge
                      CommonBadge(
                        label: ticket.priority,
                        color: ThemeColors.unifiedPrimary,
                      ),
                      //Ticket Status Badge
                      CommonBadge(
                        label: ticket.status,

                        color: CommonStatus.ticketStatusColor(ticket.status),
                      ),
                      // if (ticket.isOverdue) const _OverdueBadge(),
                    ],
                  ),
                  if (ticket.hasParent) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeColors.unifiedBackground,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: ThemeColors.unifiedBorder.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.subdirectory_arrow_right_rounded,
                            size: 13,
                            color: ThemeColors.unifiedTextMuted,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              '${ConstStrings.childOf}${ticket.parentTicketNumber ?? '#${ticket.parentTicketId}'} ${ticket.parentTicketTitle ?? ""}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: ThemeColors.unifiedTextMuted,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (ticket.deptJourney.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    CommonSectionCardContainer(
                      icon: Icons.route_rounded,
                      title: ConstStrings.lifecyclePath,
                      child: DeptJourneySection(journey: ticket.deptJourney),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
