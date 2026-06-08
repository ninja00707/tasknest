import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_helpers.dart';
import 'package:tasknest/core/theme/common_detail_appbar.dart';
import 'package:tasknest/core/theme/common_date_format.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/model/ticketmodel.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/ticket_action.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/sub_ticket_detail_section.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_history_timeline.dart';
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

    return BlocListener<DashboardBloc, DashboardState>(
      listener: (context, state) {
        if (state is DashboardActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: ThemeColors.unifiedPrimary,
            ),
          );
        } else if (state is DashboardActionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: ThemeColors.unifiedDanger,
            ),
          );
        } else if (state is DashboardError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message!),
              backgroundColor: ThemeColors.unifiedDanger,
            ),
          );
        }
      },
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          DashboardLoaded? loadedState;
          if (state is DashboardLoaded) {
            loadedState = state;
          } else if (state is DashboardActionSuccess) {
            loadedState = state.previousState;
          } else if (state is DashboardActionError) {
            loadedState = state.previousState;
          }

          if (loadedState == null) {
            return const _LoadingScaffold();
          }

          TicketModel? foundTicket;
          try {
            foundTicket = loadedState.tickets
                .followedBy(loadedState.sentTickets)
                .firstWhere((t) => t.id == ticketId);
          } catch (_) {
            for (var master in loadedState.tickets.followedBy(
              loadedState.sentTickets,
            )) {
              for (var child in master.children) {
                if (child.id == ticketId) {
                  foundTicket = TicketModel(
                    id: child.id,
                    title: child.title,
                    description: 'Sub-task of #${master.id}',
                    status: child.status,
                    priority: master.priority,
                    assignedDeptId: child.assignedDeptId,
                    assignedDeptCode: child.deptCode,
                    assignedDeptName: '',
                    createdByName: master.createdByName,
                    createdByDeptCode: master.createdByDeptCode,
                    createdByDeptId: master.createdByDeptId,
                    createdById: child.createdById,
                    createdAt: master.createdAt,
                    reopenCount: 0,
                    parentTicketId: master.id,
                    parentTicketTitle: master.title,
                    ticketType: 'standard',
                    assignedToId: child.assignedToId,
                    assignedToName: child.assigneeName,
                    history: const [],
                    deptJourney: const [],
                    children: const [],
                    immediateChildCount: child.immediateChildCount,
                    hasActiveChildren: child.hasActiveChildren,
                  );
                  break;
                }
              }
              if (foundTicket != null) break;
            }
          }

          final ticket =
              foundTicket ??
              TicketModel(
                id: 0,
                title: 'Unknown Ticket',
                description: 'No description available',
                priority: 'low',
                status: 'Unknown',
                assignedDeptCode: '',
                assignedDeptName: '',
                createdByName: '',
                createdByDeptCode: '',
                createdByDeptId: 0,
                createdById: 0,
                createdAt: DateTime.now(),
                reopenCount: 0,
                history: const [],
                assignedToId: null,
                assignedToName: null,
                deptJourney: const [],
                children: const [],
              );

          return Scaffold(
            backgroundColor: ThemeColors.unifiedBackground,
            appBar: CommonDetailAppbar(
              onHistoryPressed: null,
              ticket: ticket,
              title: null,
              issuffixStatus: true,
            ),
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
      ),
    );
  }
}

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

