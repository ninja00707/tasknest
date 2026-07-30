// ── Ticket Actions ────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/widgets/action_button.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/ticket/bloc/ticket_bloc.dart';
import 'package:tasknest/presentation/ticket/bloc/ticket_event.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

/// Handles ticket transitions with strict role and resolver-based permissions.
/// Resolver: The user assigned to the ticket.
/// Rules:
///   - Mark Completed: sub-ticket → resolver only; master → creator or CEO
///   - Finalize & Close: only the ticket CREATOR (for both sub-tickets and master)
///   - Reopen: only the ticket CREATOR
class TicketActions extends StatelessWidget {
  final dynamic ticket; // Can be TicketModel or ChildTicketModel
  final UserModel user;
  const TicketActions({super.key, required this.ticket, required this.user});

  @override
  Widget build(BuildContext context) {
    final bool isManager = user.roleId == 1;
    final bool isCeo = user.roleId == 0;
    final bool isDeveloper = user.roleId == 3;
    final bool isResolver =
        ticket.assignedToId == user.id && ticket.assignedToId != null;
    final bool isCreator = ticket.createdById == user.id;
    final bool isAssignedToMyDept = ticket.assignedDeptId == user.departmentId;

    // Once ticket is created user can't do anything until the ticket is assigned
    final bool isUnassigned = ticket.assignedToId == null;

    // Cannot mark done or finalize if any child is still not finalized (Closed)
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
            tooltip: ConstStrings.selfAssign,
            color: ThemeColors.unifiedSecondary,
            onTap: () =>
                context.read<TicketBloc>().add(SelfAssignTicket(ticket.id)),
          ),

        // 2. Managerial Assign: Only for Managers of the assigned department if unassigned
        if (isManager &&
            !ticket.isManagementDisabled &&
            isUnassigned &&
            isAssignedToMyDept &&
            !hasUnfinalizedSubs)
          ActionBtn(
            icon: Icons.manage_accounts_outlined,
            tooltip: ConstStrings.assignToEmployee,
            color: ThemeColors.unifiedAccent,
            onTap: () => _showAssignDialog(context),
          ),

        // 3. Mark Completed — sub-ticket: resolver only; master: creator only
        if (ticket.isInProgress &&
            !hasUnfinalizedSubs &&
            (ticket is ChildTicketModel ? isResolver : isCreator))
          ActionBtn(
            icon: Icons.check_circle_outline,
            tooltip: ConstStrings.markDone,
            color: ThemeColors.unifiedPrimary,
            onTap: () => _showStatusRemarkDialog(context, 'closed'),
          ),

        // 4. Create Sub Ticket: only the assigned person (resolver) can create sub-tickets
        if (!ticket.isManagementDisabled &&
            !isUnassigned &&
            ticket.immediateChildCount == 0 &&
            isResolver)
          ActionBtn(
            icon: Icons.add_link_rounded,
            tooltip: ConstStrings.createSubTicket,
            color: ThemeColors.unifiedWarning,
            onTap: () => _showSubTicketDialog(context, ticket),
          ),

        // 6. Reopen: Creator only (CEO also allowed as fallback)
        if ((isCreator || isCeo || isDeveloper) && ticket.canReopenBy(user.id))
          ActionBtn(
            icon: Icons.replay_rounded,
            tooltip: ConstStrings.reopen,
            color: ThemeColors.unifiedAccent,
            onTap: () =>
                context.read<TicketBloc>().add(ReopenTicket(ticket.id)),
          ),
      ],
    );
  }

  void _showAssignDialog(BuildContext context) {
    final bloc = context.read<TicketBloc>();
    final state = context.read<DashboardBloc>().state;
    if (state is! DashboardLoaded) return;
    if (state.employees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(ConstStrings.noEmployeesInDept),
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
                ConstStrings.assignTicket,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.unifiedTextPrimary,
                ),
              ),
              content: DropdownButtonFormField<int>(
                initialValue: selectedEmployeeId,
                decoration: InputDecoration(
                  labelText: ConstStrings.employee,
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
                  child: const Text(ConstStrings.cancel),
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
                  child: const Text(ConstStrings.assign),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showStatusRemarkDialog(BuildContext context, String status) {
    final bloc = context.read<TicketBloc>();
    final controller = TextEditingController();
    final label = 'close';
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Add remark before $label'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: ConstStrings.workSummaryHint,
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(ConstStrings.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                final remark = controller.text.trim();
                if (remark.isEmpty) return;
                Navigator.pop(dialogContext);
                bloc.add(UpdateTicketStatus(ticket.id, status, remark: remark));
              },
              child: const Text(ConstStrings.submit),
            ),
          ],
        );
      },
    );
  }

  void _showSubTicketDialog(BuildContext context, dynamic ticket) {
    final dashboardBloc = context.read<DashboardBloc>();
    final bloc = context.read<TicketBloc>();
    final titleController = TextEditingController(text: "Sub: ${ticket.title}");
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();

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

    // Rule 3: Prevent duplicate sub-ticket creation for the same department in the chain
    final occupiedDeptIds = ticket.deptJourney.map((j) => j['id']).toList();

    final depts = loadedState.departments
        .where((d) => !occupiedDeptIds.contains(d.id))
        .toList();

    if (depts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(ConstStrings.noDeptsForSubTicket)),
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
                ConstStrings.createSubTicket,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.unifiedTextPrimary,
                ),
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: ConstStrings.title,
                        hintText: ConstStrings.enterSubTicketTitle,
                      ),
                      validator: (v) =>
                          v!.isEmpty ? ConstStrings.titleRequired : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: ConstStrings.descriptionLabel,
                        hintText: ConstStrings.enterTaskDescription,
                      ),
                      maxLines: 2,
                      validator: (v) =>
                          v!.isEmpty ? ConstStrings.descriptionRequired : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: selectedDeptId,
                      decoration: InputDecoration(
                        labelText: ConstStrings.targetDepartment,
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
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(ConstStrings.cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      bloc.add(
                        TransferTicket(
                          ticket.id,
                          selectedDeptId,
                          title: titleController.text.trim(),
                          description: descController.text.trim(),
                        ),
                      );
                      Navigator.pop(dialogContext);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColors.unifiedPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: const Text(ConstStrings.createSubTicket),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
