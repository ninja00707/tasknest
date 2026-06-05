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
  final int? parentTicketId;
  final String? parentTicketTitle;

  const CreateTicketView({
    super.key,
    required this.user,
    this.parentTicketId,
    this.parentTicketTitle,
  });

  @override
  State<CreateTicketView> createState() => _CreateTicketViewState();
}

class _CreateTicketViewState extends State<CreateTicketView> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _subTitle = TextEditingController();
  final _subDescription = TextEditingController();

  Priorities _priority = Priorities(name: 'medium', id: 0);
  Departments? _selectedDepartment;
  EmployeeModel? _selectedEmployee;
  String? _dueDate;
  bool _submitting = false;
  bool _selfAssign = false;
  bool _multiDept = false;
  List<Departments> _selectedDepartments = [];
  Map<int, _DeptFormData> _deptFormData = {};

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _subTitle.dispose();
    _subDescription.dispose();
    for (final d in _deptFormData.values) {
      d.titleCtrl.dispose();
      d.descCtrl.dispose();
    }
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
    final availableDepartments = blocState is DashboardLoaded
        ? blocState.departments
            .map((d) => Departments(name: d.name, id: d.id))
            .toList()
        : <Departments>[];

    return SingleChildScrollView(
      padding: EdgeInsets.all(isWide ? 28 : 16).copyWith(bottom: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // ── Page header ───────────────────────────────────────────
          _PageHeader(
            parentId: widget.parentTicketId,
            parentTitle: widget.parentTicketTitle,
            isMulti: _multiDept,
          ),
          const SizedBox(height: 24),

          // ── Form card ─────────────────────────────────────────────
          _FormCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Department mode toggle ─────────────────────────
                  _FieldLabel(
                    label: 'Department Mode',
                    icon: Icons.swap_horiz_rounded,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: ThemeColors.unifiedInputBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: ThemeColors.unifiedBorder,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _multiDept = false;
                              _selectedDepartments = [];
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: !_multiDept
                                    ? ThemeColors.unifiedPrimary
                                    : Colors.transparent,
                                borderRadius:
                                    const BorderRadius.horizontal(
                                      left: Radius.circular(9),
                                    ),
                              ),
                              child: Center(
                                child: Text(
                                  'Single Department',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: !_multiDept
                                        ? Colors.white
                                        : ThemeColors.unifiedTextMuted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _multiDept = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: _multiDept
                                    ? ThemeColors.unifiedPrimary
                                    : Colors.transparent,
                                borderRadius:
                                    const BorderRadius.horizontal(
                                      right: Radius.circular(9),
                                    ),
                              ),
                              child: Center(
                                child: Text(
                                  'Multi Department',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _multiDept
                                        ? Colors.white
                                        : ThemeColors.unifiedTextMuted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  isWide
                      ? _WideFormLayout(
                          titleCtrl: _title,
                          descCtrl: _description,
                          priority: _priority,
                          selectedDept: _selectedDepartment,
                          selectedEmployee: _selectedEmployee,
                          dueDate: _dueDate,
                          employeeList: employeeList,
                          canAssignEmployee: canAssignEmployee,
                          selfAssign: _selfAssign,
                          submitting: _submitting,
                          multiDept: _multiDept,
                          selectedDepartments: _selectedDepartments,
                          availableDepartments: availableDepartments,
                          onPriorityChanged:
                              (v) => setState(() => _priority = v),
                          onDeptChanged: _onDeptChanged,
                          onAddDepartment: _onAddDepartment,
                          onRemoveDepartment: _onRemoveDepartment,
                          onEmployeeChanged: (v) =>
                              setState(() => _selectedEmployee = v),
                          onSelfAssignChanged: (v) =>
                              setState(() => _selfAssign = v),
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
                          selfAssign: _selfAssign,
                          submitting: _submitting,
                          multiDept: _multiDept,
                          selectedDepartments: _selectedDepartments,
                          availableDepartments: availableDepartments,
                          onPriorityChanged:
                              (v) => setState(() => _priority = v),
                          onDeptChanged: _onDeptChanged,
                          onAddDepartment: _onAddDepartment,
                          onRemoveDepartment: _onRemoveDepartment,
                          onEmployeeChanged: (v) =>
                              setState(() => _selectedEmployee = v),
                          onSelfAssignChanged: (v) =>
                              setState(() => _selfAssign = v),
                          onDateTap: _pickDate,
                          onSubmit: _submit,
                        ),

                  // ── Sub-ticket fields ──────────────────────────────
                  if (widget.parentTicketId == null && (_multiDept ||
                      (_selectedDepartment != null &&
                          _selectedDepartment!.id !=
                              widget.user.departmentId))) ...[
                    const SizedBox(height: 20),
                    const Divider(
                      color: ThemeColors.unifiedBorder,
                      height: 1,
                    ),
                    const SizedBox(height: 16),
                    if (_multiDept && _selectedDepartments.isNotEmpty) ...[
                      _MultiDeptSection(
                        departments: _selectedDepartments,
                        formData: _deptFormData,
                      ),
                    ] else ...[
                      _FieldLabel(
                        label: 'Sub-Ticket Title',
                        icon: Icons.subdirectory_arrow_right_rounded,
                        required: true,
                      ),
                      const SizedBox(height: 8),
                      _StyledTextField(
                        controller: _subTitle,
                        hint: 'Title for the sub-ticket in target department',
                        validator: (v) =>
                            v == null || v.isEmpty
                                ? 'Sub-ticket title is required'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      _FieldLabel(
                        label: 'Sub-Ticket Description',
                        icon: Icons.notes_rounded,
                        required: true,
                      ),
                      const SizedBox(height: 8),
                      _StyledTextField(
                        controller: _subDescription,
                        hint: 'Describe the sub-ticket task in detail...',
                        maxLines: 3,
                        validator: (v) =>
                            v == null || v.isEmpty
                                ? 'Sub-ticket description is required'
                                : null,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
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

  void _onAddDepartment(Departments dept) {
    setState(() {
      _selectedDepartments.add(dept);
      _deptFormData[dept.id] = _DeptFormData();
    });
  }

  void _onRemoveDepartment(Departments dept) {
    setState(() {
      _selectedDepartments.removeWhere((s) => s.id == dept.id);
      _deptFormData[dept.id]?.dispose();
      _deptFormData.remove(dept.id);
    });
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

    if (_multiDept) {
      if (_selectedDepartments.isEmpty) {
        _showSnack('Please select at least one department', isError: true);
        return;
      }
      // Validate per-department fields
      for (final dept in _selectedDepartments) {
        final fd = _deptFormData[dept.id];
        if (fd == null || fd.titleCtrl.text.trim().isEmpty || fd.descCtrl.text.trim().isEmpty) {
          _showSnack('Please fill Title and Description for ${dept.name}', isError: true);
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

    final showSubFields = widget.parentTicketId == null && !_multiDept &&
        (_selectedDepartment != null &&
            _selectedDepartment!.id != widget.user.departmentId);

    final deptTickets = _multiDept
        ? _selectedDepartments.map((d) {
            final fd = _deptFormData[d.id]!;
            return DeptTicketData(
              departmentId: d.id,
              title: fd.titleCtrl.text.trim(),
              description: fd.descCtrl.text.trim(),
            );
          }).toList()
        : null;

    context.read<DashboardBloc>().add(
      CreateTicketEvent(
        title: _title.text.trim(),
        description: _description.text.trim(),
        priority: _priority.name,
        departmentIds: _multiDept
            ? _selectedDepartments.map((d) => d.id).toList()
            : [_selectedDepartment!.id],
        assignedToId: _selectedEmployee?.id,
        createdById: widget.user.id,
        createdByDept: widget.user.departmentId,
        dueDate: _dueDate,
        parentTicketId: widget.parentTicketId,
        selfAssign: _selfAssign,
        subTitle: showSubFields ? _subTitle.text.trim() : null,
        subDescription: showSubFields ? _subDescription.text.trim() : null,
        deptTickets: deptTickets,
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
  final int? parentId;
  final String? parentTitle;
  final bool isMulti;

  const _PageHeader({this.parentId, this.parentTitle, this.isMulti = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (parentId != null) ...[
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
                    'Creating sub-ticket for #$parentId ${parentTitle ?? ""}',
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
                  colors: [
                    ThemeColors.unifiedGradStart,
                    ThemeColors.unifiedGradEnd,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isMulti ? 'Create Multi Ticket' : 'Create Standard Ticket',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: ThemeColors.unifiedTextPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
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
        ),
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
  final bool canAssignEmployee, submitting, selfAssign, multiDept;
  final List<Departments> selectedDepartments;
  final List<Departments> availableDepartments;
  final ValueChanged<Priorities> onPriorityChanged;
  final ValueChanged<Departments> onDeptChanged;
  final ValueChanged<Departments> onAddDepartment;
  final ValueChanged<Departments> onRemoveDepartment;
  final ValueChanged<EmployeeModel> onEmployeeChanged;
  final ValueChanged<bool> onSelfAssignChanged;
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
    required this.selfAssign,
    required this.submitting,
    required this.multiDept,
    required this.selectedDepartments,
    required this.availableDepartments,
    required this.onPriorityChanged,
    required this.onDeptChanged,
    required this.onAddDepartment,
    required this.onRemoveDepartment,
    required this.onEmployeeChanged,
    required this.onSelfAssignChanged,
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
                    label: multiDept
                        ? 'Assign to Departments'
                        : 'Assign to Department',
                    icon: Icons.business_outlined,
                    required: true,
                  ),
                  const SizedBox(height: 8),
                  if (multiDept) ...[
                    _StyledDropdown<Departments>(
                      hint: 'Add department...',
                      value: null,
                      items: availableDepartments
                          .where(
                            (d) =>
                                !selectedDepartments
                                    .any((s) => s.id == d.id),
                          )
                          .toList(),
                      labelBuilder: (e) => e.name,
                      onChanged: onAddDepartment,
                    ),
                    if (selectedDepartments.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children:
                            selectedDepartments.map((d) {
                              return _DepartmentChip(
                                department: d,
                                onRemove: () =>
                                    onRemoveDepartment(d),
                              );
                            }).toList(),
                      ),
                    ],
                  ] else
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
  final bool canAssignEmployee, submitting, selfAssign, multiDept;
  final List<Departments> selectedDepartments;
  final List<Departments> availableDepartments;
  final ValueChanged<Priorities> onPriorityChanged;
  final ValueChanged<Departments> onDeptChanged;
  final ValueChanged<Departments> onAddDepartment;
  final ValueChanged<Departments> onRemoveDepartment;
  final ValueChanged<EmployeeModel> onEmployeeChanged;
  final ValueChanged<bool> onSelfAssignChanged;
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
    required this.selfAssign,
    required this.submitting,
    required this.multiDept,
    required this.selectedDepartments,
    required this.availableDepartments,
    required this.onPriorityChanged,
    required this.onDeptChanged,
    required this.onAddDepartment,
    required this.onRemoveDepartment,
    required this.onEmployeeChanged,
    required this.onSelfAssignChanged,
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
          label: multiDept
              ? 'Assign to Departments'
              : 'Assign to Department',
          icon: Icons.business_outlined,
          required: true,
        ),
        const SizedBox(height: 8),
        if (multiDept) ...[
          _StyledDropdown<Departments>(
            hint: 'Add department...',
            value: null,
            items: availableDepartments
                .where(
                  (d) =>
                      !selectedDepartments
                          .any((s) => s.id == d.id),
                )
                .toList(),
            labelBuilder: (e) => e.name,
            onChanged: onAddDepartment,
          ),
          if (selectedDepartments.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children:
                  selectedDepartments.map((d) {
                    return _DepartmentChip(
                      department: d,
                      onRemove: () => onRemoveDepartment(d),
                    );
                  }).toList(),
            ),
          ],
        ] else
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

// ── Department chip for multi-select ──────────────────────────────────────────
class _DepartmentChip extends StatelessWidget {
  final Departments department;
  final VoidCallback onRemove;

  const _DepartmentChip({
    required this.department,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 4, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedPrimary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ThemeColors.unifiedPrimary.withOpacity(0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            department.name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ThemeColors.unifiedPrimary,
            ),
          ),
          const SizedBox(width: 2),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.close_rounded,
                size: 14,
                color: ThemeColors.unifiedTextMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Per-department section (multi mode) ────────────────────────────────────────
class _MultiDeptSection extends StatelessWidget {
  final List<Departments> departments;
  final Map<int, _DeptFormData> formData;

  const _MultiDeptSection({
    required this.departments,
    required this.formData,
  });

  static const _deptColors = [
    Color(0xFF4F46E5),
    Color(0xFF0891B2),
    Color(0xFF059669),
    Color(0xFFD97706),
    Color(0xFFDC2626),
    Color(0xFF7C3AED),
    Color(0xFFDB2777),
    Color(0xFF2563EB),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.dashboard_customize_rounded,
              size: 16,
              color: ThemeColors.unifiedTextMuted,
            ),
            const SizedBox(width: 6),
            const Text(
              'Department Tickets',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: ThemeColors.unifiedTextPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: ThemeColors.unifiedPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${departments.length} depts',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.unifiedPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...departments.asMap().entries.map((entry) {
          final idx = entry.key;
          final dept = entry.value;
          final fd = formData[dept.id];
          final color = _deptColors[idx % _deptColors.length];

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2), width: 1.5),
            ),
            clipBehavior: Clip.hardEdge,
            child: Column(
              children: [
                // Dept header bar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    border: Border(
                      bottom: BorderSide(
                        color: color.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        dept.name,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: color,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Ticket #${idx + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                // Fields
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel(
                        label: 'Title',
                        icon: Icons.title_rounded,
                        required: true,
                      ),
                      const SizedBox(height: 6),
                      _StyledTextField(
                        controller: fd?.titleCtrl ?? TextEditingController(),
                        hint: 'Title for ${dept.name} sub-ticket',
                        validator: (v) =>
                            v == null || v.isEmpty
                                ? 'Title is required for ${dept.name}'
                                : null,
                      ),
                      const SizedBox(height: 12),
                      _FieldLabel(
                        label: 'Description',
                        icon: Icons.notes_rounded,
                        required: true,
                      ),
                      const SizedBox(height: 6),
                      _StyledTextField(
                        controller: fd?.descCtrl ?? TextEditingController(),
                        hint: 'Describe task for ${dept.name}...',
                        maxLines: 2,
                        validator: (v) =>
                            v == null || v.isEmpty
                                ? 'Description is required for ${dept.name}'
                                : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ── Per-department form data (multi mode) ─────────────────────────────────────
class _DeptFormData {
  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;
  _DeptFormData({String title = '', String description = ''})
      : titleCtrl = TextEditingController(text: title),
        descCtrl = TextEditingController(text: description);
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
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
