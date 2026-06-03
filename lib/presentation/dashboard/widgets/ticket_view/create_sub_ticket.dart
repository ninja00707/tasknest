import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/model/ticketmodel.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

class CreateSubTicketView extends StatefulWidget {
  final UserModel user;
  final int? parentTicketId;
  final String? parentTicketTitle;

  const CreateSubTicketView({
    super.key,
    required this.user,
    this.parentTicketId,
    this.parentTicketTitle,
  });

  @override
  State<CreateSubTicketView> createState() => _CreateSubTicketViewState();
}

class _DeptTaskEntry {
  final DepartmentModel department;
  final TextEditingController taskController;

  _DeptTaskEntry({required this.department, required this.taskController});
}

class _CreateSubTicketViewState extends State<CreateSubTicketView> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final List<_DeptTaskEntry> _selectedDepts = [];
  String _priority = 'medium';
  String? _dueDate;
  bool _submitting = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    for (final e in _selectedDepts) {
      e.taskController.dispose();
    }
    super.dispose();
  }

  void _toggleDepartment(DepartmentModel dept) {
    setState(() {
      final idx = _selectedDepts.indexWhere((e) => e.department.id == dept.id);
      if (idx >= 0) {
        _selectedDepts[idx].taskController.dispose();
        _selectedDepts.removeAt(idx);
      } else {
        _selectedDepts.add(
          _DeptTaskEntry(
            department: dept,
            taskController: TextEditingController(),
          ),
        );
      }
    });
  }

  bool _isSelected(int deptId) =>
      _selectedDepts.any((e) => e.department.id == deptId);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: ThemeColors.unifiedPrimary,
            onPrimary: Colors.white,
            surface: ThemeColors.unifiedSurface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _dueDate = picked.toIso8601String().split('T').first);
    }
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedDepts.length < 2) {
      _showSnack(
        'Select at least 2 departments for a multi-task ticket',
        isError: true,
      );
      return;
    }

    for (final entry in _selectedDepts) {
      if (entry.taskController.text.trim().isEmpty) {
        _showSnack(
          'Add a task description for ${entry.department.name}',
          isError: true,
        );
        return;
      }
    }

    setState(() => _submitting = true);

    context.read<DashboardBloc>().add(
      CreateSubTicketEvent(
        title: _title.text.trim(),
        description: _description.text.trim(),
        priority: _priority,
        dueDate: _dueDate,
        parentTicketId: widget.parentTicketId,
        departments: _selectedDepts
            .map(
              (e) => {
                'departmentId': e.department.id,
                'taskDescription': e.taskController.text.trim(),
              },
            )
            .toList(),
      ),
    );

    setState(() => _submitting = false);
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError
            ? ThemeColors.unifiedDanger
            : ThemeColors.unifiedPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 700;
    final blocState = context.watch<DashboardBloc>().state;
    final departments = blocState is DashboardLoaded
        ? blocState.departments
        : <DepartmentModel>[];

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWide ? 28 : 16).copyWith(bottom: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.parentTicketId != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: ThemeColors.unifiedBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ThemeColors.unifiedBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.subdirectory_arrow_right_rounded,
                    size: 16,
                    color: ThemeColors.unifiedTextMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Creating sub-ticket for #${widget.parentTicketId} ${widget.parentTicketTitle ?? ""}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ThemeColors.unifiedTextMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.hub_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Create Multi Task Ticket',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: ThemeColors.unifiedTextPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Multi-department collaborative ticket (Manager only)',
                      style: TextStyle(
                        fontSize: 13,
                        color: ThemeColors.unifiedTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF7C3AED).withOpacity(0.3),
                  ),
                ),
                child: const Text(
                  'MULTI TASK',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7C3AED),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: ThemeColors.unifiedSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ThemeColors.unifiedBorder, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge,
            child: Column(
              children: [
                Container(
                  height: 4,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Title', Icons.title_rounded, required: true),
                        const SizedBox(height: 8),
                        _textField(
                          controller: _title,
                          hint: 'Sub-ticket title',
                          validator: (v) => v == null || v.isEmpty
                              ? 'Title is required'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        _label(
                          'Overall Description',
                          Icons.notes_rounded,
                          required: true,
                        ),
                        const SizedBox(height: 8),
                        _textField(
                          controller: _description,
                          hint:
                              'Describe the overall objective across departments...',
                          maxLines: 3,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Description is required'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        _label('Priority', Icons.flag_outlined),
                        const SizedBox(height: 8),
                        _PriorityRow(
                          selected: _priority,
                          onChanged: (v) => setState(() => _priority = v),
                        ),
                        const SizedBox(height: 20),
                        _label('Due Date', Icons.calendar_today_outlined),
                        const SizedBox(height: 8),
                        _DateField(dueDate: _dueDate, onTap: _pickDate),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            _label(
                              'Select Departments',
                              Icons.business_outlined,
                              required: true,
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: ThemeColors.unifiedBackground,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: ThemeColors.unifiedBorder,
                                ),
                              ),
                              child: Text(
                                '${_selectedDepts.length} selected',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: ThemeColors.unifiedTextMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Pick 2 or more departments. A task box appears for each.',
                          style: TextStyle(
                            fontSize: 12,
                            color: ThemeColors.unifiedTextMuted,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: departments.map((dept) {
                            final selected = _isSelected(dept.id);
                            return FilterChip(
                              label: Text('${dept.name} (${dept.code})'),
                              selected: selected,
                              onSelected: (_) => _toggleDepartment(dept),
                              selectedColor: const Color(
                                0xFF7C3AED,
                              ).withOpacity(0.15),
                              checkmarkColor: const Color(0xFF7C3AED),
                              side: BorderSide(
                                color: selected
                                    ? const Color(0xFF7C3AED)
                                    : ThemeColors.unifiedBorder,
                              ),
                              labelStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: selected
                                    ? const Color(0xFF7C3AED)
                                    : ThemeColors.unifiedTextPrimary,
                              ),
                            );
                          }).toList(),
                        ),
                        if (_selectedDepts.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          _label(
                            'Department Tasks',
                            Icons.assignment_outlined,
                            required: true,
                          ),
                          const SizedBox(height: 12),
                          ..._selectedDepts.map(_buildDeptTaskCard),
                        ],
                        const SizedBox(height: 28),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: _submitting ? null : _submit,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                gradient: _submitting
                                    ? null
                                    : const LinearGradient(
                                        colors: [
                                          Color(0xFF7C3AED),
                                          Color(0xFF4F46E5),
                                        ],
                                      ),
                                color: _submitting
                                    ? ThemeColors.unifiedBorder
                                    : null,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: _submitting
                                    ? null
                                    : [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF7C3AED,
                                          ).withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_submitting)
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: ThemeColors.unifiedTextMuted,
                                      ),
                                    )
                                  else
                                    const Icon(
                                      Icons.hub_outlined,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _submitting
                                        ? 'Creating...'
                                        : 'Create Sub-Ticket',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _submitting
                                          ? ThemeColors.unifiedTextMuted
                                          : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeptTaskCard(_DeptTaskEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF7C3AED).withOpacity(0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  entry.department.code,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7C3AED),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                entry.department.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.unifiedTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _textField(
            controller: entry.taskController,
            hint: 'Task instructions for ${entry.department.name}...',
            maxLines: 3,
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Task description required'
                : null,
          ),
        ],
      ),
    );
  }

  Widget _label(String label, IconData icon, {bool required = false}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: ThemeColors.unifiedTextMuted),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: ThemeColors.unifiedTextPrimary,
          ),
        ),
        if (required) ...[
          const SizedBox(width: 3),
          const Text('*', style: TextStyle(color: ThemeColors.unifiedDanger)),
        ],
      ],
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(
        fontSize: 14,
        color: ThemeColors.unifiedTextPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: ThemeColors.unifiedTextMuted,
          fontSize: 14,
        ),
        filled: true,
        fillColor: ThemeColors.unifiedInputBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: ThemeColors.unifiedBorder,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: ThemeColors.unifiedBorder,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
        ),
      ),
    );
  }
}

