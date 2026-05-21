import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/model/ticketmodel.dart';
import 'package:tasknest/presentation/dashboard/widgets/priority_badges.dart';
import 'package:tasknest/presentation/dashboard/widgets/status_badges.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/ticket_action.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

class TicketDetailScreen extends StatelessWidget {
  final int ticketId;
  final UserModel user;

  const TicketDetailScreen({
    super.key,
    required this.ticketId,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 1000;

    return BlocBuilder<DashboardBloc, DashboardState>(
      buildWhen: (prev, curr) =>
          curr is DashboardLoaded || curr is DashboardLoading,
      builder: (context, state) {
        if (state is! DashboardLoaded) {
          return const _LoadingScaffold();
        }

        final ticket = state.tickets.firstWhere(
          (t) => t.id == ticketId,
          orElse: () => TicketModel(
            id: 0,
            title: 'Unknown Ticket',
            description: 'No description available',
            priority: 'low',
            status: 'Unknown',
            assignedDeptCode: '',
            assignedDeptName: '',
            createdByName: '',
            createdByDeptCode: '',
            createdAt: DateTime.now(),
            reopenCount: 0,
          ),
        );

        return Scaffold(
          backgroundColor: ThemeColors.unifiedBackground,
          appBar: _DetailAppBar(ticket: ticket),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide
                  ? MediaQuery.sizeOf(context).width * 0.1
                  : 16,
              vertical: 24,
            ),
            child: isWide
                ? _WideLayout(ticket: ticket, user: user)
                : _NarrowLayout(ticket: ticket, user: user),
          ),
        );
      },
    );
  }
}

// ── Loading scaffold ──────────────────────────────────────────────────────────
class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.unifiedBackground,
      appBar: AppBar(
        backgroundColor: ThemeColors.unifiedSurface,
        elevation: 0,
        title: const Text('Loading...'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: ThemeColors.unifiedBorder),
        ),
      ),
      body: const Center(
        child: CircularProgressIndicator(color: ThemeColors.unifiedPrimary),
      ),
    );
  }
}

// ── App Bar ───────────────────────────────────────────────────────────────────
class _DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TicketModel ticket;
  const _DetailAppBar({required this.ticket});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ThemeColors.unifiedSurface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: ThemeColors.unifiedBorder),
      ),
      leading: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: ThemeColors.unifiedBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ThemeColors.unifiedBorder, width: 1.5),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: ThemeColors.unifiedTextPrimary,
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: ThemeColors.unifiedBackground,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: ThemeColors.unifiedBorder, width: 1.5),
            ),
            child: Text(
              '#${ticket.id}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: ThemeColors.unifiedTextMuted,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              ticket.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: ThemeColors.unifiedTextPrimary,
                letterSpacing: -0.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Row(
            children: [
              PriorityBadge(priority: ticket.priority),
              const SizedBox(width: 6),
              StatusBadge(status: ticket.status),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Wide layout ───────────────────────────────────────────────────────────────
class _WideLayout extends StatelessWidget {
  final TicketModel ticket;
  final UserModel user;
  const _WideLayout({required this.ticket, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeroCard(ticket: ticket),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _MainInfoColumn(ticket: ticket)),
            const SizedBox(width: 20),
            Expanded(flex: 1, child: _SidePanelColumn(ticket: ticket, user: user)),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

// ── Narrow layout ─────────────────────────────────────────────────────────────
class _NarrowLayout extends StatelessWidget {
  final TicketModel ticket;
  final UserModel user;
  const _NarrowLayout({required this.ticket, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeroCard(ticket: ticket),
        const SizedBox(height: 20),
        _MainInfoColumn(ticket: ticket),
        const SizedBox(height: 20),
        _SidePanelColumn(ticket: ticket, user: user),
        const SizedBox(height: 40),
      ],
    );
  }
}

// ── Hero card ─────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final TicketModel ticket;
  const _HeroCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final priorityColor = _priorityColor(ticket.priority);

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
          // Gradient top bar
          Container(
            height: 5,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [ThemeColors.unifiedGradStart, ThemeColors.unifiedGradEnd],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Priority color circle icon
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
                      const SizedBox(height: 6),
                      const Text(
                        'Tracking details and history for this request',
                        style: TextStyle(
                          fontSize: 13,
                          color: ThemeColors.unifiedTextMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Route row
                      Row(
                        children: [
                          _RouteChip(
                            icon: Icons.arrow_upward_rounded,
                            label: ticket.createdByDeptCode,
                            color: ThemeColors.unifiedPrimary,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: ThemeColors.unifiedTextMuted,
                            ),
                          ),
                          _RouteChip(
                            icon: Icons.arrow_forward_rounded,
                            label: ticket.assignedDeptCode,
                            color: ThemeColors.unifiedSecondary,
                          ),
                          if (ticket.isOverdue) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: ThemeColors.unifiedDanger.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: ThemeColors.unifiedDanger.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.schedule_rounded,
                                      size: 10, color: ThemeColors.unifiedDanger),
                                  SizedBox(width: 3),
                                  Text('OVERDUE',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: ThemeColors.unifiedDanger,
                                        letterSpacing: 0.3,
                                      )),
                                ],
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
        ],
      ),
    );
  }
}

