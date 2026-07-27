import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_text_styles.dart';
import 'package:tasknest/presentation/admin/data/models/admin_models.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_bloc.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_event.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_state.dart';
import 'package:tasknest/presentation/admin/presentation/widgets/admin_ticket_edit_dialog.dart';
import 'package:intl/intl.dart';

class AdminTicketsScreen extends StatefulWidget {
  final AdminBloc bloc;
  const AdminTicketsScreen({super.key, required this.bloc});

  @override
  State<AdminTicketsScreen> createState() => _AdminTicketsScreenState();
}

class _AdminTicketsScreenState extends State<AdminTicketsScreen> {
  @override
  void initState() {
    super.initState();
    widget.bloc.add(LoadTickets());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      buildWhen: (prev, curr) => curr is TicketsLoaded || curr is AdminLoading || curr is AdminError,
      builder: (context, state) {
        final tickets = state is TicketsLoaded ? state.tickets : <AdminTicketModel>[];
        final filterStatus = state is TicketsLoaded ? state.filterStatus : null;
        final searchQuery = state is TicketsLoaded ? state.searchQuery : '';
        final page = state is TicketsLoaded ? state.clampedPage : 1;
        final totalPages = state is TicketsLoaded ? state.totalPages : 1;

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
                      _searchField(widget.bloc, searchQuery),
                      const SizedBox(width: 8),
                      _statusDropdown(widget.bloc, filterStatus),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () => widget.bloc.add(LoadTickets(status: filterStatus)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (state is AdminLoading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (state is TicketsLoaded)
                Expanded(
                  child: Column(
                    children: [
                      Expanded(child: _buildTable(context, tickets)),
                      if (totalPages > 1) _pagination(widget.bloc, page, totalPages, tickets.length),
                    ],
                  ),
                )
              else if (state is AdminError)
                Expanded(child: Center(child: Text(state.message, style: const TextStyle(color: ThemeColors.unifiedDanger))))
              else
                const SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }

  Widget _searchField(AdminBloc bloc, String searchQuery) {
    final ctl = TextEditingController(text: searchQuery);
    return SizedBox(
      width: 220,
      child: TextField(
        controller: ctl,
        decoration: InputDecoration(
          hintText: ConstStrings.searchTickets,
          hintStyle: TextStyle(color: ThemeColors.unifiedTextMuted.withValues(alpha: 0.6), fontSize: 13),
          prefixIcon: Icon(Icons.search_rounded, size: 18, color: ThemeColors.unifiedTextMuted),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, size: 16, color: ThemeColors.unifiedTextMuted),
                  onPressed: () {
                    ctl.clear();
                    bloc.add(UpdateTicketSearchQuery(''));
                  },
                )
              : null,
          filled: true,
          fillColor: ThemeColors.unifiedBackground,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: ThemeColors.unifiedBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: ThemeColors.unifiedBorder.withValues(alpha: 0.5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: ThemeColors.unifiedPrimary, width: 1.5),
          ),
        ),
        onSubmitted: (v) => bloc.add(UpdateTicketSearchQuery(v)),
      ),
    );
  }

  Widget _statusDropdown(AdminBloc bloc, String? filterStatus) {
    return DropdownButton<String?>(
      value: filterStatus,
      hint: const Text(ConstStrings.allStatus),
      items: const [
        DropdownMenuItem(value: null, child: Text(ConstStrings.allStatus)),
        DropdownMenuItem(value: 'open', child: Text('Open')),
        DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
        DropdownMenuItem(value: 'completed', child: Text('Completed')),
        DropdownMenuItem(value: 'closed', child: Text('Closed')),
      ],
      onChanged: (v) => bloc.add(UpdateTicketStatusFilter(v)),
    );
  }

