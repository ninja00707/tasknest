// ── Ticket Actions ────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart'
    as ds;
import 'package:tasknest/presentation/dashboard/widgets/action_button.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/ticket/bloc/ticket_bloc.dart';
import 'package:tasknest/presentation/ticket/bloc/ticket_event.dart';
import 'package:tasknest/presentation/ticket/bloc/ticket_state.dart' as ts;
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

/// Handles ticket transitions with strict role and resolver-based permissions.
/// Resolver: The user assigned to the ticket.
/// CEO: Restricted from specific actions per requirements.
class TicketActions extends StatelessWidget {
  final dynamic ticket; // Can be TicketModel or ChildTicketModel
  final UserModel user;
  const TicketActions({super.key, required this.ticket, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketBloc, ts.TicketState>(
        buildWhen: (prev, curr) => prev != curr,
        builder: (context, state) {
          final ticket = (state is ts.TicketDetailLoaded) ? state.ticket : this.ticket;
          final isLoading = state is ts.TicketActionInProgress;
          final bool isManager = user.roleId == 1;
          final bool isCeo = user.roleId == 0 || user.roleId == 3;
          final bool isResolver =
              ticket.assignedToId == user.id && ticket.assignedToId != null;
          final bool isCreator = ticket.createdById == user.id;
          final bool isCreatingDeptManager =
              user.roleId == 1 &&
              ticket is TicketModel &&
              ticket.createdByDeptId == user.departmentId;

          final bool isAssignedToMyDept =
              ticket.assignedDeptId == user.departmentId;

          final bool isUnassigned = ticket.assignedToId == null;
          final bool hasUnfinalizedSubs = ticket.hasActiveChildren;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (ticket.isOpen &&
                  !ticket.isManagementDisabled &&
                  isUnassigned &&
                  isAssignedToMyDept &&
                  !hasUnfinalizedSubs)
                ActionBtn(
                  icon: Icons.person_add_outlined,
                  tooltip: ConstStrings.selfAssign,
                  color: ThemeColors.unifiedSecondary,
                  onTap: () {
                    if (!isLoading) {
                      context.read<TicketBloc>().add(
                        SelfAssignTicket(ticket.id),
                      );
                    }
                  },
                ),

              if (isManager &&
                  !ticket.isManagementDisabled &&
                  isUnassigned &&
                  isAssignedToMyDept &&
                  !hasUnfinalizedSubs)
                ActionBtn(
                  icon: Icons.manage_accounts_outlined,
                  tooltip: ConstStrings.assignToEmployee,
                  color: ThemeColors.unifiedAccent,
                  onTap: () {
                    if (!isLoading) _showAssignDialog(context);
                  },
                ),

              if (ticket.isInProgress && !hasUnfinalizedSubs && isResolver)
                ActionBtn(
                  icon: Icons.check_circle_outline,
                  tooltip: ConstStrings.markDone,
                  color: ThemeColors.unifiedPrimary,
                  onTap: () {
                    if (!isLoading) {
                      _showStatusRemarkDialog(context, 'completed');
                    }
                  },
                ),

              if (ticket.isCompleted &&
                  !hasUnfinalizedSubs &&
                  (ticket is ChildTicketModel
                      ? isResolver
                      : (isCreator || isCeo || isCreatingDeptManager)))
                ActionBtn(
                  icon: Icons.lock_outline,
                  tooltip: ConstStrings.finalizeAndClose,
                  color: ThemeColors.unifiedPrimary,
                  onTap: () {
                    if (!isLoading) {
                      _showStatusRemarkDialog(context, 'closed');
                    }
                  },
                ),

              if (!ticket.isManagementDisabled &&
                  !isCeo &&
                  !isUnassigned &&
                  isResolver &&
                  ticket.immediateChildCount == 0)
                ActionBtn(
                  icon: Icons.add_link_rounded,
                  tooltip: ConstStrings.createSubTicket,
                  color: ThemeColors.unifiedWarning,
                  onTap: () {
                    if (!isLoading) _showSubTicketDialog(context, ticket);
                  },
                ),

              if ((isCreator || isCeo) && ticket.canReopenBy(user.id))
                ActionBtn(
                  icon: Icons.replay_rounded,
                  tooltip: ConstStrings.reopen,
                  color: ThemeColors.unifiedAccent,
                  onTap: () {
                    if (!isLoading) {
                      context.read<TicketBloc>().add(ReopenTicket(ticket.id));
                    }
                  },
                ),
            ],
          );
        },
      );
  }

  void _showAssignDialog(BuildContext context) {
    final bloc = context.read<TicketBloc>();
    final state = context.read<DashboardBloc>().state;
    ds.DashboardLoaded? loadedState;

    if (state is ds.DashboardLoaded) {
      loadedState = state;
    } else if (state is ds.DashboardActionSuccess) {
      loadedState = state.previousState;
    } else if (state is ds.DashboardActionError) {
      loadedState = state.previousState;
    }

    final ds.DashboardLoaded loaded = loadedState!;
    if (loaded.employees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(ConstStrings.noEmployeesInDept),
          backgroundColor: ThemeColors.unifiedDanger,
        ),
      );
      return;
    }

    int selectedEmployeeId = loaded.employees.first.id;

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
                items: loaded.employees.map((employee) {
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
                  print('DEBUG: Attempting to complete ticket ${ticket.id}');
                  print('DEBUG: User ID: ${user.id}, Ticket AssignedToID: ${ticket.assignedToId}');
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
    final titleController = TextEditingController(text: 'Sub: ${ticket.title}');
    final descController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final state = dashboardBloc.state;
    ds.DashboardLoaded? loadedState;

    if (state is ds.DashboardLoaded) {
      loadedState = state;
    } else if (state is ds.DashboardActionSuccess) {
      loadedState = state.previousState;
    } else if (state is ds.DashboardActionError) {
      loadedState = state.previousState;
    }

    final ds.DashboardLoaded loaded = loadedState!;

    // Rule 3: Prevent duplicate sub-ticket creation for the same department in the chain
    final occupiedDeptIds = ticket.deptJourney.map((j) => j['id']).toList();

    final depts = loaded.departments
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
