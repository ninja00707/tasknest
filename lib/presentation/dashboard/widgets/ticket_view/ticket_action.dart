// ── Ticket Actions ────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/data/datasource/localstorage/sharedpreferences.dart';
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
  final TicketModel ticket;
  final UserModel user;
  const TicketActions({super.key, required this.ticket, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is! DashboardLoaded) {
          return const SizedBox.shrink();
        }

        final bool isManager = user.roleId == 1;
        final bool isCeo = user.roleId == 0;
        final bool isResolver = ticket.assignedToId == user.id;
        final bool isAssignedToMyDept =
            ticket.assignedDeptId == user.departmentId;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Self Assign: Open to employees/managers in the department
            if (ticket.isOpen &&
                ticket.assignedToId == null &&
                isAssignedToMyDept)
              ActionBtn(
                icon: Icons.person_add_outlined,
                tooltip: 'Self Assign',
                color: ThemeColors.unifiedSecondary,
                onTap: () => context.read<DashboardBloc>().add(
                  SelfAssignTicket(ticket.id),
                ),
              ),

            // 2. Managerial Assign: Only for Managers
            if (isManager &&
                ticket.assignedToId == null &&
                state.employees.isNotEmpty &&
                isAssignedToMyDept)
              ActionBtn(
                icon: Icons.manage_accounts_outlined,
                tooltip: 'Assign to Employee',
                color: ThemeColors.unifiedAccent,
                onTap: () => _showAssignDialog(context, state),
              ),

            // 3. Resolver Action: Mark Completed (Done). CEO is restricted.
            if (ticket.isInProgress && isResolver && !isCeo)
              ActionBtn(
                icon: Icons.check_circle_outline,
                tooltip: 'Mark Done',
                color: ThemeColors.unifiedPrimary,
                onTap: () => context.read<DashboardBloc>().add(
                  UpdateTicketStatus(ticket.id, 'completed'),
                ),
              ),

            // 4. Resolver Action: Close. Restricted for CEO.
            if (ticket.isCompleted && isResolver && !isCeo)
              ActionBtn(
                icon: Icons.lock_outline,
                tooltip: 'Finalize & Close',
                color: ThemeColors.unifiedTextMuted,
                onTap: () => context.read<DashboardBloc>().add(
                  UpdateTicketStatus(ticket.id, 'closed'),
                ),
              ),

            // 5. Transfer: Only if unassigned (Manager) or if current user is the Resolver.
            if (!ticket.isClosed &&
                !isCeo &&
                ((isManager && ticket.assignedToId == null) || isResolver))
              ActionBtn(
                icon: Icons.swap_horiz_rounded,
                tooltip: 'Transfer Dept',
                color: ThemeColors.unifiedWarning,
                onTap: () => _showTransferDialog(context, ticket),
              ),

            // 6. Reopen: For those who need to resume work
            if ((ticket.isClosed || ticket.isCompleted) &&
                ticket.reopenCount < 1)
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
          builder: (context, setState) {
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
                    context.read<DashboardBloc>().add(
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

  void _showTransferDialog(BuildContext context, TicketModel ticket) {
    if (ticket.isOpen) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Open tickets cannot be transferred. Please assign or start progress first.',
          ),
          backgroundColor: ThemeColors.unifiedDanger,
        ),
      );

      return;
    }

    final bloc = context.read<DashboardBloc>();
    final state = bloc.state;

    if (state is! DashboardLoaded) return;

    final depts = state.departments
        .where((d) => d.id != ticket.assignedDeptId)
        .toList();

    if (depts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No departments available for transfer')),
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
                'Transfer Ticket',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.unifiedTextPrimary,
                ),
              ),
              content: DropdownButtonFormField<int>(
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
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedDeptId == ticket.assignedDeptId) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Ticket is already in the selected department.',
                          ),
                          backgroundColor: ThemeColors.unifiedDanger,
                        ),
                      );
                      return;
                    }
                    bloc.add(TransferTicket(ticket.id, selectedDeptId));
                    Navigator.pop(dialogContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColors.unifiedPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text('Transfer'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