class _WideLayout extends StatelessWidget {
  final TicketModel ticket;
  final UserModel user;
  const _WideLayout({required this.ticket, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeroSection(ticket: ticket),
        const SizedBox(height: 24),
        if (ticket.isSubTicket || ticket.isMultiTaskTicket) ...[
          _ProgressSection(ticket: ticket),
          const SizedBox(height: 24),
        ],
        if (ticket.isSubTicket) ...[
          SubTicketDetailSection(ticket: ticket, user: user),
          const SizedBox(height: 24),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _LeftColumn(ticket: ticket, user: user)),
            const SizedBox(width: 20),
            Expanded(
              flex: 1,
              child: _RightColumn(ticket: ticket, user: user),
            ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  final TicketModel ticket;
  final UserModel user;
  const _NarrowLayout({required this.ticket, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeroSection(ticket: ticket),
        const SizedBox(height: 20),
        if (ticket.isSubTicket || ticket.isMultiTaskTicket) ...[
          _ProgressSection(ticket: ticket),
          const SizedBox(height: 20),
        ],
        if (ticket.isSubTicket) ...[
          SubTicketDetailSection(ticket: ticket, user: user),
          const SizedBox(height: 20),
        ],
        _LeftColumn(ticket: ticket, user: user),
        const SizedBox(height: 20),
        _RightColumn(ticket: ticket, user: user),
        const SizedBox(height: 40),
      ],
    );
  }
}

// ── Hero Section ─────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  final TicketModel ticket;
  const _HeroSection({required this.ticket});

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
                              _HeroBadge(
                                icon: Icons.tag_rounded,
                                label: ticket.ticketNumber.isNotEmpty
                                    ? ticket.ticketNumber
                                    : '#${ticket.id}',
                                color: ThemeColors.unifiedTextMuted,
                              ),
                              _HeroBadge(
                                icon: ticket.isMultiTaskTicket
                                    ? Icons.dashboard_rounded
                                    : Icons.task_alt_rounded,
                                label: ticket.isMultiTaskTicket
                                    ? 'Multi Task'
                                    : ticket.isSubTicket
                                        ? 'Sub Ticket'
                                        : 'Standard',
                                color: ThemeColors.unifiedSecondary,
                              ),
                              _PriorityBadge(priority: ticket.priority),
                              if (ticket.isOverdue)
                                _HeroBadge(
                                  icon: Icons.schedule_rounded,
                                  label: 'OVERDUE',
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
                            'Child of ${ticket.parentTicketNumber ?? '#${ticket.parentTicketId}'} ${ticket.parentTicketTitle ?? ""}',
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
                  _DeptJourneySection(journey: ticket.deptJourney),
                ],
                const SizedBox(height: 14),
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
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _HeroBadge({
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

class _PriorityBadge extends StatelessWidget {
  final String priority;
  const _PriorityBadge({required this.priority});

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

// ── Progress Section ─────────────────────────────────────────────────────────
class _ProgressSection extends StatelessWidget {
  final TicketModel ticket;
  const _ProgressSection({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final progress = ticket.overallProgress;
    final deptColor = const Color(0xFF7C3AED);

    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: deptColor.withOpacity(0.2), width: 1.5),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [deptColor, ThemeColors.unifiedSecondary],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: deptColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ticket.isMultiTaskTicket ? 'MULTI TASK' : 'SUB TICKET',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: deptColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$progress% Complete',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: progress == 100
                            ? ThemeColors.unifiedSuccess
                            : deptColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${ticket.departmentCount} departments · '
                  '${ticket.completedDepartmentCount} completed',
                  style: const TextStyle(
                    fontSize: 13,
                    color: ThemeColors.unifiedTextMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 10,
                    backgroundColor: deptColor.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation(
                      progress == 100
                          ? ThemeColors.unifiedSuccess
                          : deptColor,
                    ),
                  ),
                ),
                if (ticket.subDepartments.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Department Breakdown',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: ThemeColors.unifiedTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...ticket.subDepartments.map(
                    (dept) => _DeptMiniCard(dept: dept),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeptMiniCard extends StatelessWidget {
  final SubTicketDepartmentModel dept;
  const _DeptMiniCard({required this.dept});

  Color get _statusColor {
    if (dept.isCompleted) return ThemeColors.unifiedSuccess;
    if (dept.isApproved) return ThemeColors.unifiedSecondary;
    if (dept.isPendingApproval) return ThemeColors.unifiedWarning;
    if (dept.isInProgress) return const Color(0xFF7C3AED);
    return ThemeColors.unifiedTextMuted;
  }

  String get _statusLabel {
    if (dept.isCompleted) return 'DONE';
    if (dept.isApproved) return 'OK';
    if (dept.isPendingApproval) return 'REVIEW';
    if (dept.isInProgress) return 'ACTIVE';
    return 'OPEN';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ThemeColors.unifiedBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  dept.departmentCode,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7C3AED),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  dept.departmentName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: ThemeColors.unifiedTextPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: _statusColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${dept.progressPercent}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: dept.progressPercent / 100,
              minHeight: 5,
              backgroundColor: const Color(0xFFEDE9FE),
              valueColor: AlwaysStoppedAnimation(_statusColor),
            ),
          ),
          if (dept.taskDescription.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              dept.taskDescription,
              style: const TextStyle(
                fontSize: 12,
                color: ThemeColors.unifiedTextMuted,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (dept.assignedToName != null) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 12,
                    color: ThemeColors.unifiedTextMuted),
                const SizedBox(width: 4),
                Text(
                  dept.assignedToName!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.unifiedTextMuted,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Left Column ──────────────────────────────────────────────────────────────
class _LeftColumn extends StatelessWidget {
  final TicketModel ticket;
  final UserModel user;
  const _LeftColumn({required this.ticket, required this.user});

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
        _DetailsCard(ticket: ticket),
        const SizedBox(height: 16),
        _SectionCard(
          icon: Icons.history_edu_rounded,
          title: 'History',
          child: TicketHistoryTimeline(history: ticket.history ?? []),
        ),
        const SizedBox(height: 16),
        _CommentSection(ticket: ticket, user: user),
      ],
    );
  }
}

// ── Details Card ─────────────────────────────────────────────────────────────
class _DetailsCard extends StatelessWidget {
  final TicketModel ticket;
  const _DetailsCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
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
            label: 'Created Dept',
            value: ticket.createdByDeptCode,
          ),
          _DetailRow(
            icon: Icons.my_library_books_rounded,
            label: 'Assigned Dept',
            value: ticket.assignedDeptCode,
          ),
          if (ticket.assignedToName != null)
            _DetailRow(
              icon: Icons.assignment_ind_outlined,
              label: 'Assigned To',
              value: ticket.assignedToName!,
            ),
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Created',
            value: CommonDateFormat.formatDateTime(ticket.createdAt),
          ),
          if (ticket.dueDate != null)
            _DetailRow(
              icon: Icons.event_outlined,
              label: 'Due Date',
              value: CommonDateFormat.formatDateTime(ticket.dueDate),
              valueColor: ticket.isOverdue
                  ? ThemeColors.unifiedDanger
                  : null,
            ),
          if (ticket.closedAt != null)
            _DetailRow(
              icon: Icons.lock_outline_rounded,
              label: 'Closed At',
              value: CommonDateFormat.formatDateTime(ticket.closedAt),
            ),
          _DetailRow(
            icon: Icons.replay_rounded,
            label: 'Reopen Count',
            value: '${ticket.reopenCount}',
          ),
          if (ticket.transferredFromCode != null &&
              ticket.transferredFromCode != 'None')
            _DetailRow(
              icon: Icons.swap_horiz_rounded,
              label: 'Transferred From',
              value: ticket.transferredFromCode!,
            ),
          if (ticket.lastAction != null)
            _DetailRow(
              icon: Icons.info_outline_rounded,
              label: 'Last Action',
              value: ticket.lastAction!,
            ),
          if (ticket.lastActedByName != null)
            _DetailRow(
              icon: Icons.person_outline_rounded,
              label: 'Last Acted By',
              value: ticket.lastActedByName!,
            ),
          if (ticket.lastUpdatedAt != null)
            _DetailRow(
              icon: Icons.schedule_rounded,
              label: 'Last Action At',
              value: CommonDateFormat.formatDateTime(ticket.lastUpdatedAt!),
              isLast: true,
            ),
        ],
      ),
    );
  }
}

