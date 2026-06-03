import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/model/ticketmodel.dart';
import 'package:tasknest/presentation/dashboard/widgets/priority_badges.dart';
import 'package:tasknest/presentation/dashboard/widgets/status_badges.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/ticket_action.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

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
    final color = _priorityColor(ticket.priority);
    final isTransferred = ticket.transferredFromCode != null;

    return GestureDetector(
      onTap: onTap ?? () => context.push('/ticket/${ticket.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: ThemeColors.unifiedSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: ticket.isOverdue
                ? ThemeColors.unifiedDanger.withOpacity(0.35)
                : ThemeColors.unifiedBorder,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Row 1: ID + flags + badges ───────────────────
                      Row(
                        children: [
                          _IdChip(id: ticket.id),
                          const SizedBox(width: 8),
                          if (ticket.isStandardTicket)
                            _FlagChip(
                              label: 'STANDARD',
                              bg: ThemeColors.unifiedPrimary.withOpacity(0.08),
                              fg: ThemeColors.unifiedPrimary,
                              icon: Icons.article_rounded,
                            )
                          else if (ticket.isMultiTaskTicket)
                            _FlagChip(
                              label: 'MULTI TASK',
                              bg: const Color(0xFFEDE9FE),
                              fg: const Color(0xFF7C3AED),
                              icon: Icons.hub_rounded,
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
                        _DeptJourneySection(journey: ticket.deptJourney),
                        const SizedBox(height: 16),
                      ],

                      // ── Row 2: Title & Lineage ─────────────────────────
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (ticket.hasParent)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.subdirectory_arrow_right_rounded,
                                    size: 14,
                                    color: ThemeColors.unifiedTextMuted,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'CHILD OF #${ticket.parentTicketId}',
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
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: ThemeColors.unifiedTextPrimary,
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ── Row 3: Description ───────────────────────────
                      Text(
                        ticket.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: ThemeColors.unifiedTextPrimary,
                          letterSpacing: -0.2,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 5),

                      // ── Row 3: Description ───────────────────────────
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

                      const SizedBox(height: 12),

                      // ── Row 4: Timeline / Stats ──────────────────────
                      if (ticket.isSubTicket) ...[
                        _SubTicketProgressSection(ticket: ticket, user: user),
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
                        _ChildTicketsList(
                          children: ticket.children,
                          user: user,
                        ),
                      ],

                      const SizedBox(height: 16),

                      // ── Row 6: Meta Info ─────────────────────────────
                      Row(
                        children: [
                          _MetaChip(
                            icon: Icons.arrow_upward_rounded,
                            iconColor: ThemeColors.unifiedPrimary,
                            label: ticket.createdByDeptCode,
                          ),
                          if (!ticket.isSubTicket) ...[
                            _MetaDivider(),
                            _MetaChip(
                              icon: Icons.arrow_forward_rounded,
                              iconColor: ThemeColors.unifiedSecondary,
                              label: ticket.assignedDeptCode,
                            ),
                            if (ticket.assignedToName != null) ...[
                              _MetaDivider(),
                              _MetaChip(
                                icon: Icons.person_outline_rounded,
                                iconColor: ThemeColors.unifiedTextMuted,
                                label: ticket.assignedToName!,
                              ),
                            ],
                          ] else ...[
                            _MetaDivider(),
                            _MetaChip(
                              icon: Icons.groups_outlined,
                              iconColor: const Color(0xFF7C3AED),
                              label:
                                  '${ticket.departmentCount} dept${ticket.departmentCount == 1 ? '' : 's'}',
                            ),
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

// ── #ID Chip ──────────────────────────────────────────────────────────────────
class _IdChip extends StatelessWidget {
  final int id;
  const _IdChip({required this.id});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: ThemeColors.unifiedBorder),
      ),
      child: Text(
        '#$id',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: ThemeColors.unifiedTextMuted,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ── Flag Chip (OVERDUE / TRANSFERRED) ────────────────────────────────────────
class _FlagChip extends StatelessWidget {
  final String label;
  final Color bg, fg;
  final IconData icon;

  const _FlagChip({
    required this.label,
    required this.bg,
    required this.fg,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: fg),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
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

// ── Meta chip (dept / assignee) ───────────────────────────────────────────────
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _MetaChip({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: iconColor),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ThemeColors.unifiedTextMuted,
          ),
        ),
      ],
    );
  }
}

// ── Meta divider dot ──────────────────────────────────────────────────────────
class _MetaDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 7),
      decoration: const BoxDecoration(
        color: ThemeColors.unifiedBorder,
        shape: BoxShape.circle,
      ),
    );
  }
}

// ── Sub-ticket progress section ─────────────────────────────────────────────
class _SubTicketProgressSection extends StatelessWidget {
  final TicketModel ticket;
  final UserModel user;
  const _SubTicketProgressSection({required this.ticket, required this.user});

