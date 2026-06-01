import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_dep.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/model/ticketmodel.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

class CreateTicketView extends StatefulWidget {
  final UserModel user;
  const CreateTicketView({super.key, required this.user});

  @override
  State<CreateTicketView> createState() => _CreateTicketViewState();
}

class _CreateTicketViewState extends State<CreateTicketView> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();

  Priorities _priority = Priorities(name: 'medium', id: 0);
  List<DepartmentModel> _selectedDepartments = []; // Use dynamic models
  EmployeeModel? _selectedEmployee;
  String? _dueDate;
  bool _submitting = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 700;
    final blocState = context.watch<DashboardBloc>().state;
    final employeeList = blocState is DashboardLoaded
        ? blocState.employees
        : <EmployeeModel>[];
    final departmentList = blocState is DashboardLoaded
        ? blocState.departments
        : <DepartmentModel>[];

    // Employee can only be assigned if exactly one department is selected
    final canAssignEmployee =
        (widget.user.roleId == 0 || widget.user.roleId == 1) &&
        _selectedDepartments.length == 1;

    return SizedBox(
      height: MediaQuery.sizeOf(context).height,
      width: MediaQuery.sizeOf(context).width,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isWide ? 28 : 16).copyWith(bottom: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // ── Page header ───────────────────────────────────────────
            _PageHeader(),
            const SizedBox(height: 24),

            // ── Form card ─────────────────────────────────────────────
            _FormCard(
              child: Form(
                key: _formKey,
                child: isWide
                    ? _WideFormLayout(
                        titleCtrl: _title,
                        descCtrl: _description,
                        priority: _priority,
                        selectedDepartments: _selectedDepartments,
                        allDepartments: departmentList,
                        selectedEmployee: _selectedEmployee,
                        dueDate: _dueDate,
                        employeeList: employeeList,
                        canAssignEmployee: canAssignEmployee,
                        submitting: _submitting,
                        onPriorityChanged: (v) => setState(() => _priority = v),
                        onDeptChanged: _onDeptChanged,
                        onEmployeeChanged:
                            (v) => // Only if single dept selected
                                setState(() => _selectedEmployee = v),
                        onDateTap: _pickDate,
                        onSubmit: _submit,
                      )
                    : _NarrowFormLayout(
                        titleCtrl: _title,
                        descCtrl: _description,
                        priority: _priority,
                        selectedDepartments: _selectedDepartments,
                        allDepartments: departmentList,
                        selectedEmployee: _selectedEmployee,
                        dueDate: _dueDate,
                        employeeList: employeeList,
                        canAssignEmployee: canAssignEmployee,
                        submitting: _submitting,
                        onPriorityChanged: (v) => setState(() => _priority = v),
                        onDeptChanged: _onDeptChanged,
                        onEmployeeChanged:
                            (v) => // Only if single dept selected
                                setState(() => _selectedEmployee = v),
                        onDateTap: _pickDate,
                        onSubmit: _submit,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onDeptChanged(List<DepartmentModel> values) {
    setState(() {
      _selectedDepartments = values;
      _selectedEmployee = null;
    });
    if (values.length == 1) {
      context.read<DashboardBloc>().add(LoadEmployeesForDept(values.first.id));
    }
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
    if (_selectedDepartments.isEmpty) {
      _showSnack('Please select at least one department', isError: true);
      return;
    }

    setState(() => _submitting = true);

    context.read<DashboardBloc>().add(
      CreateTicketEvent(
        title: _title.text.trim(),
        description: _description.text.trim(),
        priority: _priority.name,
        assignedDeptId: _selectedDepartments.length == 1
            ? _selectedDepartments.first.id
            : null, // For single dept
        assignedDeptIds: _selectedDepartments.length > 1
            ? _selectedDepartments.map((d) => d.id).toList()
            : null, // For multi-dept
        assignedToId: _selectedDepartments.length == 1
            ? _selectedEmployee?.id
            : null, // Only assign to employee if single dept
        createdById: widget.user.id,
        createdByDept: widget.user.departmentId,
        dueDate: _dueDate,
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
}

// ── Page header ───────────────────────────────────────────────────────────────
class _PageHeader extends StatelessWidget {
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
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Create New Ticket',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: ThemeColors.unifiedTextPrimary,
                letterSpacing: -0.4,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Fill in the details and assign to a department.',
              style: TextStyle(
                fontSize: 13,
                color: ThemeColors.unifiedTextMuted,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Form card wrapper ─────────────────────────────────────────────────────────
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
          // Gradient top bar
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

// ── Wide layout (2-col) ───────────────────────────────────────────────────────
class _WideFormLayout extends StatelessWidget {
  final TextEditingController titleCtrl, descCtrl;
  final Priorities priority;
  final List<DepartmentModel> selectedDepartments;
  final List<DepartmentModel> allDepartments;
  final EmployeeModel? selectedEmployee;
  final String? dueDate;
  final List<EmployeeModel> employeeList;
  final bool canAssignEmployee, submitting;
  final ValueChanged<Priorities> onPriorityChanged;
  final ValueChanged<List<DepartmentModel>> onDeptChanged;
  final ValueChanged<EmployeeModel> onEmployeeChanged;
  final VoidCallback onDateTap, onSubmit;

  const _WideFormLayout({
    required this.titleCtrl,
    required this.descCtrl,
    required this.priority,
    required this.selectedDepartments,
    required this.allDepartments,
    required this.selectedEmployee,
    required this.dueDate,
    required this.employeeList,
    required this.canAssignEmployee,
    required this.submitting,
    required this.onPriorityChanged,
    required this.onDeptChanged,
    required this.onEmployeeChanged,
    required this.onDateTap,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Title (full width)
        _FieldLabel(label: 'Title', icon: Icons.title_rounded, required: true),
        const SizedBox(height: 8),
        _StyledTextField(
          controller: titleCtrl,
          hint: 'Enter a clear, descriptive title',
          validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
        ),
        const SizedBox(height: 20),

        // Description (full width)
        _FieldLabel(
          label: 'Description',
          icon: Icons.notes_rounded,
          required: true,
        ),
        const SizedBox(height: 8),
        _StyledTextField(
          controller: descCtrl,
          hint: 'Describe the task in full detail...',
          maxLines: 4,
          validator: (v) =>
              v == null || v.isEmpty ? 'Description is required' : null,
        ),
        const SizedBox(height: 20),

        // Dept + Priority side by side
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
                  _MultiSelectDepartmentField(
                    hint: 'Select Department(s)',
                    selectedDepartments: selectedDepartments,
                    allDepartments: allDepartments,
                    labelBuilder: (e) => e.name,
                    onChanged: onDeptChanged,
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
                    selected: priority,
                    onChanged: onPriorityChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Employee + Due date side by side
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (canAssignEmployee)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(
                      label: 'Assign to Employee (Single Dept)',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 8),
                    _StyledDropdown<EmployeeModel>(
                      hint: selectedDepartments.isEmpty
                          ? 'Select dept first'
                          : employeeList.isEmpty
                          ? 'No employees in selected dept'
                          : 'Select Employee',
                      value: selectedEmployee,
                      items: employeeList,
                      labelBuilder: (e) => e.name,
                      onChanged: employeeList.isEmpty
                          ? (_) {}
                          : onEmployeeChanged,
                      enabled: employeeList.isNotEmpty,
                    ),
                  ],
                ),
              ),
            if (canAssignEmployee) const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel(
                    label: 'Due Date',
                    icon: Icons.calendar_today_outlined,
                  ),
                  const SizedBox(height: 8),
                  _DatePicker(dueDate: dueDate, onTap: onDateTap),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        Align(
          alignment: Alignment.centerRight,
          child: _SubmitButton(
            submitting: submitting,
            onTap: onSubmit,
            wide: true,
          ),
        ),
      ],
    );
  }
}

// ── Narrow layout (single col) ────────────────────────────────────────────────
class _NarrowFormLayout extends StatelessWidget {
  final TextEditingController titleCtrl, descCtrl;
  final Priorities priority;
  final List<DepartmentModel> selectedDepartments;
  final List<DepartmentModel> allDepartments;
  final EmployeeModel? selectedEmployee;
  final String? dueDate;
  final List<EmployeeModel> employeeList;
  final bool canAssignEmployee, submitting;
  final ValueChanged<Priorities> onPriorityChanged;
  final ValueChanged<List<DepartmentModel>> onDeptChanged;
  final ValueChanged<EmployeeModel> onEmployeeChanged;
  final VoidCallback onDateTap, onSubmit;

  const _NarrowFormLayout({
    required this.titleCtrl,
    required this.descCtrl,
    required this.priority,
    required this.selectedDepartments,
    required this.allDepartments,
    required this.selectedEmployee,
    required this.dueDate,
    required this.employeeList,
    required this.canAssignEmployee,
    required this.submitting,
    required this.onPriorityChanged,
    required this.onDeptChanged,
    required this.onEmployeeChanged,
    required this.onDateTap,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: 'Title', icon: Icons.title_rounded, required: true),
        const SizedBox(height: 8),
        _StyledTextField(
          controller: titleCtrl,
          hint: 'Enter a clear, descriptive title',
          validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
        ),
        const SizedBox(height: 20),

        _FieldLabel(
          label: 'Description',
          icon: Icons.notes_rounded,
          required: true,
        ),
        const SizedBox(height: 8),
        _StyledTextField(
          controller: descCtrl,
          hint: 'Describe the task in full detail...',
          maxLines: 4,
          validator: (v) =>
              v == null || v.isEmpty ? 'Description is required' : null,
        ),
        const SizedBox(height: 20),

        _FieldLabel(
          label: 'Assign to Department',
          icon: Icons.business_outlined,
          required: true,
        ),
        const SizedBox(height: 8),
        _MultiSelectDepartmentField(
          hint: 'Select Department(s)',
          selectedDepartments: selectedDepartments,
          allDepartments: allDepartments,
          labelBuilder: (e) => e.name,
          onChanged: onDeptChanged,
        ),
        const SizedBox(height: 20),

        _FieldLabel(
          label: 'Priority',
          icon: Icons.flag_outlined,
          required: true,
        ),
        const SizedBox(height: 8),
        _PrioritySelector(selected: priority, onChanged: onPriorityChanged),
        const SizedBox(height: 20),

        if (canAssignEmployee) ...[
          _FieldLabel(
            label: 'Assign to Employee',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 8),
          _StyledDropdown<EmployeeModel>(
            hint: selectedDepartments.isEmpty
                ? 'Select dept first'
                : employeeList.isEmpty
                ? 'No employees in selected dept'
                : 'Select Employee',
            value: selectedEmployee,
            items: employeeList,
            labelBuilder: (e) => e.name,
            onChanged: employeeList.isEmpty ? (_) {} : onEmployeeChanged,
            enabled: employeeList.isNotEmpty,
          ),
          const SizedBox(height: 20),
        ],

        _FieldLabel(label: 'Due Date', icon: Icons.calendar_today_outlined),
        const SizedBox(height: 8),
        _DatePicker(dueDate: dueDate, onTap: onDateTap),
        const SizedBox(height: 28),

        _SubmitButton(submitting: submitting, onTap: onSubmit, wide: false),
      ],
    );
  }
}

// ── Field label ───────────────────────────────────────────────────────────────
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

// ── Styled text field ─────────────────────────────────────────────────────────
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

// ── Styled dropdown ───────────────────────────────────────────────────────────
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

// ── Multi-select department field ─────────────────────────────────────────────
class _MultiSelectDepartmentField extends StatelessWidget {
  final String hint;
  final List<DepartmentModel> selectedDepartments;
  final List<DepartmentModel> allDepartments;
  final String Function(DepartmentModel) labelBuilder;
  final ValueChanged<List<DepartmentModel>> onChanged;

  const _MultiSelectDepartmentField({
    required this.hint,
    required this.selectedDepartments,
    required this.allDepartments,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = selectedDepartments.isEmpty
        ? hint
        : selectedDepartments.map((d) => labelBuilder(d)).join(', ');

    return GestureDetector(
      onTap: () => _showMultiSelectDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: ThemeColors.unifiedInputBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: ThemeColors.unifiedBorder, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                displayValue,
                style: TextStyle(
                  fontSize: 14,
                  color: selectedDepartments.isEmpty
                      ? ThemeColors.unifiedTextMuted
                      : ThemeColors.unifiedTextPrimary,
                  fontWeight: selectedDepartments.isEmpty
                      ? FontWeight.w400
                      : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: ThemeColors.unifiedTextMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showMultiSelectDialog(BuildContext context) {
    // 1. Initialize temporary state outside the builder to persist changes during dialog rebuilds
    final List<DepartmentModel> tempSelected = List.from(selectedDepartments);

    // 2. Prepare the hierarchical display list once
    final List<DepartmentModel> displayList = [];
    final parents = allDepartments.where((d) => d.parentId == null).toList();
    for (var p in parents) {
      displayList.add(p);
      displayList.addAll(allDepartments.where((d) => d.parentId == p.id));
    }
    // Catch any remaining depts not caught by parent-child logic
    for (var d in allDepartments) {
      if (!displayList.any((item) => item.id == d.id)) {
        displayList.add(d);
      }
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        // 3. Use StatefulBuilder to manage the dialog's local state properly
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select Departments'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: ListBody(
                    children: displayList.map((dept) {
                      final bool isSub = dept.parentId != null;
                      return CheckboxListTile(
                        contentPadding: EdgeInsets.only(left: isSub ? 32 : 16),
                        value: tempSelected.any((e) => e.id == dept.id),
                        title: Text(
                          labelBuilder(dept),
                          style: TextStyle(
                            fontSize: isSub ? 13 : 14,
                            fontWeight: isSub
                                ? FontWeight.w400
                                : FontWeight.w600,
                            color: isSub
                                ? ThemeColors.unifiedTextMuted
                                : ThemeColors.unifiedTextPrimary,
                          ),
                        ),
                        onChanged: (bool? selected) {
                          setDialogState(() {
                            if (selected == true) {
                              if (!tempSelected.any((e) => e.id == dept.id)) {
                                tempSelected.add(dept);
                              }
                            } else {
                              tempSelected.removeWhere((e) => e.id == dept.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    onChanged(tempSelected);
                    Navigator.pop(dialogContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeColors.unifiedPrimary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Select'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

// ── Priority selector (pill buttons) ─────────────────────────────────────────
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

// ── Date picker field ─────────────────────────────────────────────────────────
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

// ── Submit button ─────────────────────────────────────────────────────────────
class _SubmitButton extends StatelessWidget {
  final bool submitting;
  final bool wide;
  final VoidCallback onTap;

  const _SubmitButton({
    required this.submitting,
    required this.onTap,
    required this.wide,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: submitting ? null : onTap,
      child: Container(
        width: wide ? null : double.infinity,
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

// ── Priority color helper ─────────────────────────────────────────────────────
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
