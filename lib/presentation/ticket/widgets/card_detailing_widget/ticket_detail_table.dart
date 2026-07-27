import 'package:flutter/material.dart';
import 'package:tasknest/core/constant/common_status.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_date_format.dart';
import 'package:tasknest/core/theme/common_section_container.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/ticket/widgets/card_detailing_widget/common_baged.dart';
import 'package:tasknest/presentation/ticket/widgets/card_detailing_widget/ticket_detail_table_raw.dart';

class DetailsCard extends StatelessWidget {
  final TicketModel ticket;
  const DetailsCard({super.key, required this.ticket});

  String get _typeLabel {
    if (ticket.isMultiTaskTicket) return ConstStrings.multiTaskLabel;
    if (ticket.isSubTicket) return ConstStrings.subTicketLabel;
    return ConstStrings.standardLabel;
  }

  String get _assignedToDisplay {
    if (ticket.subDepartments.isNotEmpty && ticket.subDepartments.any((d) => d.isAssigned)) {
      return ticket.subDepartments
          .where((d) => d.isAssigned)
          .map((d) => '${d.assignedToName} (${d.departmentCode})')
          .join(', ');
    }
    if (ticket.children.isNotEmpty && ticket.children.any((c) => c.assigneeName != null)) {
      return ticket.children
          .where((c) => c.assigneeName != null)
          .map((c) => '${c.assigneeName} (${c.deptCode})')
          .join(', ');
    }
    return ticket.assignedToName ?? ConstStrings.unassigned;
  }

  @override
  Widget build(BuildContext context) {
    return CommonSectionCardContainer(
      icon: Icons.info_outline_rounded,
      title: ConstStrings.ticketDetails,
      child: Column(
        children: [
          DetailRow(
            label: ConstStrings.status,
            value: ticket.status.toUpperCase().replaceAll('_', ' '),
            valueWidget: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: CommonStatus.ticketStatusColor(
                  ticket.status,
                ).withValues(alpha: 0.12),
                // ticketPriorityColor.statusColor(
                //   ticket.status,
                // ).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                ticket.status.toUpperCase().replaceAll('_', ' '),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: CommonStatus.ticketStatusColor(ticket.status),
                ),
              ),
            ),
          ),
          DetailRow(
            label: ConstStrings.htmlPriority,
            value: ticket.priority.toUpperCase(),
            valueWidget: CommonBadge(
              label: ticket.priority,
              color: CommonStatus.ticketStatusColor(ticket.status),
              // CommonStatusColor.statusColor(ticket.status),
            ),
          ),
          DetailRow(label: 'Type', value: _typeLabel),
          DetailRow(
            label: ConstStrings.createdBy,
            value: '${ticket.createdByName} (${ticket.createdByDeptCode})',
          ),
          DetailRow(
            label: ConstStrings.assignedDept,
            value: '${ticket.assignedDeptName} (${ticket.assignedDeptCode})',
          ),
          DetailRow(
            label: ConstStrings.assignedTo,
            value: _assignedToDisplay,
          ),
          DetailRow(
            label: ConstStrings.created,
            value: CommonDateFormat.formatDateTime(ticket.createdAt),
          ),
          if (ticket.dueDate != null)
            DetailRow(
              label: ConstStrings.dueDate,
              value: CommonDateFormat.formatDateTime(ticket.dueDate),
              valueColor: ticket.isOverdue ? ThemeColors.unifiedDanger : null,
              trailing: ticket.isOverdue
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeColors.unifiedDanger.withValues(
                          alpha: 0.12,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        ConstStrings.overdue,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: ThemeColors.unifiedDanger,
                        ),
                      ),
                    )
                  : null,
            ),
          if (ticket.closedAt != null)
            DetailRow(
              label: ConstStrings.closedAt,
              value: CommonDateFormat.formatDateTime(ticket.closedAt),
            ),
          DetailRow(
            label: ConstStrings.reopenCount,
            value: '${ticket.reopenCount}',
          ),
          if (ticket.transferredFromCode != null &&
              ticket.transferredFromCode != 'None')
            DetailRow(
              label: ConstStrings.transferredFrom,
              value: ticket.transferredFromCode!,
            ),
          if (ticket.lastAction != null)
            DetailRow(
              label: ConstStrings.lastAction,
              value: ticket.lastAction!,
            ),
          if (ticket.lastActedByName != null)
            DetailRow(
              label: ConstStrings.lastActedBy,
              value: ticket.lastActedByDeptName != null
                  ? '${ticket.lastActedByName!} (${ticket.lastActedByDeptName!})'
                  : ticket.lastActedByName!,
            ),
          if (ticket.lastUpdatedAt != null)
            DetailRow(
              label: ConstStrings.lastActionAt,
              value: CommonDateFormat.formatDateTime(ticket.lastUpdatedAt!),
              isLast:
                  ticket.assignedToReportsToName == null &&
                  ticket.createdByReportsToName == null &&
                  (ticket.myAssignedToName == null ||
                      ticket.myAssignedToName == ticket.assignedToName),
            ),
          // if (ticket.assignedToReportsToName != null)
          //   DetailRow(
          //     label: 'Reports To',
          //     value: ticket.assignedToReportsToName!,
          //     isLast:
          //         ticket.createdByReportsToName == null &&
          //         (ticket.myAssignedToName == null ||
          //             ticket.myAssignedToName == ticket.assignedToName),
          //   ),
          if (ticket.createdByReportsToName != null)
            DetailRow(
              label: 'Created By Reports To',
              value: ticket.createdByReportsToName!,
              isLast:
                  ticket.myAssignedToName == null ||
                  ticket.myAssignedToName == ticket.assignedToName,
            ),
          if (ticket.myAssignedToName != null &&
              ticket.myAssignedToName != ticket.assignedToName)
            DetailRow(
              label: 'My Assigned To',
              value: ticket.myAssignedToName!,
              isLast: true,
            ),
        ],
      ),
    );
  }
}
