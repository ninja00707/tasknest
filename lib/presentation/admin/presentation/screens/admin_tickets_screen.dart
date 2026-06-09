import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/admin/data/models/admin_models.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_bloc.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_event.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_state.dart';

class AdminTicketsScreen extends StatefulWidget {
  final AdminBloc bloc;
  const AdminTicketsScreen({super.key, required this.bloc});

  @override
  State<AdminTicketsScreen> createState() => _AdminTicketsScreenState();
}

class _AdminTicketsScreenState extends State<AdminTicketsScreen> {
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    widget.bloc.add(LoadTickets());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Manage Tickets', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: ThemeColors.unifiedTextPrimary)),
                  Row(
                    children: [
                      DropdownButton<String?>(
                        value: _statusFilter,
                        hint: const Text('All Status'),
                        items: const [
                          DropdownMenuItem(value: null, child: Text('All Status')),
                          DropdownMenuItem(value: 'open', child: Text('Open')),
                          DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                          DropdownMenuItem(value: 'completed', child: Text('Completed')),
                          DropdownMenuItem(value: 'closed', child: Text('Closed')),
                        ],
                        onChanged: (v) {
                          setState(() => _statusFilter = v);
                          widget.bloc.add(LoadTickets(status: v));
                        },
                      ),
                      const SizedBox(width: 8),
                      IconButton(icon: const Icon(Icons.refresh), onPressed: () => widget.bloc.add(LoadTickets(status: _statusFilter))),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (state is AdminLoading) const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (state is TicketsLoaded) _buildTable(state.tickets, state.filterStatus)
              else if (state is AdminError) Expanded(child: Center(child: Text(state.message, style: const TextStyle(color: ThemeColors.unifiedDanger))))
              else const SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTable(List<AdminTicketModel> tickets, String? filter) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ThemeColors.unifiedBorder),
        ),
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(ThemeColors.unifiedBackground),
            columns: const [
              DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.w700))),
              DataColumn(label: Text('Ticket #', style: TextStyle(fontWeight: FontWeight.w700))),
              DataColumn(label: Text('Title', style: TextStyle(fontWeight: FontWeight.w700))),
              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w700))),
              DataColumn(label: Text('Priority', style: TextStyle(fontWeight: FontWeight.w700))),
              DataColumn(label: Text('Dept', style: TextStyle(fontWeight: FontWeight.w700))),
              DataColumn(label: Text('Assigned To', style: TextStyle(fontWeight: FontWeight.w700))),
              DataColumn(label: Text('Created By', style: TextStyle(fontWeight: FontWeight.w700))),
              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.w700))),
            ],
            rows: tickets.map((t) => DataRow(cells: [
              DataCell(Text('${t.id}')),
              DataCell(Text(t.ticketNumber ?? '-', style: const TextStyle(fontSize: 12))),
              DataCell(ConstrainedBox(constraints: const BoxConstraints(maxWidth: 200), child: Text(t.title, overflow: TextOverflow.ellipsis))),
              DataCell(_badge(t.status)),
              DataCell(_priorityBadge(t.priority)),
              DataCell(Text(t.assignedDeptName ?? '-', style: const TextStyle(fontSize: 12))),
              DataCell(Text(t.assignedToName ?? '-', style: const TextStyle(fontSize: 12))),
              DataCell(Text(t.createdByName ?? '-', style: const TextStyle(fontSize: 12))),
              DataCell(IconButton(
                icon: const Icon(Icons.delete, size: 18, color: ThemeColors.unifiedDanger),
                onPressed: () => _confirmDelete(context, t),
                tooltip: 'Delete Ticket',
              )),
            ])).toList(),
          ),
        ),
      ),
    );
  }

  Widget _badge(String status) {
    Color bg, fg;
    switch (status) {
      case 'open': bg = ThemeColors.statusOpenBg; fg = ThemeColors.statusOpenFg; break;
      case 'in_progress': bg = ThemeColors.statusProgressBg; fg = ThemeColors.statusProgressFg; break;
      case 'completed': bg = ThemeColors.statusDoneBg; fg = ThemeColors.statusDoneFg; break;
      default: bg = ThemeColors.statusClosedBg; fg = ThemeColors.statusClosedFg;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(status.replaceAll('_', ' ').toUpperCase(), style: TextStyle(fontSize: 11, color: fg, fontWeight: FontWeight.w600)),
    );
  }

  Widget _priorityBadge(String priority) {
    Color bg, fg;
    switch (priority) {
      case 'low': bg = ThemeColors.priorityLowBg; fg = ThemeColors.priorityLowFg; break;
      case 'medium': bg = ThemeColors.priorityMedBg; fg = ThemeColors.priorityMedFg; break;
      case 'high': bg = ThemeColors.priorityHighBg; fg = ThemeColors.priorityHighFg; break;
      default: bg = ThemeColors.priorityUrgentBg; fg = ThemeColors.priorityUrgentFg;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(priority.toUpperCase(), style: TextStyle(fontSize: 11, color: fg, fontWeight: FontWeight.w600)),
    );
  }

  void _confirmDelete(BuildContext dialogContext, AdminTicketModel t) {
    showDialog(
      context: dialogContext,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Ticket?'),
        content: Text('Delete ticket "${t.ticketNumber ?? t.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ThemeColors.unifiedDanger),
            onPressed: () {
              Navigator.pop(ctx);
              widget.bloc.add(DeleteTicket(t.id, context));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
