import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_text_styles.dart';
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
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    widget.bloc.add(LoadTickets());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        List<AdminTicketModel> displayTickets = [];
        if (state is TicketsLoaded) {
          displayTickets = state.tickets.where((t) {
            if (_searchQuery.isEmpty) return true;
            final q = _searchQuery.toLowerCase();
            return (t.ticketNumber?.toLowerCase().contains(q) ?? false) ||
                t.title.toLowerCase().contains(q) ||
                (t.assignedToName?.toLowerCase().contains(q) ?? false) ||
                (t.createdByName?.toLowerCase().contains(q) ?? false) ||
                (t.assignedDeptName?.toLowerCase().contains(q) ?? false);
          }).toList();
        }

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Manage Tickets', style: AppTextStyles.pageTitle),
                  Row(
                    children: [
                      SizedBox(
                        width: 220,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: ConstStrings.searchTickets,
                            hintStyle: TextStyle(color: ThemeColors.unifiedTextMuted.withValues(alpha: 0.6), fontSize: 13),
                            prefixIcon: Icon(Icons.search_rounded, size: 18, color: ThemeColors.unifiedTextMuted),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear_rounded, size: 16, color: ThemeColors.unifiedTextMuted),
                                    onPressed: () => setState(() => _searchQuery = ''),
                                  )
                                : null,
                            filled: true,
                            fillColor: ThemeColors.unifiedBackground,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: ThemeColors.unifiedBorder)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: ThemeColors.unifiedBorder.withValues(alpha: 0.5))),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: ThemeColors.unifiedPrimary, width: 1.5)),
                          ),
                          onChanged: (v) => setState(() => _searchQuery = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButton<String?>(
                        value: _statusFilter,
                        hint: const Text(ConstStrings.allStatus),
                        items: const [
                          DropdownMenuItem(value: null, child: Text(ConstStrings.allStatus)),
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
              if (_searchQuery.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('${displayTickets.length} result${displayTickets.length == 1 ? '' : 's'} for "$_searchQuery"',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ThemeColors.unifiedTextMuted),
                  ),
                ),
              if (state is AdminLoading) const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (state is TicketsLoaded) _buildTable(displayTickets, state.filterStatus)
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
              DataCell(Text(t.ticketNumber ?? '-', style: AppTextStyles.caption)),
              DataCell(ConstrainedBox(constraints: const BoxConstraints(maxWidth: 200), child: Text(t.title, overflow: TextOverflow.ellipsis))),
              DataCell(_badge(t.status)),
              DataCell(_priorityBadge(t.priority)),
              DataCell(Text(t.assignedDeptName ?? '-', style: AppTextStyles.caption)),
              DataCell(Text(t.assignedToName ?? '-', style: AppTextStyles.caption)),
              DataCell(Text(t.createdByName ?? '-', style: AppTextStyles.caption)),
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
        title: const Text(ConstStrings.deleteTicket),
        content: Text('Delete ticket "${t.ticketNumber ?? t.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text(ConstStrings.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ThemeColors.unifiedDanger),
            onPressed: () {
              Navigator.pop(ctx);
              widget.bloc.add(DeleteTicket(t.id, context));
            },
            child: const Text(ConstStrings.delete),
          ),
        ],
      ),
    );
  }
}
