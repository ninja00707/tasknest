// ── Ticket Actions ────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/theme/color.dart';

import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/model/ticketmodel.dart';
import 'package:tasknest/presentation/dashboard/widgets/action_button.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

/// Handles ticket transitions with strict role and resolver-based permissions.
/// Resolver: The user assigned to the ticket.
/// CEO: Restricted from specific actions per requirements.
class TicketActions extends StatelessWidget {
  final dynamic ticket; // Can be TicketModel or ChildTicketModel
  final UserModel user;
  const TicketActions({super.key, required this.ticket, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
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
          return const SizedBox.shrink();
        }

        final bool isManager = user.roleId == 1;
        final bool isCeo = user.roleId == 0;
        final bool isResolver =
            ticket.assignedToId == user.id && ticket.assignedToId != null;
        final bool isCreator = ticket.createdById == user.id;
        final bool isCreatingDeptManager =
            user.roleId == 1 &&
            ticket is TicketModel &&
            ticket.createdByDeptId == user.departmentId;

        final bool isAssignedToMyDept =
            ticket.assignedDeptId == user.departmentId;

        // NEW RULES:
        // 1. Once ticket is created user can't not do anything until the ticket is assigned
        final bool isUnassigned = ticket.assignedToId == null;

        // RULE: Cannot mark done or finalize if any child (recursive) is still not finalized (Closed)
        final bool hasUnfinalizedSubs = ticket.hasActiveChildren;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Self Assign: Only if unassigned and in my dept
            if (ticket.isOpen &&
                !ticket.isManagementDisabled &&
                isUnassigned &&
                isAssignedToMyDept &&
                !hasUnfinalizedSubs)
              ActionBtn(
                icon: Icons.person_add_outlined,
                tooltip: 'Self Assign',
                color: ThemeColors.unifiedSecondary,
                onTap: () => context.read<DashboardBloc>().add(
                  SelfAssignTicket(ticket.id),
                ),
              ),

            // 2. Managerial Assign: Only for Managers of the assigned department if unassigned
            if (isManager &&
                !ticket.isManagementDisabled &&
                isUnassigned &&
                isAssignedToMyDept &&
                !hasUnfinalizedSubs)
              ActionBtn(
                icon: Icons.manage_accounts_outlined,
                tooltip: 'Assign to Employee',
                color: ThemeColors.unifiedAccent,
                onTap: () => _showAssignDialog(context, loadedState!),
              ),

            // 3. Resolver Action: Mark Completed (Done).
            if (ticket.isInProgress &&
                !hasUnfinalizedSubs &&
                (isResolver || isCeo || (isManager && isAssignedToMyDept)))
              ActionBtn(
                icon: Icons.check_circle_outline,
                tooltip: 'Mark Done',
                color: ThemeColors.unifiedPrimary,
                onTap: () => _showStatusRemarkDialog(context, 'completed'),
              ),

            // 4. Creator/CEO/Creating Dept Manager Action: Finalize & Close
            if (ticket.isCompleted &&
                !hasUnfinalizedSubs &&
                (isCreator || isCeo || isCreatingDeptManager))
              ActionBtn(
                icon: Icons.lock_outline,
                tooltip: 'Finalize & Close',
                color: ThemeColors.unifiedPrimary,
                onTap: () => _showStatusRemarkDialog(context, 'closed'),
              ),

            // 5. Create Sub Ticket: Disabled if Completed, Closed, unassigned or if sub-ticket already exists
            // RULE: Creator and Resolver (and anyone in assigned dept) are allowed ONCE to create a sub-ticket
            if (!ticket.isManagementDisabled &&
                !isCeo &&
                !isUnassigned &&
                ticket.immediateChildCount == 0 &&
                isAssignedToMyDept)
              ActionBtn(
                icon: Icons.add_link_rounded,
                tooltip: 'Create Sub Ticket',
                color: ThemeColors.unifiedWarning,
                onTap: () => _showSubTicketDialog(context, ticket),
              ),

            // 6. Reopen: Restricted to Creator/CEO based on model rules
            if ((isCreator || isCeo) && ticket.canReopenBy(user.id))
              ActionBtn(
                icon: Icons.replay_rounded,
                tooltip: 'Reopen',
                color: ThemeColors.unifiedAccent,
                onTap: () =>
                    context.read<DashboardBloc>().add(ReopenTicket(ticket.id)),
              ),
          ],
        );
      },
    );
  }

  void _showAssignDialog(BuildContext context, DashboardLoaded state) {
    final bloc = context.read<DashboardBloc>();
    if (state.employees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No employees found in your department'),
          backgroundColor: ThemeColors.unifiedDanger,
        ),
      );
      return;
    }

    int selectedEmployeeId = state.employees.first.id;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (stfContext, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text(
                'Assign Ticket',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.unifiedTextPrimary,
                ),
              ),
              content: DropdownButtonFormField<int>(
                value: selectedEmployeeId,
                decoration: InputDecoration(
                  labelText: 'Employee',
                  filled: true,
                  fillColor: ThemeColors.unifiedInputBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: ThemeColors.unifiedBorder,
                    ),
                  ),
                ),
                items: state.employees.map((employee) {
                  return DropdownMenuItem<int>(
                    value: employee.id,
                    child: Text('${employee.name} (${employee.deptCode})'),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedEmployeeId = value;
                    });
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    bloc.add(
                      AssignTicketToEmployee(ticket.id, selectedEmployeeId),
                    );
                    Navigator.pop(dialogContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColors.unifiedPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text('Assign'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showStatusRemarkDialog(BuildContext context, String status) {
    final bloc = context.read<DashboardBloc>();
    final controller = TextEditingController();
    final label = status == 'completed' ? 'done' : 'close';
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Add remark before $label'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Write work summary / closing remark',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final remark = controller.text.trim();
                if (remark.isEmpty) return;
                Navigator.pop(dialogContext);
                bloc.add(UpdateTicketStatus(ticket.id, status, remark: remark));
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _showSubTicketDialog(BuildContext context, dynamic ticket) {
    final bloc = context.read<DashboardBloc>();
    final state = bloc.state;
    DashboardLoaded? loadedState;

    if (state is DashboardLoaded) {
      loadedState = state;
    } else if (state is DashboardActionSuccess) {
      loadedState = state.previousState;
    } else if (state is DashboardActionError) {
      loadedState = state.previousState;
    }

    if (loadedState == null) return;

    final int? assignedDeptId = ticket is TicketModel
        ? ticket.assignedDeptId
        : (ticket as ChildTicketModel).assignedDeptId;

    final depts = loadedState.departments
        .where((d) => d.id != assignedDeptId)
        .toList();

    if (depts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No departments available for sub-ticket'),
        ),
      );

      return;
    }

    int selectedDeptId = depts.first.id;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text(
                'Create Sub Ticket',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.unifiedTextPrimary,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'This will create a new sub-ticket for the selected department linked to this ticket.',
                    style: TextStyle(
                      fontSize: 13,
                      color: ThemeColors.unifiedTextMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: selectedDeptId,
                    decoration: InputDecoration(
                      labelText: 'Target Department',
                      filled: true,
                      fillColor: ThemeColors.unifiedInputBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: ThemeColors.unifiedBorder,
                        ),
                      ),
                    ),
                    items: depts.map((d) {
                      return DropdownMenuItem<int>(
                        value: d.id,
                        child: Text(d.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedDeptId = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    bloc.add(TransferTicket(ticket.id, selectedDeptId));
                    Navigator.pop(dialogContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColors.unifiedPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text('Create Sub Ticket'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
