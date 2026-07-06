import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_dep.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/ticket/bloc/ticket_bloc.dart';
import 'package:tasknest/presentation/ticket/bloc/ticket_event.dart';
import 'package:tasknest/presentation/ticket/bloc/ticket_state.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/ticket/crud/create/create_ticket_form.dart';
import 'package:tasknest/presentation/ticket/crud/create/create_ticket_layouts.dart';

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
  State<CreateTicketView> createState() => CreateTicketViewState();
}

class CreateTicketViewState extends State<CreateTicketView> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  Priorities _priority = Priorities(name: 'medium', id: 0);
  EmployeeModel? _selectedEmployee;
  bool _submitting = false;
  bool _selfAssign = false;
  List<Departments> _selectedDepartments = [];
  Map<int, DeptFormData> _deptFormData = {};

  bool get _isMulti => _selectedDepartments.length > 1;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
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
        widget.user.roleId == 0 ||
        widget.user.roleId == 1 ||
        widget.user.roleId == 3;
    final availableDepartments = blocState is DashboardLoaded
        ? blocState.departments
              .map((d) => Departments(name: d.name, id: d.id))
              .toList()
        : <Departments>[];

    return BlocListener<TicketBloc, TicketState>(
      listener: (context, state) {
        if (state is TicketActionSuccess) {
          _showSnack(state.message);
          _resetForm();
        } else if (state is TicketActionError) {
          _showSnack(state.message, isError: true);
          setState(() => _submitting = false);
        }
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isWide ? 28 : 16).copyWith(bottom: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            PageHeader(
              parentId: widget.parentTicketId,
              parentTitle: widget.parentTicketTitle,
              isMulti: _isMulti,
            ),
            const SizedBox(height: 24),
            FormCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isWide
                        ? WideFormLayout(
                            titleCtrl: _title,
                            descCtrl: _description,
                            priority: _priority,
                            selectedEmployee: _selectedEmployee,
                            employeeList: employeeList,
                            canAssignEmployee: canAssignEmployee && !_isMulti,
                            selfAssign: _selfAssign,
                            submitting: _submitting,
                            isMulti: _isMulti,
                            selectedDepartments: _selectedDepartments,
                            availableDepartments: availableDepartments,
                            onPriorityChanged: (v) =>
                                setState(() => _priority = v),
                            onAddDepartment: _onAddDepartment,
                            onRemoveDepartment: _onRemoveDepartment,
                            onEmployeeChanged: (v) =>
                                setState(() => _selectedEmployee = v),
                            onSelfAssignChanged: (v) =>
                                setState(() => _selfAssign = v),
                            deptFormData: _deptFormData,
                            onSubmit: _submit,
                          )
                        : NarrowFormLayout(
                            deptFormData: _deptFormData,
                            titleCtrl: _title,
                            descCtrl: _description,
                            priority: _priority,
                            selectedEmployee: _selectedEmployee,
                            employeeList: employeeList,
                            canAssignEmployee: canAssignEmployee && !_isMulti,
                            selfAssign: _selfAssign,
                            submitting: _submitting,
                            isMulti: _isMulti,
                            selectedDepartments: _selectedDepartments,
                            availableDepartments: availableDepartments,
                            onPriorityChanged: (v) =>
                                setState(() => _priority = v),
                            onAddDepartment: _onAddDepartment,
                            onRemoveDepartment: _onRemoveDepartment,
                            onEmployeeChanged: (v) =>
                                setState(() => _selectedEmployee = v),
                            onSelfAssignChanged: (v) =>
                                setState(() => _selfAssign = v),
                            onSubmit: _submit,
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onAddDepartment(Departments dept) {
    setState(() {
      _selectedDepartments.add(dept);
      _deptFormData[dept.id] = DeptFormData();
      _selectedEmployee = null;
    });
    if (_selectedDepartments.length == 1) {
      context.read<DashboardBloc>().add(LoadEmployeesForDept(dept.id));
    }
  }

  void _onRemoveDepartment(Departments dept) {
    setState(() {
      _selectedDepartments.removeWhere((s) => s.id == dept.id);
      _deptFormData[dept.id]?.dispose();
      _deptFormData.remove(dept.id);
      _selectedEmployee = null;
    });
    if (_selectedDepartments.length == 1) {
      context.read<DashboardBloc>().add(
        LoadEmployeesForDept(_selectedDepartments.first.id),
      );
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
  }

  void _resetForm() {
    _title.clear();
    _description.clear();
    _priority = Priorities(name: 'medium', id: 0);
    _selectedEmployee = null;
    _selfAssign = false;
    _selectedDepartments = [];
    for (final d in _deptFormData.values) {
      d.dispose();
    }
    _deptFormData.clear();
    _formKey.currentState?.reset();
    setState(() => _submitting = false);
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedDepartments.isEmpty) {
      _showSnack('Please select at least one department', isError: true);
      return;
    }

    if (_isMulti) {
      for (final dept in _selectedDepartments) {
        final fd = _deptFormData[dept.id];
        if (fd == null ||
            fd.titleCtrl.text.trim().isEmpty ||
            fd.descCtrl.text.trim().isEmpty) {
          _showSnack(
            'Please fill Title and Description for ${dept.name}',
            isError: true,
          );
          return;
        }
      }
    }

    setState(() => _submitting = true);

    final deptTickets = _isMulti
        ? _selectedDepartments.map((d) {
            final fd = _deptFormData[d.id]!;
            return DeptTicketData(
              departmentId: d.id,
              title: fd.titleCtrl.text.trim(),
              description: fd.descCtrl.text.trim(),
            );
          }).toList()
        : null;

    context.read<TicketBloc>().add(
      CreateTicketEvent(
        title: _title.text.trim(),
        description: _description.text.trim(),
        priority: _priority.name,
        departmentIds: _selectedDepartments.map((d) => d.id).toList(),
        assignedToId: _isMulti ? null : _selectedEmployee?.id,
        createdById: widget.user.id,
        createdByDept: widget.user.departmentId,
        dueDate: null,
        parentTicketId: widget.parentTicketId,
        selfAssign: _selfAssign,
        subTitle: null,
        subDescription: null,
        deptTickets: deptTickets,
      ),
    );
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

class DatePicker extends StatelessWidget {
  final String? dueDate;
  final VoidCallback onTap;

  const DatePicker({this.dueDate, required this.onTap});

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