class _RouteChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _RouteChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Main info column ──────────────────────────────────────────────────────────
class _MainInfoColumn extends StatelessWidget {
  final TicketModel ticket;
  const _MainInfoColumn({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionCard(
          icon: Icons.article_outlined,
          title: 'Description',
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
        _SectionCard(
          icon: Icons.info_outline_rounded,
          title: 'Ticket Details',
          child: Column(
            children: [
              _DetailRow(
                icon: Icons.person_outline_rounded,
                label: 'Created By',
                value: ticket.createdByName,
              ),
              _DetailRow(
                icon: Icons.business_outlined,
                label: 'Department',
                value: ticket.assignedDeptName,
              ),
              if (ticket.assignedToName != null)
                _DetailRow(
                  icon: Icons.assignment_ind_outlined,
                  label: 'Assigned To',
                  value: ticket.assignedToName!,
                ),
              _DetailRow(
                icon: Icons.calendar_today_outlined,
                label: 'Created At',
                value: ticket.createdAt.toString().split('.').first,
              ),
              if (ticket.dueDate != null)
                _DetailRow(
                  icon: Icons.event_outlined,
                  label: 'Due Date',
                  value: ticket.dueDate!.toString().split('.').first,
                  valueColor: ticket.isOverdue
                      ? ThemeColors.unifiedDanger
                      : null,
                ),
              if (ticket.closedAt != null)
                _DetailRow(
                  icon: Icons.lock_outline_rounded,
                  label: 'Closed At',
                  value: ticket.closedAt!.toString().split('.').first,
                ),
              _DetailRow(
                icon: Icons.replay_rounded,
                label: 'Reopen Count',
                value: '${ticket.reopenCount}',
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Side panel column ─────────────────────────────────────────────────────────
class _SidePanelColumn extends StatelessWidget {
  final TicketModel ticket;
  final UserModel user;
  const _SidePanelColumn({required this.ticket, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionCard(
          icon: Icons.bolt_rounded,
          title: 'Actions',
          child: Center(child: TicketActions(ticket: ticket, user: user)),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          icon: Icons.timeline_rounded,
          title: 'Ticket Progress',
          child: _ProgressTimeline(status: ticket.status),
        ),
      ],
    );
  }
}

// ── Shared section card ───────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
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
          // Card header
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
                  child: Icon(icon,
                      size: 15, color: ThemeColors.unifiedPrimary),
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
          Padding(
            padding: const EdgeInsets.all(18),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ── Detail row ────────────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isLast;

  const _DetailRow({
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

// ── Progress timeline ─────────────────────────────────────────────────────────
class _ProgressTimeline extends StatelessWidget {
  final String status;
  const _ProgressTimeline({required this.status});

  bool _isPassed(int step) {
    final s = status.toLowerCase();
    if (s == 'closed') return true;
    if (s == 'completed' && step <= 3) return true;
    if (s == 'in_progress' && step <= 2) return true;
    if (s == 'open' && step <= 1) return true;
    return false;
  }

  bool _isCurrentStep(int step) {
    final s = status.toLowerCase();
    if (s == 'open' && step == 1) return true;
    if (s == 'in_progress' && step == 2) return true;
    if (s == 'completed' && step == 3) return true;
    if (s == 'closed' && step == 4) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      _TimelineStep(
        step: 1,
        icon: Icons.add_circle_outline_rounded,
        title: 'Ticket Created',
        description: 'Request logged in the system.',
        color: ThemeColors.unifiedPrimary,
      ),
      _TimelineStep(
        step: 2,
        icon: Icons.assignment_ind_outlined,
        title: 'In Progress',
        description: 'A resolver is working on this.',
        color: ThemeColors.unifiedSecondary,
      ),
      _TimelineStep(
        step: 3,
        icon: Icons.check_circle_outline_rounded,
        title: 'Completed',
        description: 'Task finished, awaiting closure.',
        color: ThemeColors.unifiedAccent,
      ),
      _TimelineStep(
        step: 4,
        icon: Icons.lock_outline_rounded,
        title: 'Closed',
        description: 'Resolved and archived.',
        color: ThemeColors.unifiedTextMuted,
        isLast: true,
      ),
    ];

    return Column(
      children: steps.map((s) => _TimelineItem(
        step: s,
        isActive: _isPassed(s.step),
        isCurrent: _isCurrentStep(s.step),
      )).toList(),
    );
  }
}

class _TimelineStep {
  final int step;
  final IconData icon;
  final String title, description;
  final Color color;
  final bool isLast;

  const _TimelineStep({
    required this.step,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.isLast = false,
  });
}

class _TimelineItem extends StatelessWidget {
  final _TimelineStep step;
  final bool isActive, isCurrent;

  const _TimelineItem({
    required this.step,
    required this.isActive,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = isActive ? step.color : ThemeColors.unifiedBorder;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Left: dot + connector ─────────────────────────────────────
        Column(
          children: [
            // Step dot
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isActive
                    ? step.color.withOpacity(0.1)
                    : ThemeColors.unifiedBackground,
                shape: BoxShape.circle,
                border: Border.all(
                  color: dotColor,
                  width: isCurrent ? 2.5 : 1.5,
                ),
              ),
              child: Icon(step.icon, size: 17, color: dotColor),
            ),
            if (!step.isLast)
              Container(
                width: 2,
                height: 32,
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: isActive
                      ? step.color.withOpacity(0.35)
                      : ThemeColors.unifiedBorder,
                ),
              ),
          ],
        ),
        const SizedBox(width: 14),

        // ── Right: text ───────────────────────────────────────────────
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              top: 6,
              bottom: step.isLast ? 0 : 22,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isActive
                              ? ThemeColors.unifiedTextPrimary
                              : ThemeColors.unifiedTextMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        step.description,
                        style: const TextStyle(
                          fontSize: 11,
                          color: ThemeColors.unifiedTextMuted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCurrent)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: step.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: step.color.withOpacity(0.3)),
                    ),
                    child: Text(
                      'NOW',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: step.color,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Priority color helper ─────────────────────────────────────────────────────
Color _priorityColor(String p) {
  switch (p.toLowerCase()) {
    case 'urgent': return ThemeColors.unifiedDanger;
    case 'high':   return const Color(0xFFEA580C);
    case 'medium': return ThemeColors.unifiedWarning;
    default:       return ThemeColors.unifiedPrimary;
  }
}