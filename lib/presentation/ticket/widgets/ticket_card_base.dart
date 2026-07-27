import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/constant/common_listview_builder.dart';
import 'package:tasknest/core/constant/common_status.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_text_styles.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/ticket/bloc/ticket_bloc.dart';
import 'package:tasknest/presentation/ticket/bloc/ticket_event.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/dashboard/widgets/status_badges.dart';
import 'package:tasknest/presentation/ticket/widgets/ticket_action.dart';

// ── #ID Chip ──────────────────────────────────────────────────────────────────
class IdChip extends StatelessWidget {
  final String label;
  const IdChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: ThemeColors.unifiedBorder),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: ThemeColors.unifiedTextMuted,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ── Flag Chip (OVERDUE / TRANSFERRED / STANDARD / SUB) ────────────────────────
class FlagChip extends StatelessWidget {
  final String label;
  final Color bg, fg;
  final IconData icon;

  const FlagChip({
    super.key,
    required this.label,
    required this.bg,
    required this.fg,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: fg),
          const SizedBox(width: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.5,
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
class MetaChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const MetaChip({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: iconColor),
        const SizedBox(width: 3),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 100),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: ThemeColors.unifiedTextMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class MetaDivider extends StatelessWidget {
  const MetaDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: const BoxDecoration(
        color: ThemeColors.unifiedBorder,
        shape: BoxShape.circle,
      ),
    );
  }
}

// ── Compact action button ─────────────────────────────────────────────────────
class _CompactActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  const _CompactActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 13),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10.5),
            ),
          ),
        ],
      ),
    );
  }
}

class SmallActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const SmallActionBtn({super.key, required this.icon, required this.onTap});

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
        child: Icon(icon, size: 13, color: ThemeColors.unifiedPrimary),
      ),
    );
  }
}

