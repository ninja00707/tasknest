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
  Departments? _selectedDepartment;
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
    final canAssignEmployee =
        widget.user.roleId == 0 || widget.user.roleId == 1;

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
                        selectedDept: _selectedDepartment,
                        selectedEmployee: _selectedEmployee,
                        dueDate: _dueDate,
                        employeeList: employeeList,
                        canAssignEmployee: canAssignEmployee,
                        submitting: _submitting,
                        onPriorityChanged: (v) => setState(() => _priority = v),
                        onDeptChanged: _onDeptChanged,
                        onEmployeeChanged: (v) =>
                            setState(() => _selectedEmployee = v),
                        onDateTap: _pickDate,
                        onSubmit: _submit,
                      )
                    : _NarrowFormLayout(
                        titleCtrl: _title,
                        descCtrl: _description,
                        priority: _priority,
                        selectedDept: _selectedDepartment,
                        selectedEmployee: _selectedEmployee,
                        dueDate: _dueDate,
                        employeeList: employeeList,
                        canAssignEmployee: canAssignEmployee,
                        submitting: _submitting,
                        onPriorityChanged: (v) => setState(() => _priority = v),
                        onDeptChanged: _onDeptChanged,
                        onEmployeeChanged: (v) =>
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
    if (_selectedDepartment == null) {
      _showSnack('Please select a department', isError: true);
      return;
    }

    setState(() => _submitting = true);

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
  final Departments? selectedDept;
  final EmployeeModel? selectedEmployee;
  final String? dueDate;
  final List<EmployeeModel> employeeList;
  final bool canAssignEmployee, submitting;
  final ValueChanged<Priorities> onPriorityChanged;
  final ValueChanged<Departments> onDeptChanged;
  final ValueChanged<EmployeeModel> onEmployeeChanged;
  final VoidCallback onDateTap, onSubmit;

  const _WideFormLayout({
    required this.titleCtrl,
    required this.descCtrl,
    required this.priority,
    required this.selectedDept,
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
                  _StyledDropdown<Departments>(
                    hint: 'Select Department',
                    value: selectedDept,
                    items: departments,
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
                      label: 'Assign to Employee',
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 8),
                    _StyledDropdown<EmployeeModel>(
                      hint: selectedDept == null
                          ? 'Select dept first'
                          : employeeList.isEmpty
                          ? 'No employees found'
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
  final Departments? selectedDept;
  final EmployeeModel? selectedEmployee;
  final String? dueDate;
  final List<EmployeeModel> employeeList;
  final bool canAssignEmployee, submitting;
  final ValueChanged<Priorities> onPriorityChanged;
  final ValueChanged<Departments> onDeptChanged;
  final ValueChanged<EmployeeModel> onEmployeeChanged;
  final VoidCallback onDateTap, onSubmit;

  const _NarrowFormLayout({
    required this.titleCtrl,
    required this.descCtrl,
    required this.priority,
    required this.selectedDept,
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
        _StyledDropdown<Departments>(
          hint: 'Select Department',
          value: selectedDept,
          items: departments,
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
            hint: selectedDept == null
                ? 'Select dept first'
                : employeeList.isEmpty
                ? 'No employees found'
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