  Widget _buildTable(BuildContext context, List<AdminTicketModel> tickets) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.unifiedBorder),
      ),
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(ThemeColors.unifiedBackground),
          columns: const [
            DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
            DataColumn(label: Text('Ticket #', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
            DataColumn(label: Text('Title', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
            DataColumn(label: Text('Priority', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
            DataColumn(label: Text('Dept', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
            DataColumn(label: Text('Assigned To', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
            DataColumn(label: Text('Created By', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
            DataColumn(label: Text('Last Action', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
            DataColumn(label: Text('Due', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12))),
          ],
          rows: tickets.map((t) => DataRow(
            color: WidgetStateProperty.resolveWith((states) {
              if (t.isOverdue) return ThemeColors.unifiedDanger.withValues(alpha: 0.04);
              return null;
            }),
            cells: [
              DataCell(Text('${t.id}', style: const TextStyle(fontSize: 12))),
              DataCell(Text(t.ticketNumber ?? '-', style: const TextStyle(fontSize: 11))),
              DataCell(ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 180),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.title, overflow: TextOverflow.ellipsis, maxLines: 1, style: const TextStyle(fontSize: 12)),
                    if (t.isSubTicket)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: ThemeColors.unifiedSecondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: const Text('SUB', style: TextStyle(fontSize: 9, color: ThemeColors.unifiedSecondary, fontWeight: FontWeight.w700)),
                      ),
                  ],
                ),
              )),
              DataCell(_badge(t.status)),
              DataCell(_priorityBadge(t.priority)),
              DataCell(Text(t.assignedDeptName ?? '-', style: const TextStyle(fontSize: 11))),
              DataCell(Text(t.assignedToName ?? '-', style: const TextStyle(fontSize: 11))),
              DataCell(Text(t.createdByName ?? '-', style: const TextStyle(fontSize: 11))),
              DataCell(ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Text(
                  [
                    if (t.lastAction != null) t.lastAction!.replaceAll('_', ' ').toUpperCase(),
                    if (t.lastActedByDeptName != null) t.lastActedByDeptName!,
                  ].join(' · '),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: ThemeColors.unifiedTextMuted),
                ),
              )),
              DataCell(Text(
                t.dueDate != null ? DateFormat('dd/MM/yy').format(DateTime.parse(t.dueDate!)) : '-',
                style: TextStyle(
                  fontSize: 11,
                  color: t.isOverdue ? ThemeColors.unifiedDanger : null,
                  fontWeight: t.isOverdue ? FontWeight.w700 : null,
                ),
              )),
              DataCell(Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility_outlined, size: 17, color: ThemeColors.unifiedSecondary),
                    onPressed: () => _openDetail(context, t),
                    tooltip: ConstStrings.ticketDetail,
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 17, color: ThemeColors.unifiedPrimary),
                    onPressed: () => _openEdit(context, t),
                    tooltip: ConstStrings.editTicket,
                  ),
                  if (t.immediateChildCount > 0)
                    Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: ThemeColors.unifiedAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${t.immediateChildCount}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: ThemeColors.unifiedAccent)),
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 17, color: ThemeColors.unifiedDanger),
                    onPressed: () => _confirmDelete(context, t),
                    tooltip: ConstStrings.delete,
                  ),
                ],
              )),
            ],
          )).toList(),
        ),
      ),
    );
  }

  Widget _pagination(AdminBloc bloc, int page, int totalPages, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 20),
            onPressed: page > 1 ? () => bloc.add(UpdateTicketPage(page - 1)) : null,
          ),
          const SizedBox(width: 8),
          Text('Page $page of $totalPages ($count tickets)',
              style: AppTextStyles.bodySmallMuted),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 20),
            onPressed: page < totalPages ? () => bloc.add(UpdateTicketPage(page + 1)) : null,
          ),
        ],
      ),
    );
  }

  void _openEdit(BuildContext context, AdminTicketModel ticket) async {
    final bloc = context.read<AdminBloc>();
    final departments = await bloc.fetchDepartments();
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: AdminTicketEditDialog(
          ticket: ticket,
          departments: departments,
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, AdminTicketModel ticket) {
    context.read<AdminBloc>().add(LoadTicketDetail(ticket.id));
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<AdminBloc>(),
        child: _TicketDetailDialog(ticketId: ticket.id),
      ),
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
              dialogContext.read<AdminBloc>().add(DeleteTicket(t.id, dialogContext));
            },
            child: const Text(ConstStrings.delete),
          ),
        ],
      ),
    );
  }

  Widget _badge(String status) {
    Color bg, fg;
    switch (status) {
      case 'open':
        bg = ThemeColors.statusOpenBg;
        fg = ThemeColors.statusOpenFg;
      case 'in_progress':
        bg = ThemeColors.statusProgressBg;
        fg = ThemeColors.statusProgressFg;
      case 'completed':
        bg = ThemeColors.statusDoneBg;
        fg = ThemeColors.statusDoneFg;
      default:
        bg = ThemeColors.statusClosedBg;
        fg = ThemeColors.statusClosedFg;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(status.replaceAll('_', ' ').toUpperCase(),
          style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w600)),
    );
  }

  Widget _priorityBadge(String priority) {
    Color bg, fg;
    switch (priority) {
      case 'low':
        bg = ThemeColors.priorityLowBg;
        fg = ThemeColors.priorityLowFg;
      case 'medium':
        bg = ThemeColors.priorityMedBg;
        fg = ThemeColors.priorityMedFg;
      case 'high':
        bg = ThemeColors.priorityHighBg;
        fg = ThemeColors.priorityHighFg;
      default:
        bg = ThemeColors.priorityUrgentBg;
        fg = ThemeColors.priorityUrgentFg;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(priority.toUpperCase(),
          style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w600)),
    );
  }
}

