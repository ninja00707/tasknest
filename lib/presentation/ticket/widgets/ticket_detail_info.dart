import 'package:flutter/material.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_date_format.dart';
import 'package:tasknest/core/theme/common_text_styles.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/ticket/widgets/ticket_action.dart';
import 'package:tasknest/presentation/ticket/widgets/ticket_comment_section.dart';
import 'package:tasknest/presentation/ticket/widgets/ticket_progress_timeline.dart';

class LeftColumn extends StatelessWidget {
  final TicketModel ticket;
  final UserModel user;
  const LeftColumn({required this.ticket, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionCard(
          icon: Icons.article_outlined,
          title: ConstStrings.description,
          child: Text(
            ticket.description,
            style: const TextStyle(
              fontSize: 14,
              color: ThemeColors.unifiedTextPrimary,
              height: 1.7,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 16),
        DetailsCard(ticket: ticket),
        if (ticket.children.isNotEmpty) ...[
          const SizedBox(height: 16),
          SectionCard(
            icon: Icons.account_tree_outlined,
            title: 'Sub Tickets (${ticket.children.length})',
            child: Column(
              children: ticket.children
                  .map((child) => ChildDetailCard(child: child))
                  .toList(),
            ),
          ),
        ],
        const SizedBox(height: 16),
        CommentSection(ticket: ticket, user: user),
      ],
    );
  }
}

class RightColumn extends StatelessWidget {
  final TicketModel ticket;
  final UserModel user;
  const RightColumn({required this.ticket, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionCard(
          icon: Icons.bolt_rounded,
          title: ConstStrings.actions,
          child: Center(
            child: TicketActions(ticket: ticket, user: user),
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          icon: Icons.timeline_rounded,
          title: ConstStrings.progress,
          child: ProgressTimeline(status: ticket.status),
        ),
      ],
    );
  }
}

// ── Section Card ──────────────────────────────────────────────────────────────
class SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.unifiedBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: ThemeColors.unifiedBorder),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: ThemeColors.unifiedPrimary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(
                    icon,
                    size: 15,
                    color: ThemeColors.unifiedPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: ThemeColors.unifiedTextMuted,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(18), child: child),
        ],
      ),
    );
  }
}

// ── Details Card ──────────────────────────────────────────────────────────────
class DetailsCard extends StatelessWidget {
  final TicketModel ticket;
  const DetailsCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      icon: Icons.info_outline_rounded,
      title: ConstStrings.ticketDetails,
      child: Column(
        children: [
          InfoRow(
            icon: Icons.person_outline_rounded,
            label: ConstStrings.createdBy,
            value: ticket.createdByName,
          ),
          InfoRow(
            icon: Icons.business_outlined,
            label: ConstStrings.createdDept,
            value: ticket.createdByDeptCode,
          ),
          if (ticket.deptJourney.length > 1)
            InfoRow(
              icon: Icons.my_library_books_rounded,
              label: ConstStrings.assignedDept,
              value: ticket.deptJourney
                  .where((j) => j['role'] != 'ORIGIN')
                  .map((j) => j['code'] as String)
                  .join(' → '),
            )
          else
            InfoRow(
              icon: Icons.my_library_books_rounded,
              label: ConstStrings.assignedDept,
              value: ticket.assignedDeptCode,
            ),
          ...buildAssignedTo(ticket),
          InfoRow(
            icon: Icons.calendar_today_outlined,
            label: ConstStrings.created,
            value: CommonDateFormat.formatDateTime(ticket.createdAt),
          ),
          if (ticket.dueDate != null)
            InfoRow(
              icon: Icons.event_outlined,
              label: ConstStrings.dueDate,
              value: CommonDateFormat.formatDateTime(ticket.dueDate),
              valueColor: ticket.isOverdue ? ThemeColors.unifiedDanger : null,
            ),
          if (ticket.closedAt != null)
            InfoRow(
              icon: Icons.lock_outline_rounded,
              label: ConstStrings.closedAt,
              value: CommonDateFormat.formatDateTime(ticket.closedAt),
            ),
          InfoRow(
            icon: Icons.replay_rounded,
            label: ConstStrings.reopenCount,
            value: '${ticket.reopenCount}',
          ),
          if (ticket.transferredFromCode != null &&
              ticket.transferredFromCode != 'None')
            InfoRow(
              icon: Icons.swap_horiz_rounded,
              label: ConstStrings.transferredFrom,
              value: ticket.transferredFromCode!,
            ),
          if (ticket.lastAction != null)
            InfoRow(
              icon: Icons.info_outline_rounded,
              label: ConstStrings.lastAction,
              value: ticket.lastAction!,
            ),
          if (ticket.lastActedByName != null)
            InfoRow(
              icon: Icons.person_outline_rounded,
              label: ConstStrings.lastActedBy,
              value: ticket.lastActedByName!,
            ),
          if (ticket.lastUpdatedAt != null)
            InfoRow(
              icon: Icons.schedule_rounded,
              label: ConstStrings.lastActionAt,
              value: CommonDateFormat.formatDateTime(ticket.lastUpdatedAt!),
              isLast: true,
            ),
        ],
      ),
    );
  }
}