class _PriorityRow extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _PriorityRow({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const items = ['low', 'medium', 'high', 'urgent'];
    return Row(
      children: items.map((p) {
        final isSel = p == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(p),
            child: Container(
              margin: EdgeInsets.only(right: p != 'urgent' ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSel
                    ? ThemeColors.unifiedPrimary.withOpacity(0.12)
                    : ThemeColors.unifiedInputBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSel
                      ? ThemeColors.unifiedPrimary
                      : ThemeColors.unifiedBorder,
                  width: isSel ? 2 : 1.5,
                ),
              ),
              child: Text(
                p[0].toUpperCase() + p.substring(1),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                  color: isSel
                      ? ThemeColors.unifiedPrimary
                      : ThemeColors.unifiedTextMuted,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DateField extends StatelessWidget {
  final String? dueDate;
  final VoidCallback onTap;

  const _DateField({this.dueDate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: ThemeColors.unifiedInputBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ThemeColors.unifiedBorder, width: 1.5),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: ThemeColors.unifiedTextMuted,
            ),
            const SizedBox(width: 10),
            Text(
              dueDate ?? 'Pick a due date (optional)',
              style: TextStyle(
                fontSize: 14,
                color: dueDate != null
                    ? ThemeColors.unifiedTextPrimary
                    : ThemeColors.unifiedTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