class _TicketDetailDialog extends StatelessWidget {
  final int ticketId;
  const _TicketDetailDialog({required this.ticketId});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ThemeColors.unifiedSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 640,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(24),
        child: BlocBuilder<AdminBloc, AdminState>(
          buildWhen: (prev, curr) => curr is TicketDetailLoaded || curr is AdminLoading,
          builder: (context, state) {
            if (state is AdminLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is! TicketDetailLoaded) {
              return const SizedBox.shrink();
            }
            final t = state.ticket;
            final subTickets = state.subTickets;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.confirmation_number, color: ThemeColors.unifiedPrimary, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${t.ticketNumber ?? ''} — ${t.title}',
                        style: AppTextStyles.pageTitle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (_) => BlocProvider.value(
                            value: context.read<AdminBloc>(),
                            child: AdminTicketEditDialog(
                              ticket: t,
                              departments: state.departments,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _infoRow('Status', _badge(t.status)),
                _infoRow('Priority', _priorityBadge(t.priority)),
                _infoRow('Type', Text(t.ticketType ?? 'standard', style: const TextStyle(fontSize: 13))),
                _infoRow('Created By', Text('${t.createdByName ?? '-'} (${t.createdByEmail ?? '-'})', style: const TextStyle(fontSize: 13))),
                _infoRow('Assigned Dept', Text('${t.assignedDeptName ?? '-'} (${t.assignedDeptCode ?? '-'})', style: const TextStyle(fontSize: 13))),
                _infoRow('Assigned To', Text(t.assignedToName ?? ConstStrings.unassigned, style: const TextStyle(fontSize: 13))),
                if (t.dueDate != null)
                  _infoRow('Due Date', Text(
                    DateFormat('dd MMM yyyy').format(DateTime.parse(t.dueDate!)),
                    style: TextStyle(
                      fontSize: 13,
                      color: t.isOverdue ? ThemeColors.unifiedDanger : null,
                      fontWeight: t.isOverdue ? FontWeight.w700 : null,
                    ),
                  )),
                if (t.lastAction != null)
                  _infoRow('Last Action', Text(
                    '${t.lastAction!.replaceAll('_', ' ')} — ${t.lastActedByName ?? 'System'}${t.lastActedByDeptName != null ? ' (${t.lastActedByDeptName})' : ''}',
                    style: const TextStyle(fontSize: 13),
                  )),
                if (t.version != null)
                  _infoRow('Version', Text('${t.version}', style: const TextStyle(fontSize: 13))),
                if (t.description != null && t.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(ConstStrings.description, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ThemeColors.unifiedTextMuted)),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ThemeColors.unifiedInputBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(t.description!, style: const TextStyle(fontSize: 13)),
                  ),
                ],
                if (subTickets.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('${ConstStrings.subTicketCount} (${subTickets.length})',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ThemeColors.unifiedTextPrimary)),
                  const SizedBox(height: 8),
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: ThemeColors.unifiedBorder),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(ThemeColors.unifiedBackground),
                        columns: const [
                          DataColumn(label: Text('#', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11))),
                          DataColumn(label: Text('Dept', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11))),
                          DataColumn(label: Text('Progress', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11))),
                          DataColumn(label: Text('Assignee', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11))),
                        ],
                        rows: subTickets.map((s) => DataRow(cells: [
                          DataCell(Text('${s.id}', style: const TextStyle(fontSize: 11))),
                          DataCell(Text(s.departmentName ?? '-', style: const TextStyle(fontSize: 11))),
                          DataCell(_subBadge(s.status)),
                          DataCell(Text('${s.progressPercent}%', style: const TextStyle(fontSize: 11))),
                          DataCell(Text(s.assignedToName ?? '-', style: const TextStyle(fontSize: 11))),
                        ])).toList(),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(ConstStrings.close),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _infoRow(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ThemeColors.unifiedTextMuted)),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _badge(String status) {
    Color bg, fg;
    switch (status) {
      case 'open':
        bg = ThemeColors.statusOpenBg;
        fg = ThemeColors.statusOpenFg;
      case 'in_progress':
        bg = ThemeColors.statusProgressBg;
        fg = ThemeColors.statusProgressFg;
      case 'completed':
        bg = ThemeColors.statusDoneBg;
        fg = ThemeColors.statusDoneFg;
      default:
        bg = ThemeColors.statusClosedBg;
        fg = ThemeColors.statusClosedFg;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(status.replaceAll('_', ' ').toUpperCase(),
          style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w600)),
    );
  }

  Widget _priorityBadge(String priority) {
    Color bg, fg;
    switch (priority) {
      case 'low':
        bg = ThemeColors.priorityLowBg;
        fg = ThemeColors.priorityLowFg;
      case 'medium':
        bg = ThemeColors.priorityMedBg;
        fg = ThemeColors.priorityMedFg;
      case 'high':
        bg = ThemeColors.priorityHighBg;
        fg = ThemeColors.priorityHighFg;
      default:
        bg = ThemeColors.priorityUrgentBg;
        fg = ThemeColors.priorityUrgentFg;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(priority.toUpperCase(),
          style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w600)),
    );
  }

  Widget _subBadge(String status) {
    Color bg, fg;
    switch (status) {
      case 'open':
        bg = ThemeColors.statusOpenBg;
        fg = ThemeColors.statusOpenFg;
      case 'in_progress':
        bg = ThemeColors.statusProgressBg;
        fg = ThemeColors.statusProgressFg;
      case 'completed':
        bg = ThemeColors.statusDoneBg;
        fg = ThemeColors.statusDoneFg;
      case 'pending_approval':
        bg = ThemeColors.priorityMedBg;
        fg = ThemeColors.priorityMedFg;
      default:
        bg = ThemeColors.statusDoneBg;
        fg = ThemeColors.statusDoneFg;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(status.replaceAll('_', ' ').toUpperCase(),
          style: TextStyle(fontSize: 9, color: fg, fontWeight: FontWeight.w600)),
    );
  }
}
