import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/constant/common_status.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/projects/widgets/UIhelpers.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

/// Responsive kanban board for project tickets.
///
/// Uses a compact, self-contained card ([ProjectTicketCard]) that follows the
/// dashboard ticket style (priority accent bar, chips, pills) but shows the
/// project ticket data completely.
///
/// - Wide (>= 900): three fixed-height, independently scrollable columns.
/// - Narrow: the three status groups stack vertically as full-width lists.
class ProjectTicketsBoard extends StatelessWidget {
  final List<TicketModel> tickets;
  const ProjectTicketsBoard({super.key, required this.tickets});

  static const _statuses = ['open', 'in_progress', 'closed'];
  static const _labels = ['Open', 'In Progress', 'Complete'];

  static const Map<String, Color> _columnColors = {
    'open': Color(0xFF2563EB),
    'in_progress': Color(0xFFF59E0B),
    'closed': Color(0xFF16A34A),
  };

  List<TicketModel> _forStatus(String status) =>
      tickets.where((t) => t.status == status).toList();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final columns = [
          for (var i = 0; i < _statuses.length; i++)
            _ProjectStatusColumn(
              label: _labels[i],
              color: _columnColors[_statuses[i]]!,
              tickets: _forStatus(_statuses[i]),
              scrollable: wide,
            ),
        ];

        if (wide) {
          final boardHeight = (MediaQuery.of(context).size.height * 0.55)
              .clamp(480.0, 640.0)
              .toDouble();
          return SizedBox(
            height: boardHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < columns.length; i++) ...[
                  if (i > 0) const SizedBox(width: 16),
                  Expanded(child: columns[i]),
                ],
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < columns.length; i++) ...[
              if (i > 0) const SizedBox(height: 18),
              columns[i],
            ],
          ],
        );
      },
    );
  }
}

class _ProjectStatusColumn extends StatelessWidget {
  final String label;
  final Color color;
  final List<TicketModel> tickets;
  final bool scrollable;
  const _ProjectStatusColumn({
    required this.label,
    required this.color,
    required this.tickets,
    required this.scrollable,
  });

  @override
  Widget build(BuildContext context) {
    final header = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
        border: Border(bottom: BorderSide(color: color.withValues(alpha: 0.14))),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${tickets.length}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );

    final emptyState = Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 30,
            color: ThemeColors.unifiedTextMuted.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 8),
          Text(
            'No tickets',
            style: TextStyle(
              fontSize: 12.5,
              color: ThemeColors.unifiedTextMuted.withValues(alpha: 0.55),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    final shell = Container(
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ThemeColors.unifiedBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: scrollable
          ? Column(
              children: [
                header,
                Expanded(
                  child: tickets.isEmpty
                      ? emptyState
                      : ListView.separated(
                          padding: const EdgeInsets.all(10),
                          itemCount: tickets.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, i) =>
                              ProjectTicketCard(ticket: tickets[i]),
                        ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                if (tickets.isEmpty)
                  emptyState
                else
                  ...tickets.map(
                    (t) => Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: ProjectTicketCard(ticket: t),
                    ),
                  ),
                const SizedBox(height: 10),
              ],
            ),
    );
    return shell;
  }
}

/// Compact project ticket card — dashboard ticket style (priority accent bar,
/// chips, pills) with complete project ticket info.
class ProjectTicketCard extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback? onTap;
  const ProjectTicketCard({super.key, required this.ticket, this.onTap});

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String get _dueLabel {
    final d = ticket.dueDate;
    if (d == null) return '';
    return 'Due ${d.day} ${_months[d.month - 1]}';
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'open':
        return 'OPEN';
      case 'in_progress':
        return 'IN PROGRESS';
      case 'closed':
        return 'COMPLETE';
      default:
        return s.replaceAll('_', ' ').toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ticket;
    final priorityColor = CommonStatus.ticketPriorityColor(t.priority);
    final statusColor = CommonStatus.ticketStatusColor(t.status);
    final overdue = t.isOverdue;
    final deptName =
        t.assignedDeptName.isNotEmpty ? t.assignedDeptName : t.assignedDeptCode;
    final showSubProgress = t.isSubTicket && t.overallProgress > 0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap ?? () => context.push('/ticket/${t.id}'),
        child: Container(
          decoration: BoxDecoration(
            color: ThemeColors.unifiedSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: overdue
                  ? ThemeColors.unifiedDanger.withValues(alpha: 0.4)
                  : priorityColor.withValues(alpha: 0.18),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: priorityColor.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 4, color: priorityColor),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header: number + flags + priority + status ──
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: priorityColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              t.ticketNumber.isNotEmpty
                                  ? t.ticketNumber
                                  : '#${t.id}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: priorityColor,
                              ),
                            ),
                          ),
                        ),
                        if (t.isSubTicket) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.account_tree_rounded,
                                  size: 11,
                                  color: Color(0xFFD97706),
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'SUB',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFD97706),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const Spacer(),
                        _Pill(
                          label: t.priority.toUpperCase(),
                          bg: priorityColor.withValues(alpha: 0.12),
                          fg: priorityColor,
                        ),
                        const SizedBox(width: 6),
                        _Pill(
                          label: _statusLabel(t.status),
                          bg: statusColor.withValues(alpha: 0.12),
                          fg: statusColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    // ── Title / description ──
                    Text(
                      t.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: ThemeColors.unifiedTextPrimary,
                        height: 1.25,
                      ),
                    ),
                    if (t.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        t.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ThemeColors.unifiedTextMuted,
                          height: 1.35,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Container(
                      height: 1,
                      color: ThemeColors.unifiedBorder.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 9),
                    // ── Meta: department + assignee ──
                    Row(
                      children: [
                        const Icon(
                          Icons.apartment_rounded,
                          size: 13,
                          color: ThemeColors.unifiedTextMuted,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            deptName.isNotEmpty ? deptName : 'No department',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: ThemeColors.unifiedTextMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (t.assignedToName != null &&
                            t.assignedToName != 'Unassigned') ...[
                          const SizedBox(width: 10),
                          InitialsAvatar(name: t.assignedToName!, size: 18),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              t.assignedToName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: ThemeColors.unifiedTextMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    // ── Footer: due date + sub-ticket progress ──
                    if (t.dueDate != null || showSubProgress) ...[
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          if (t.dueDate != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: overdue
                                    ? ThemeColors.unifiedDanger.withValues(
                                        alpha: 0.12,
                                      )
                                    : ThemeColors.unifiedInputBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.event_rounded,
                                    size: 11,
                                    color: overdue
                                        ? ThemeColors.unifiedDanger
                                        : ThemeColors.unifiedTextMuted,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _dueLabel,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: overdue
                                          ? ThemeColors.unifiedDanger
                                          : ThemeColors.unifiedTextMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (showSubProgress) ...[
                            const SizedBox(width: 10),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: (t.overallProgress / 100).clamp(0, 1),
                                  minHeight: 5,
                                  backgroundColor: ThemeColors.unifiedInputBg,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    ThemeColors.unifiedPrimary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${t.overallProgress}%',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: ThemeColors.unifiedPrimary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _Pill({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
          color: fg,
        ),
      ),
    );
  }
}