  @override
  Widget build(BuildContext context) {
    final myDeptTask = ticket.subDeptFor(user.departmentId);
    final isManager = user.roleId == 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Overall Progress',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: ThemeColors.unifiedTextMuted,
              ),
            ),
            const Spacer(),
            Text(
              '${ticket.overallProgress}%',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF7C3AED),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${ticket.completedDepartmentCount}/${ticket.departmentCount} done',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: ThemeColors.unifiedTextMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ticket.overallProgress / 100,
            minHeight: 6,
            backgroundColor: const Color(0xFFEDE9FE),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF7C3AED)),
          ),
        ),
        if (ticket.subDepartments.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: ticket.subDepartments.map((dept) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: dept.isCompleted
                      ? const Color(0xFFDCFCE7)
                      : ThemeColors.unifiedBackground,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: dept.isCompleted
                        ? const Color(0xFF16A34A).withOpacity(0.3)
                        : ThemeColors.unifiedBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      dept.departmentCode,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: dept.isCompleted
                            ? const Color(0xFF16A34A)
                            : const Color(0xFF7C3AED),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${dept.progressPercent}%',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: ThemeColors.unifiedTextMuted,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
        // ── Action Row for My Department (Multi Task) ────────────────
        if (myDeptTask != null && !myDeptTask.isCompleted) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF7C3AED).withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.assignment_ind_outlined,
                  size: 14,
                  color: Color(0xFF7C3AED),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    myDeptTask.isAssigned
                        ? 'Assigned to ${myDeptTask.assignedToName}'
                        : 'Unassigned ${myDeptTask.departmentCode} task',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: ThemeColors.unifiedTextPrimary,
                    ),
                  ),
                ),
                if (!myDeptTask.isAssigned) ...[
                  // Self Assign
                  _SmallActionBtn(
                    icon: Icons.person_add_alt_1_rounded,
                    onTap: () => context.read<DashboardBloc>().add(
                      SelfAssignSubDept(ticket.id, user.departmentId),
                    ),
                  ),
                  if (isManager) ...[
                    const SizedBox(width: 8),
                    // Assign to employee
                    _SmallActionBtn(
                      icon: Icons.manage_accounts_rounded,
                      onTap: () => _showSubDeptAssignDialog(
                        context,
                        ticket,
                        user.departmentId,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _showSubDeptAssignDialog(
    BuildContext context,
    TicketModel ticket,
    int deptId,
  ) {
    final bloc = context.read<DashboardBloc>();
    final state = bloc.state;
    if (state is! DashboardLoaded) return;

    if (state.employees.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No employees found')));
      return;
    }

    int selectedId = state.employees.first.id;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Assign Dept Task'),
              content: DropdownButtonFormField<int>(
                value: selectedId,
                items: state.employees.map((e) {
                  return DropdownMenuItem(value: e.id, child: Text(e.name));
                }).toList(),
                onChanged: (v) => setState(() => selectedId = v!),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    bloc.add(
                      AssignSubDeptEmployeeEvent(
                        ticketId: ticket.id,
                        departmentId: deptId,
                        employeeId: selectedId,
                      ),
                    );
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Assign'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _SmallActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _SmallActionBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: ThemeColors.unifiedBorder),
        ),
        child: Icon(icon, size: 14, color: ThemeColors.unifiedPrimary),
      ),
    );
  }
}

// ── Priority color helper ─────────────────────────────────────────────────────
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

// ── Child Tickets List (One Card View) ──────────────────────────────────────
class _ChildTicketsList extends StatelessWidget {
  final List<ChildTicketModel> children;
  final UserModel user;
  const _ChildTicketsList({required this.children, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.unifiedBackground.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.unifiedBorder.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(
                  Icons.account_tree_rounded,
                  size: 14,
                  color: ThemeColors.unifiedTextMuted,
                ),
                const SizedBox(width: 8),
                Text(
                  'SUB-TICKETS (${children.length})',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: ThemeColors.unifiedTextMuted,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: List.generate(children.length, (index) {
              final child = children[index];
              final isLast = index == children.length - 1;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: ThemeColors.unifiedPrimary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '#${child.id}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: ThemeColors.unifiedPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                child.title,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: ThemeColors.unifiedTextPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Dept: ${child.deptCode} • ${child.assigneeName ?? "Unassigned"}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: ThemeColors.unifiedTextMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        TicketActions(ticket: child, user: user),
                        const SizedBox(width: 8),
                        StatusBadge(status: child.status),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      color: ThemeColors.unifiedBorder.withOpacity(0.3),
                      indent: 12,
                      endIndent: 12,
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Department Journey Section ──────────────────────────────────────────────
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