// ── Right Column ─────────────────────────────────────────────────────────────
class _RightColumn extends StatelessWidget {
  final TicketModel ticket;
  final UserModel user;
  const _RightColumn({required this.ticket, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionCard(
          icon: Icons.bolt_rounded,
          title: 'Actions',
          child: Center(
            child: TicketActions(ticket: ticket, user: user),
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          icon: Icons.timeline_rounded,
          title: 'Progress',
          child: _ProgressTimeline(status: ticket.status),
        ),
        if (ticket.children.isNotEmpty) ...[
          const SizedBox(height: 16),
          _SectionCard(
            icon: Icons.account_tree_outlined,
            title: 'Sub Tickets',
            child: Column(
              children: ticket.children.map((child) => _ChildTile(
                child: child,
                parentId: ticket.ticketNumber.isNotEmpty
                    ? ticket.ticketNumber
                    : '#${ticket.id}',
              )).toList(),
            ),
          ),
        ],
      ],
    );
  }
}

class _ChildTile extends StatelessWidget {
  final ChildTicketModel child;
  final String parentId;
  const _ChildTile({required this.child, required this.parentId});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    switch (child.status) {
      case 'completed':
        statusColor = ThemeColors.unifiedSuccess;
      case 'in_progress':
        statusColor = const Color(0xFF7C3AED);
      case 'open':
        statusColor = ThemeColors.unifiedSecondary;
      default:
        statusColor = ThemeColors.unifiedTextMuted;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ThemeColors.unifiedBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: ThemeColors.unifiedTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  child.ticketNumber.isNotEmpty
                      ? child.ticketNumber
                      : '#${child.id} · ${child.deptCode}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: ThemeColors.unifiedTextMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              child.status.toUpperCase().replaceAll('_', ' '),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared Widgets ───────────────────────────────────────────────────────────
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
                  child: Icon(icon, size: 15, color: ThemeColors.unifiedPrimary),
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

// ── Progress Timeline ────────────────────────────────────────────────────────
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
      children: steps
          .map(
            (s) => _TimelineItem(
              step: s,
              isActive: _isPassed(s.step),
              isCurrent: _isCurrentStep(s.step),
            ),
          )
          .toList(),
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
        Column(
          children: [
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
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 6, bottom: step.isLast ? 0 : 22),
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
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: step.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: step.color.withOpacity(0.3)),
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

// ── Comment Section (last comment first) ────────────────────────────────────
class _CommentSection extends StatefulWidget {
  final TicketModel ticket;
  final UserModel user;
  const _CommentSection({required this.ticket, required this.user});

  @override
  State<_CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<_CommentSection> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  bool get _isCreator => widget.user.id == widget.ticket.createdById;

  void _submitComment() {
    final msg = _commentController.text.trim();
    if (msg.isEmpty) return;
    context.read<DashboardBloc>().add(AddTicketComment(widget.ticket.id, msg));
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final comments = widget.ticket.comments;

    return _SectionCard(
      icon: Icons.chat_outlined,
      title: 'Comments (${comments.length})',
      child: Column(
        children: [
          // Comment input — only creator can post
          if (_isCreator && !widget.ticket.isClosed)
            Container(
              decoration: BoxDecoration(
                color: ThemeColors.unifiedBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ThemeColors.unifiedBorder),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _commentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Write a comment or update...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(14),
                    ),
                  ),
                  Container(
                    height: 1,
                    color: ThemeColors.unifiedBorder,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: _submitComment,
                          icon: const Icon(Icons.send_rounded, size: 15),
                          label: const Text('Post'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeColors.unifiedPrimary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (!_isCreator)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ThemeColors.unifiedInfo.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: ThemeColors.unifiedInfo.withOpacity(0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 15,
                    color: ThemeColors.unifiedInfo,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.ticket.isClosed
                          ? 'Comments are closed for this ticket.'
                          : 'Only the ticket creator can post comments.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: ThemeColors.unifiedInfo,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          // Comments list (last comment first — already sorted DESC from backend)
          if (comments.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No comments yet.',
                style: TextStyle(
                  color: ThemeColors.unifiedTextMuted,
                  fontSize: 13,
                ),
              ),
            )
          else
            ...comments.map((c) => _CommentTile(comment: c)),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommentModel comment;
  const _CommentTile({required this.comment});

  // ── Comment type detection ──────────────────────────────────────────
  bool get _isStatusRemark =>
      comment.message.startsWith('[COMPLETED REMARK]') ||
      comment.message.startsWith('[CLOSED REMARK]');

  bool get _isDeptRemark =>
      RegExp(r'^\[DEPT (COMPLETION|APPROVED|COMPLETED|PROGRESS)').hasMatch(comment.message);

  bool get _isSpecial => _isStatusRemark || _isDeptRemark;

  String get _typeLabel {
    if (_isStatusRemark) {
      return comment.message.startsWith('[COMPLETED REMARK]') ? 'MARKS DONE' : 'CLOSES';
    }
    if (_isDeptRemark) {
      if (comment.message.contains('COMPLETION')) return 'DEPT DONE';
      if (comment.message.contains('APPROVED')) return 'DEPT OK';
      if (comment.message.contains('COMPLETED')) return 'DEPT FINAL';
      return 'DEPT UPDATE';
    }
    return '';
  }

  IconData get _typeIcon {
    if (_isStatusRemark) return Icons.verified_rounded;
    if (_isDeptRemark) return Icons.workspace_premium_rounded;
    return Icons.person_rounded;
  }

  Color get _tintColor {
    if (_isStatusRemark) return ThemeColors.unifiedAccent;
    if (_isDeptRemark) return const Color(0xFF7C3AED);
    return ThemeColors.unifiedPrimary;
  }

  String get _displayName {
    if (_isStatusRemark) {
      return comment.message.startsWith('[COMPLETED REMARK]')
          ? 'Marked as Done'
          : 'Finalized & Closed';
    }
    if (_isDeptRemark) {
      final match = RegExp(r'^\[DEPT \w+ - (.+?)\]').firstMatch(comment.message);
      return match?.group(1) ?? 'Department';
    }
    return comment.userName;
  }

  String get _cleanMessage {
    return comment.message.replaceAll(RegExp(r'^\[[^\]]*\]:\s*'), '');
  }

  // ── Build ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _isSpecial
            ? _tintColor.withOpacity(0.04)
            : ThemeColors.unifiedBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isSpecial
              ? _tintColor.withOpacity(0.2)
              : ThemeColors.unifiedBorder,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _tintColor.withOpacity(0.12),
            child: Icon(_typeIcon, size: 16, color: _tintColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _displayName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _tintColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (_isSpecial)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: _tintColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _typeLabel,
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: _tintColor,
                            letterSpacing: 0.4,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: ThemeColors.unifiedSecondary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          comment.deptCode,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: ThemeColors.unifiedSecondary,
                          ),
                        ),
                      ),
                    const Spacer(),
                    Text(
                      CommonDateFormat.formatDateTime(comment.createdAt),
                      style: const TextStyle(
                        fontSize: 10,
                        color: ThemeColors.unifiedTextMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _cleanMessage,
                  style: TextStyle(
                    fontSize: 13,
                    color: _isSpecial
                        ? _tintColor.withOpacity(0.85)
                        : ThemeColors.unifiedTextPrimary,
                    height: 1.5,
                    fontWeight: _isSpecial ? FontWeight.w600 : FontWeight.w400,
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

// ── Route Chip ───────────────────────────────────────────────────────────────
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

// ── Dept Journey ─────────────────────────────────────────────────────────────
class _DeptJourneySection extends StatelessWidget {
  final List<dynamic> journey;
  const _DeptJourneySection({required this.journey});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.unifiedBorder.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.route_rounded,
                size: 12,
                color: ThemeColors.unifiedTextMuted,
              ),
              const SizedBox(width: 6),
              Text(
                'LIFECYCLE PATH',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: ThemeColors.unifiedTextMuted.withOpacity(0.8),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(journey.length, (index) {
                final dept = journey[index] as Map<String, dynamic>;
                final role = (dept['role'] ?? 'LINK').toString();
                final isLast = index == journey.length - 1;

                Color activeColor;
                String label = role;

                if (role == 'ORIGIN') {
                  activeColor = ThemeColors.unifiedPrimary;
                  label = 'ORIGIN';
                } else if (role == 'CURRENT') {
                  activeColor = ThemeColors.unifiedSecondary;
                  label = 'CURRENT';
                } else if (role == 'TRANSFER') {
                  activeColor = ThemeColors.unifiedWarning;
                  label = 'TRANSFER';
                } else {
                  activeColor = ThemeColors.unifiedTextMuted;
                  label = 'LINK';
                }

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isLast
                                ? activeColor.withOpacity(0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isLast
                                  ? activeColor.withOpacity(0.4)
                                  : ThemeColors.unifiedBorder,
                              width: isLast ? 1.5 : 1,
                            ),
                            boxShadow: isLast
                                ? [
                                    BoxShadow(
                                      color: activeColor.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            dept['code'] ?? '??',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isLast
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                              color: isLast
                                  ? activeColor
                                  : ThemeColors.unifiedTextPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.w900,
                            color: isLast
                                ? activeColor
                                : ThemeColors.unifiedTextMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    if (!isLast)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10,
                          color: ThemeColors.unifiedBorder.withOpacity(0.8),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

