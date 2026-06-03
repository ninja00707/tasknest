import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_dep.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/model/ticketmodel.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

class CreateTicketUnified extends StatefulWidget {
  final UserModel user;
  const CreateTicketUnified({super.key, required this.user});

  @override
  State<CreateTicketUnified> createState() => _CreateTicketUnifiedState();
}

class _DeptTaskEntry {
  final DepartmentModel department;
  final TextEditingController taskController;

  _DeptTaskEntry({required this.department, required this.taskController});
}

class _CreateTicketUnifiedState extends State<CreateTicketUnified> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final List<_DeptTaskEntry> _selectedDepts = [];

  bool _isSubTicket = false;
  Priorities _priority = Priorities(name: 'medium', id: 0);
  Departments? _selectedDepartment;
  EmployeeModel? _selectedEmployee;
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

  void _onDeptChanged(Departments value) {
    setState(() {
      _selectedDepartment = value;
      _selectedEmployee = null;
    });
    context.read<DashboardBloc>().add(LoadEmployeesForDept(value.id));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 3)),
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

    if (_isSubTicket) {
      if (_selectedDepts.length < 2) {
        _showSnack('Select at least 2 departments for a sub-ticket', isError: true);
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
    } else {
      if (_selectedDepartment == null) {
        _showSnack('Please select a department', isError: true);
        return;
      }
    }

    setState(() => _submitting = true);

    if (_isSubTicket) {
      context.read<DashboardBloc>().add(
        CreateSubTicketEvent(
          title: _title.text.trim(),
          description: _description.text.trim(),
          priority: _priority.name,
          dueDate: _dueDate,
          departments: _selectedDepts
              .map((e) => {
                'departmentId': e.department.id,
                'taskDescription': e.taskController.text.trim(),
              })
              .toList(),
        ),
      );
    } else {
      context.read<DashboardBloc>().add(
        CreateTicketEvent(
          title: _title.text.trim(),
          description: _description.text.trim(),
          priority: _priority.name,
          assignedDeptId: _selectedDepartment?.id ?? widget.user.departmentId,
          assignedToId: _selectedEmployee?.id,
          createdById: widget.user.id,
          createdByDept: widget.user.departmentId,
          dueDate: _dueDate,
        ),
      );
    }

    setState(() => _submitting = false);
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            isError ? ThemeColors.unifiedDanger : ThemeColors.unifiedPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 700;
    final blocState = context.watch<DashboardBloc>().state;
    final employeeList = blocState is DashboardLoaded
        ? blocState.employees
        : <EmployeeModel>[];
    final departments = blocState is DashboardLoaded
        ? blocState.departments
        : <DepartmentModel>[];
    final canAssignEmployee =
        widget.user.roleId == 0 || widget.user.roleId == 1;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWide ? 28 : 16).copyWith(bottom: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PageHeader(
            isSubTicket: _isSubTicket,
            onToggle: (val) {
              setState(() {
                _isSubTicket = val;
                if (!_isSubTicket) {
                  _selectedDepts.clear();
                }
              });
            },
            canToggle: canAssignEmployee,
          ),
          const SizedBox(height: 24),
          _FormCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel(
                    label: 'Title',
                    icon: Icons.title_rounded,
                    required: true,
                  ),
                  const SizedBox(height: 8),
                  _StyledTextField(
                    controller: _title,
                    hint: 'Enter a clear, descriptive title',
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 20),
                  _FieldLabel(
                    label: 'Description',
                    icon: Icons.notes_rounded,
                    required: true,
                  ),
                  const SizedBox(height: 8),
                  _StyledTextField(
                    controller: _description,
                    hint: _isSubTicket
                        ? 'Describe the overall objective across departments...'
                        : 'Describe the task in full detail...',
                    maxLines: 4,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Description is required' : null,
                  ),
                  const SizedBox(height: 20),
                  if (!_isSubTicket)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(
                                label: 'Assign to Department',
                                icon: Icons.business_outlined,
                                required: true,
                              ),
                              const SizedBox(height: 8),
                              _StyledDropdown<Departments>(
                                hint: 'Select Department',
                                value: _selectedDepartment,
                                items: departments,
                                labelBuilder: (e) => e.name,
                                onChanged: _onDeptChanged,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(
                                label: 'Priority',
                                icon: Icons.flag_outlined,
                                required: true,
                              ),
                              const SizedBox(height: 8),
                              _PrioritySelector(
                                selected: _priority,
                                onChanged: (v) =>
                                    setState(() => _priority = v),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _FieldLabel(
                      label: 'Priority',
                      icon: Icons.flag_outlined,
                      required: true,
                    ),
                    const SizedBox(height: 8),
                    _PrioritySelector(
                      selected: _priority,
                      onChanged: (v) => setState(() => _priority = v),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (!_isSubTicket) const SizedBox(height: 20),
                  if (!_isSubTicket && canAssignEmployee) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(
                                label: 'Assign to Employee',
                                icon: Icons.person_outline_rounded,
                              ),
                              const SizedBox(height: 8),
                              _StyledDropdown<EmployeeModel>(
                                hint: _selectedDepartment == null
                                    ? 'Select dept first'
                                    : employeeList.isEmpty
                                    ? 'No employees found'
                                    : 'Select Employee',
                                value: _selectedEmployee,
                                items: employeeList,
                                labelBuilder: (e) => e.name,
                                onChanged: employeeList.isEmpty
                                    ? (_) {}
                                    : (v) =>
                                        setState(() => _selectedEmployee = v),
                                enabled: employeeList.isNotEmpty,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(
                                label: 'Due Date',
                                icon: Icons.calendar_today_outlined,
                              ),
                              const SizedBox(height: 8),
                              _DatePicker(dueDate: _dueDate, onTap: _pickDate),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ] else if (_isSubTicket) ...[
                    _FieldLabel(
                      label: 'Due Date',
                      icon: Icons.calendar_today_outlined,
                    ),
                    const SizedBox(height: 8),
                    _DatePicker(dueDate: _dueDate, onTap: _pickDate),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _FieldLabel(
                          label: 'Select Departments',
                          icon: Icons.business_outlined,
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
                            border: Border.all(color: ThemeColors.unifiedBorder),
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
                          selectedColor:
                              ThemeColors.unifiedPrimary.withOpacity(0.15),
                          checkmarkColor: ThemeColors.unifiedPrimary,
                          side: BorderSide(
                            color: selected
                                ? ThemeColors.unifiedPrimary
                                : ThemeColors.unifiedBorder,
                          ),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                            color: selected
                                ? ThemeColors.unifiedPrimary
                                : ThemeColors.unifiedTextPrimary,
                          ),
                        );
                      }).toList(),
                    ),
                    if (_selectedDepts.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _FieldLabel(
                        label: 'Department Tasks',
                        icon: Icons.assignment_outlined,
                        required: true,
                      ),
                      const SizedBox(height: 12),
                      ..._selectedDepts.map(_buildDeptTaskCard),
                    ],
                  ],
                  const SizedBox(height: 28),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _SubmitButton(
                      submitting: _submitting,
                      onTap: _submit,
                    ),
                  ),
                ],
              ),
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
          color: ThemeColors.unifiedPrimary.withOpacity(0.25),
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
                  color: ThemeColors.unifiedPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  entry.department.code,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: ThemeColors.unifiedPrimary,
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
          _StyledTextField(
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
}