// ── Child Detail Card ─────────────────────────────────────────────────────────
class ChildDetailCard extends StatelessWidget {
  final ChildTicketModel child;
  const ChildDetailCard({required this.child});

  Color get _statusColor {
    switch (child.status) {
      case 'completed':
        return ThemeColors.unifiedSuccess;
      case 'in_progress':
        return const Color(0xFF7C3AED);
      case 'open':
        return ThemeColors.unifiedSecondary;
      default:
        return ThemeColors.unifiedTextMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.unifiedBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  child.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ThemeColors.unifiedTextPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  child.status.toUpperCase().replaceAll('_', ' '),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: _statusColor,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (child.ticketNumber.isNotEmpty) ...[
                Icon(
                  Icons.tag_rounded,
                  size: 11,
                  color: ThemeColors.unifiedTextMuted,
                ),
                const SizedBox(width: 3),
                Text(
                  child.ticketNumber,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.unifiedTextMuted,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Icon(
                Icons.business_outlined,
                size: 11,
                color: ThemeColors.unifiedTextMuted,
              ),
              const SizedBox(width: 3),
              Text(
                child.deptCode,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.unifiedTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              if (child.assigneeName != null) ...[
                Icon(
                  Icons.person_outline,
                  size: 11,
                  color: ThemeColors.unifiedTextMuted,
                ),
                const SizedBox(width: 3),
                Text(
                  child.assigneeName!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: ThemeColors.unifiedTextMuted,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              if (child.hasActiveChildren)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    ConstStrings.hasSubTasks,
                    style: AppTextStyles.micro,
                  ),
                ),
              if (child.immediateChildCount > 0 && !child.hasActiveChildren)
                Text(
                  '${child.immediateChildCount} sub-task${child.immediateChildCount > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: ThemeColors.unifiedTextMuted,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Info Row ──────────────────────────────────────────────────────────────────
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isLast;

  const InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: isLast
          ? null
          : const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: ThemeColors.unifiedBorder),
              ),
            ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: ThemeColors.unifiedTextMuted),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: ThemeColors.unifiedTextMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: valueColor ?? ThemeColors.unifiedTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Assigned To helper ────────────────────────────────────────────────────────
List<Widget> buildAssignedTo(TicketModel ticket) {
  final parts = <String>[];
  if (ticket.myAssignedToName != null) parts.add(ticket.myAssignedToName!);
  for (final sd in ticket.subDepartments) {
    if (sd.assignedToName != null && !parts.contains(sd.assignedToName)) {
      parts.add('${sd.assignedToName} (${sd.departmentCode})');
    }
  }
  for (final child in ticket.children) {
    if (child.assigneeName != null && !parts.contains(child.assigneeName)) {
      parts.add('${child.assigneeName} (${child.deptCode})');
    }
  }
  if (parts.isEmpty) {
    if (ticket.assignedToName != null) {
      return [
        InfoRow(
          icon: Icons.assignment_ind_outlined,
          label: ConstStrings.assignedTo,
          value: ticket.assignedToName!,
        ),
      ];
    }
    return [];
  }
  return [
    InfoRow(
      icon: Icons.assignment_ind_outlined,
      label: ConstStrings.assignedTo,
      value: parts.join(', '),
    ),
  ];
}
