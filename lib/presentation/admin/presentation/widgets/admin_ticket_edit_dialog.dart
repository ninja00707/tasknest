import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_text_styles.dart';
import 'package:tasknest/presentation/admin/data/models/admin_models.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_bloc.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_event.dart';

class AdminTicketEditDialog extends StatefulWidget {
  final AdminTicketModel ticket;
  final List<AdminDeptModel> departments;

  const AdminTicketEditDialog({
    super.key,
    required this.ticket,
    this.departments = const [],
  });

  @override
  State<AdminTicketEditDialog> createState() => _AdminTicketEditDialogState();
}

class _AdminTicketEditDialogState extends State<AdminTicketEditDialog> {
  late TextEditingController _titleCtl;
  late TextEditingController _descCtl;
  late String _status;
  late String _priority;
  int? _assignedDeptId;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _titleCtl = TextEditingController(text: widget.ticket.title);
    _descCtl = TextEditingController(text: widget.ticket.description ?? '');
    _status = widget.ticket.status;
    _priority = widget.ticket.priority;
    _assignedDeptId = widget.ticket.assignedDeptId;
    if (widget.ticket.dueDate != null) {
      _dueDate = DateTime.tryParse(widget.ticket.dueDate!);
    }
  }

  @override
  void dispose() {
    _titleCtl.dispose();
    _descCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: ThemeColors.unifiedSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.edit_note, color: ThemeColors.unifiedPrimary, size: 22),
                const SizedBox(width: 10),
                Text('${ConstStrings.editTicket} ${widget.ticket.ticketNumber ?? ''}',
                    style: AppTextStyles.pageTitle),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _field('Title', _titleCtl),
            const SizedBox(height: 12),
            _field('Description', _descCtl, maxLines: 3),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _statusDropdown()),
                const SizedBox(width: 12),
                Expanded(child: _priorityDropdown()),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _deptDropdown()),
                const SizedBox(width: 12),
                Expanded(child: _dueDateField(context)),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(ConstStrings.cancel),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColors.unifiedPrimary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _save,
                  child: const Text(ConstStrings.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctl, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ThemeColors.unifiedTextMuted)),
        const SizedBox(height: 4),
        TextField(
          controller: ctl,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: ThemeColors.unifiedInputBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: ThemeColors.unifiedBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: ThemeColors.unifiedBorder),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ThemeColors.unifiedTextMuted)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: _status,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: ThemeColors.unifiedInputBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: ThemeColors.unifiedBorder),
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'open', child: Text('Open')),
            DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
            DropdownMenuItem(value: 'completed', child: Text('Completed')),
            DropdownMenuItem(value: 'closed', child: Text('Closed')),
          ],
          onChanged: (v) => setState(() => _status = v ?? _status),
        ),
      ],
    );
  }

  Widget _priorityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Priority', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ThemeColors.unifiedTextMuted)),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: _priority,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: ThemeColors.unifiedInputBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: ThemeColors.unifiedBorder),
            ),
          ),
          items: const [
            DropdownMenuItem(value: 'low', child: Text('Low')),
            DropdownMenuItem(value: 'medium', child: Text('Medium')),
            DropdownMenuItem(value: 'high', child: Text('High')),
            DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
          ],
          onChanged: (v) => setState(() => _priority = v ?? _priority),
        ),
      ],
    );
  }

  Widget _deptDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Assigned Dept', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ThemeColors.unifiedTextMuted)),
        const SizedBox(height: 4),
        DropdownButtonFormField<int?>(
          initialValue: _assignedDeptId,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: ThemeColors.unifiedInputBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: ThemeColors.unifiedBorder),
            ),
          ),
          items: [
            const DropdownMenuItem<int?>(value: null, child: Text(ConstStrings.unassigned)),
            ...widget.departments.map((d) => DropdownMenuItem(
              value: d.id,
              child: Text('${d.name} (${d.code})'),
            )),
          ],
          onChanged: (v) => setState(() => _assignedDeptId = v),
        ),
      ],
    );
  }

  Widget _dueDateField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(ConstStrings.dueDateLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ThemeColors.unifiedTextMuted)),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _dueDate ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (picked != null) setState(() => _dueDate = picked);
          },
          child: InputDecorator(
            decoration: InputDecoration(
              filled: true,
              fillColor: ThemeColors.unifiedInputBg,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: ThemeColors.unifiedBorder),
              ),
              suffixIcon: _dueDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () => setState(() => _dueDate = null),
                    )
                  : const Icon(Icons.calendar_today, size: 16),
            ),
            child: Text(
              _dueDate != null
                  ? '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'
                  : ConstStrings.selectDueDate,
              style: TextStyle(
                color: _dueDate != null ? ThemeColors.unifiedTextPrimary : ThemeColors.unifiedTextMuted,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _save() {
    if (_titleCtl.text.trim().isEmpty) return;
    final body = <String, dynamic>{
      'title': _titleCtl.text.trim(),
      'description': _descCtl.text.trim(),
      'status': _status,
      'priority': _priority,
      'assigned_dept_id': _assignedDeptId,
      'due_date': _dueDate?.toIso8601String().split('T').first,
    };
    context.read<AdminBloc>().add(UpdateTicketAdmin(widget.ticket.id, body, context));
    Navigator.pop(context);
  }
}