class _PageHeader extends StatelessWidget {
  final bool isSubTicket;
  final ValueChanged<bool> onToggle;
  final bool canToggle;

  const _PageHeader({
    required this.isSubTicket,
    required this.onToggle,
    required this.canToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                ThemeColors.unifiedGradStart,
                ThemeColors.unifiedGradEnd,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isSubTicket ? Icons.hub_outlined : Icons.add_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isSubTicket ? 'Create Sub-Ticket' : 'Create Ticket',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: ThemeColors.unifiedTextPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isSubTicket
                    ? 'Multi-department collaborative ticket'
                    : 'Fill in the details and assign to a department.',
                style: const TextStyle(
                  fontSize: 13,
                  color: ThemeColors.unifiedTextMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        if (canToggle) ...[
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ThemeColors.unifiedBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ThemeColors.unifiedBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Sub-Ticket',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.unifiedTextMuted,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => onToggle(!isSubTicket),
                  child: Container(
                    width: 36,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isSubTicket
                          ? ThemeColors.unifiedPrimary
                          : ThemeColors.unifiedBorder,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: AnimatedAlign(
                      alignment: isSubTicket
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  final Widget child;
  const _FormCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                colors: [
                  ThemeColors.unifiedGradStart,
                  ThemeColors.unifiedGradEnd,
                ],
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.all(24), child: child),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool required;

  const _FieldLabel({
    required this.label,
    required this.icon,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
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
          const Text(
            '*',
            style: TextStyle(
              fontSize: 13,
              color: ThemeColors.unifiedDanger,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final String? Function(String?)? validator;

  const _StyledTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(
        fontSize: 14,
        color: ThemeColors.unifiedTextPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: ThemeColors.unifiedTextMuted,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: ThemeColors.unifiedInputBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
          borderSide: const BorderSide(
            color: ThemeColors.unifiedPrimary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: ThemeColors.unifiedDanger,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: ThemeColors.unifiedDanger,
            width: 2,
          ),
        ),
      ),
    );
  }
}

class _StyledDropdown<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;
  final bool enabled;

  const _StyledDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: enabled
            ? ThemeColors.unifiedInputBg
            : ThemeColors.unifiedBorder.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ThemeColors.unifiedBorder, width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(
              color: ThemeColors.unifiedTextMuted,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: ThemeColors.unifiedTextMuted,
            size: 20,
          ),
          style: const TextStyle(
            color: ThemeColors.unifiedTextPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          dropdownColor: ThemeColors.unifiedSurface,
          borderRadius: BorderRadius.circular(10),
          items: enabled
              ? items
                    .map(
                      (e) => DropdownMenuItem<T>(
                        value: e,
                        child: Text(labelBuilder(e)),
                      ),
                    )
                    .toList()
              : [],
          onChanged: enabled ? (v) => v != null ? onChanged(v) : null : null,
        ),
      ),
    );
  }
}

class _PrioritySelector extends StatelessWidget {
  final Priorities selected;
  final ValueChanged<Priorities> onChanged;

  const _PrioritySelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: priorities.map((p) {
        final isSel = p.id == selected.id;
        final color = _priorityColor(p.name);

        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(p),
            child: Container(
              margin: EdgeInsets.only(
                right: p.id < priorities.length - 1 ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSel
                    ? color.withOpacity(0.12)
                    : ThemeColors.unifiedInputBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSel ? color : ThemeColors.unifiedBorder,
                  width: isSel ? 2 : 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p.name[0].toUpperCase() + p.name.substring(1),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      color: isSel ? color : ThemeColors.unifiedTextMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DatePicker extends StatelessWidget {
  final String? dueDate;
  final VoidCallback onTap;

  const _DatePicker({this.dueDate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasDate = dueDate != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: ThemeColors.unifiedInputBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasDate
                ? ThemeColors.unifiedPrimary
                : ThemeColors.unifiedBorder,
            width: hasDate ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: hasDate
                  ? ThemeColors.unifiedPrimary
                  : ThemeColors.unifiedTextMuted,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                dueDate ?? 'Pick a due date',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: hasDate ? FontWeight.w600 : FontWeight.w400,
                  color: hasDate
                      ? ThemeColors.unifiedTextPrimary
                      : ThemeColors.unifiedTextMuted,
                ),
              ),
            ),
            if (hasDate)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: ThemeColors.unifiedPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  'SET',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: ThemeColors.unifiedPrimary,
                    letterSpacing: 0.3,
                  ),
                ),
              )
            else
              const Icon(
                Icons.arrow_drop_down_rounded,
                size: 20,
                color: ThemeColors.unifiedTextMuted,
              ),
          ],
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool submitting;
  final VoidCallback onTap;

  const _SubmitButton({
    required this.submitting,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: submitting ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
          gradient: submitting
              ? null
              : const LinearGradient(
                  colors: [
                    ThemeColors.unifiedGradStart,
                    ThemeColors.unifiedGradEnd,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          color: submitting ? ThemeColors.unifiedBorder : null,
          borderRadius: BorderRadius.circular(12),
          boxShadow: submitting
              ? null
              : [
                  BoxShadow(
                    color: ThemeColors.unifiedPrimary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (submitting)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: ThemeColors.unifiedTextMuted,
                ),
              )
            else
              const Icon(Icons.send_rounded, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              submitting ? 'Submitting...' : 'Submit Ticket',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: submitting ? ThemeColors.unifiedTextMuted : Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _priorityColor(String p) {
  switch (p.toLowerCase()) {
    case 'urgent':
      return ThemeColors.unifiedDanger;
    case 'high':
      return const Color(0xFFEA580C);
    case 'medium':
      return ThemeColors.unifiedWarning;
    default:
      return ThemeColors.unifiedPrimary;
  }
}
