// ── Ticket Actions ────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/model/ticketmodel.dart';
import 'package:tasknest/presentation/dashboard/widgets/action_button.dart';

class TicketActions extends StatelessWidget {
  final TicketModel ticket;
  const TicketActions({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Self-assign (only open, not yet assigned)
        if (ticket.isOpen && ticket.assignedToId == null)
          ActionBtn(
            icon: Icons.person_add_outlined,
            tooltip: 'Self Assign',
            color: ThemeColors.unifiedSecondary,
            onTap: () =>
                context.read<DashboardBloc>().add(SelfAssignTicket(ticket.id)),
          ),

        // Mark as completed
        if (ticket.isInProgress)
          ActionBtn(
            icon: Icons.check_circle_outline,
            tooltip: 'Mark Completed',
            color: ThemeColors.unifiedPrimary,
            onTap: () => context.read<DashboardBloc>().add(
              UpdateTicketStatus(ticket.id, 'completed'),
            ),
          ),

        // Close ticket (manager or resolver)
        if (ticket.isCompleted)
          ActionBtn(
            icon: Icons.lock_outline,
            tooltip: 'Close Ticket',
            color: ThemeColors.unifiedTextMuted,
            onTap: () => context.read<DashboardBloc>().add(
              UpdateTicketStatus(ticket.id, 'closed'),
            ),
          ),

        // Transfer
        if (!ticket.isClosed)
          ActionBtn(
            icon: Icons.swap_horiz_rounded,
            tooltip: 'Transfer',
            color: ThemeColors.unifiedWarning,
            onTap: () => _showTransferDialog(context, ticket),
          ),

        // Reopen
        if ((ticket.isClosed || ticket.isCompleted) && ticket.reopenCount < 1)
          ActionBtn(
            icon: Icons.replay_rounded,
            tooltip: 'Reopen',
            color: ThemeColors.unifiedAccent,
            onTap: () =>
                context.read<DashboardBloc>().add(ReopenTicket(ticket.id)),
          ),
      ],
    );
  }

  void _showTransferDialog(BuildContext context, TicketModel ticket) {
    final bloc = context.read<DashboardBloc>();
    final state = bloc.state;
    if (state is! DashboardLoaded) return;

    final depts = state.departments.where((d) => d.tier == 'lower').toList();
    int? selectedDeptId;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Transfer Ticket',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: ThemeColors.unifiedTextPrimary,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return DropdownButtonFormField<int>(
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
              items: depts
                  .map(
                    (d) => DropdownMenuItem(value: d.id, child: Text(d.name)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => selectedDeptId = v),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: selectedDeptId == null
                ? null
                : () {
                    bloc.add(TransferTicket(ticket.id, selectedDeptId!));
                    Navigator.pop(context);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.unifiedPrimary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Transfer'),
          ),
        ],
      ),
    );
  }
}