// ── Sub-ticket progress section ─────────────────────────────────────────────
class SubTicketProgressSection extends StatelessWidget {
  final TicketModel ticket;
  final UserModel user;
  const SubTicketProgressSection({
    super.key,
    required this.ticket,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final myDeptTask = ticket.subDeptFor(user.departmentId);
    final isManager = user.roleId == 1 || user.roleId == 0 || user.roleId == 3;
    final isCreator = user.id == ticket.createdById;
    final allSubDeptsCompleted =
        ticket.subDepartments.isNotEmpty &&
        ticket.subDepartments.every((dept) => dept.isCompleted);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Flexible(
              child: Text(
                ConstStrings.overallProgress,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.unifiedTextMuted,
                ),
              ),
            ),
            const Spacer(),
            Text(
              '${ticket.overallProgress}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF7C3AED),
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '${ticket.completedDepartmentCount}/${ticket.departmentCount} done',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.unifiedTextMuted,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ticket.overallProgress / 100,
            minHeight: 5,
            backgroundColor: const Color(0xFFEDE9FE),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF7C3AED)),
          ),
        ),
        if (ticket.subDepartments.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: ticket.subDepartments.map((dept) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                constraints: const BoxConstraints(maxWidth: 130),
                decoration: BoxDecoration(
                  color: dept.isCompleted
                      ? const Color(0xFFDCFCE7)
                      : ThemeColors.unifiedBackground,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: dept.isCompleted
                        ? const Color(0xFF16A34A).withValues(alpha: 0.3)
                        : ThemeColors.unifiedBorder,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        dept.departmentCode,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: dept.isCompleted
                              ? const Color(0xFF16A34A)
                              : const Color(0xFF7C3AED),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${dept.progressPercent}%',
                      style: const TextStyle(
                        fontSize: 9.5,
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

        if (isCreator && allSubDeptsCompleted && !ticket.isCompleted) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF059669).withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'All departments completed! Take action:',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF059669),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _CompactActionButton(
                        icon: Icons.check_circle_outline,
                        label: 'Mark as Done',
                        color: const Color(0xFF059669),
                        onPressed: !ticket.isCompleted
                            ? () => context.read<TicketBloc>().add(
                                MarkTicketAsDone(ticket.id),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _CompactActionButton(
                        icon: Icons.verified_outlined,
                        label: 'Finalize & Close',
                        color: const Color(0xFF7C3AED),
                        onPressed: !ticket.isCompleted
                            ? () => context.read<TicketBloc>().add(
                                FinalizeTicket(ticket.id),
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],

        if (myDeptTask != null && !myDeptTask.isCompleted) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.assignment_ind_outlined,
                  size: 13,
                  color: Color(0xFF7C3AED),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    myDeptTask.isAssigned
                        ? 'Assigned to ${myDeptTask.assignedToName}'
                        : 'Unassigned ${myDeptTask.departmentCode} task',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: ThemeColors.unifiedTextPrimary,
                    ),
                  ),
                ),
                if (!myDeptTask.isAssigned) ...[
                  SmallActionBtn(
                    icon: Icons.person_add_alt_1_rounded,
                    onTap: () => context.read<TicketBloc>().add(
                      SelfAssignSubDept(ticket.id, user.departmentId),
                    ),
                  ),
                  if (isManager) ...[
                    const SizedBox(width: 6),
                    SmallActionBtn(
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
    final dashboardBloc = context.read<DashboardBloc>();
    final bloc = context.read<TicketBloc>();
    final state = dashboardBloc.state;
    DashboardLoaded? loadedState;

    if (state is DashboardLoaded) {
      loadedState = state;
    } else if (state is DashboardActionSuccess) {
      loadedState = state.previousState;
    } else if (state is DashboardActionError) {
      loadedState = state.previousState;
    }

    if (loadedState == null) return;

    if (loadedState.employees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(ConstStrings.noEmployeesInDept)),
      );
      return;
    }

    int selectedId = loadedState.employees.first.id;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(ConstStrings.assignTicket),
              content: DropdownButtonFormField<int>(
                initialValue: selectedId,
                isExpanded: true,
                items: loadedState!.employees.map((e) {
                  return DropdownMenuItem(
                    value: e.id,
                    child: Text(
                      e.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (v) => setState(() => selectedId = v!),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(ConstStrings.cancel),
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
                  child: const Text(ConstStrings.assign),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ── Child Tickets List (One Card View) ──────────────────────────────────────
class ChildTicketsList extends StatelessWidget {
  final List<ChildTicketModel> children;
  final UserModel user;
  const ChildTicketsList({
    super.key,
    required this.children,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.unifiedBackground.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: ThemeColors.unifiedBorder.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
            child: Row(
              children: [
                const Icon(
                  Icons.account_tree_rounded,
                  size: 12,
                  color: ThemeColors.unifiedTextMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  'SUB-TICKETS (${children.length})',
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: ThemeColors.unifiedTextMuted,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          CommonListViewBuilder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            items: children,
            padding: EdgeInsets.zero,
            itemBuilder: (_, child, index) {
              final isLast = index == children.length - 1;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.push('/ticket/${child.id}'),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 3,
                              margin: const EdgeInsets.only(top: 2, right: 8),
                              decoration: BoxDecoration(
                                color: CommonStatus.ticketPriorityColor(
                                  child.priority,
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      IdChip(
                                        label: child.ticketNumber.isNotEmpty
                                            ? child.ticketNumber
                                            : '#${child.id}',
                                      ),
                                      const Spacer(),
                                      StatusBadge(status: child.status),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    child.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: ThemeColors.unifiedTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: _AssigneeChip(
                                          name: child.assigneeName,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      Flexible(
                                        child: Text(
                                          '• Dept: ${child.deptCode}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.micro,
                                        ),
                                      ),
                                      const Spacer(),
                                      TicketActions(ticket: child, user: user),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isLast)
                        Divider(
                          height: 1,
                          color: ThemeColors.unifiedBorder.withValues(
                            alpha: 0.3,
                          ),
                          indent: 10,
                          endIndent: 10,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AssigneeChip extends StatelessWidget {
  final String? name;
  const _AssigneeChip({this.name});

  @override
  Widget build(BuildContext context) {
    final label = name ?? 'Unassigned';
    final initial = (name?.isNotEmpty ?? false) ? name![0].toUpperCase() : '?';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 6.5,
          backgroundColor: name != null
              ? ThemeColors.unifiedPrimary.withValues(alpha: 0.15)
              : ThemeColors.unifiedBorder.withValues(alpha: 0.3),
          child: Text(
            initial,
            style: TextStyle(
              fontSize: 7.5,
              fontWeight: FontWeight.w700,
              color: name != null
                  ? ThemeColors.unifiedPrimary
                  : ThemeColors.unifiedTextPrimary.withValues(alpha: 0.5),
            ),
          ),
        ),
        const SizedBox(width: 4),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 70),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.micro,
          ),
        ),
      ],
    );
  }
}

// ── Department Journey Section ──────────────────────────────────────────────
class DeptJourneySection extends StatelessWidget {
  final List<dynamic> journey;
  const DeptJourneySection({super.key, required this.journey});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: ThemeColors.unifiedBorder.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.route_rounded,
                size: 11,
                color: ThemeColors.unifiedTextMuted,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  ConstStrings.lifecyclePath,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    color: ThemeColors.unifiedTextMuted.withValues(alpha: 0.8),
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
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
                  label = ConstStrings.origin;
                } else if (role == 'CURRENT') {
                  activeColor = ThemeColors.unifiedSecondary;
                  label = ConstStrings.current;
                } else if (role == 'TRANSFER') {
                  activeColor = ThemeColors.unifiedWarning;
                  label = ConstStrings.transfer;
                } else {
                  activeColor = ThemeColors.unifiedTextMuted;
                  label = ConstStrings.link;
                }

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      children: [
                        Container(
                          constraints: const BoxConstraints(maxWidth: 72),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isLast
                                ? activeColor.withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: isLast
                                  ? activeColor.withValues(alpha: 0.4)
                                  : ThemeColors.unifiedBorder,
                              width: isLast ? 1.3 : 1,
                            ),
                          ),
                          child: Text(
                            dept['code'] ?? '??',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isLast
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                              color: isLast
                                  ? activeColor
                                  : ThemeColors.unifiedTextPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 6.5,
                            fontWeight: FontWeight.w900,
                            color: isLast
                                ? activeColor
                                : ThemeColors.unifiedTextMuted,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                    if (!isLast)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 9,
                          color: ThemeColors.unifiedBorder.withValues(
                            alpha: 0.8,
                          ),
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
