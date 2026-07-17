import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_dep.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/create_ticket_module/bloc/create_ticket_bloc.dart';
import 'package:tasknest/presentation/create_ticket_module/bloc/create_ticket_event.dart';
import 'package:tasknest/presentation/create_ticket_module/bloc/create_ticket_state.dart';
import 'package:tasknest/presentation/create_ticket_module/widget/create_ticket_form.dart';
import 'package:tasknest/presentation/create_ticket_module/widget/create_ticket_layouts.dart';

class CreateTicketView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => context.read<CreateTicketBloc>(),
      child: _CreateTicketBody(
        user: user,
        parentTicketId: parentTicketId,
        parentTicketTitle: parentTicketTitle,
      ),
    );
  }
}

class _CreateTicketBody extends StatefulWidget {
  final UserModel user;
  final int? parentTicketId;
  final String? parentTicketTitle;

  const _CreateTicketBody({
    required this.user,
    this.parentTicketId,
    this.parentTicketTitle,
  });

  @override
  State<_CreateTicketBody> createState() => _CreateTicketBodyState();
}

class _CreateTicketBodyState extends State<_CreateTicketBody> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final Map<int, DeptFormData> _deptFormData = {};

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    for (final d in _deptFormData.values) {
      d.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateTicketBloc, CreateTicketBaseState>(
      listenWhen: (prev, curr) =>
          curr is CreateTicketSuccess || curr is CreateTicketError,
      listener: (context, state) {
        if (state is CreateTicketSuccess) {
          _showSnack(context, 'Ticket created!');
          _resetForm();
        } else if (state is CreateTicketError) {
          _showSnack(context, state.message, isError: true);
        }
      },
      child: BlocBuilder<CreateTicketBloc, CreateTicketBaseState>(
        buildWhen: (prev, curr) => curr is CreateTicketFormState,
        builder: (context, blocState) {
          final form = blocState as CreateTicketFormState;

          final blocData = context.watch<DashboardBloc>().state;
          final isWide = blocData is DashboardLoaded ? blocData.isWide : true;
          final allEmployees = blocData is DashboardLoaded
              ? blocData.employees
              : <EmployeeModel>[];
          final employeeList = form.selectedDepartments.length == 1
              ? allEmployees
                  .where((e) =>
                      e.departmentId ==
                          form.selectedDepartments.first.id &&
                      e.isActive)
                  .toList()
              : allEmployees.where((e) => e.isActive).toList();
          final canAssignEmployee = widget.user.roleId == 0 ||
              widget.user.roleId == 1 ||
              widget.user.roleId == 3;
          final availableDepartments = blocData is DashboardLoaded
              ? blocData.departments
                  .map((d) => Departments(name: d.name, id: d.id))
                  .toList()
              : <Departments>[];

          return SingleChildScrollView(
            padding: EdgeInsets.all(isWide ? 28 : 16).copyWith(bottom: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                PageHeader(
                  parentId: widget.parentTicketId,
                  parentTitle: widget.parentTicketTitle,
                  isMulti: form.isMulti,
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
                                priority: form.priority,
                                selectedEmployee: form.selectedEmployee,
                                employeeList: employeeList,
                                canAssignEmployee:
                                    canAssignEmployee && !form.isMulti,
                                selfAssign: form.selfAssign,
                                submitting: form.submitting,
                                isMulti: form.isMulti,
                                selectedDepartments: form.selectedDepartments,
                                availableDepartments: availableDepartments,
                                onPriorityChanged: (v) => context
                                    .read<CreateTicketBloc>()
                                    .add(UpdatePriority(v)),
                                onAddDepartment: (d) => context
                                    .read<CreateTicketBloc>()
                                    .add(AddDepartment(d)),
                                onRemoveDepartment: (d) => context
                                    .read<CreateTicketBloc>()
                                    .add(RemoveDepartment(d)),
                                onEmployeeChanged: (v) => context
                                    .read<CreateTicketBloc>()
                                    .add(UpdateEmployee(v)),
                                onSelfAssignChanged: (v) => context
                                    .read<CreateTicketBloc>()
                                    .add(ToggleSelfAssign(v)),
                                deptFormData: _deptFormData,
                                onSubmit: _submit,
                              )
                            : NarrowFormLayout(
                                deptFormData: _deptFormData,
                                titleCtrl: _title,
                                descCtrl: _description,
                                priority: form.priority,
                                selectedEmployee: form.selectedEmployee,
                                employeeList: employeeList,
                                canAssignEmployee:
                                    canAssignEmployee && !form.isMulti,
                                selfAssign: form.selfAssign,
                                submitting: form.submitting,
                                isMulti: form.isMulti,
                                selectedDepartments: form.selectedDepartments,
                                availableDepartments: availableDepartments,
                                onPriorityChanged: (v) => context
                                    .read<CreateTicketBloc>()
                                    .add(UpdatePriority(v)),
                                onAddDepartment: (d) => context
                                    .read<CreateTicketBloc>()
                                    .add(AddDepartment(d)),
                                onRemoveDepartment: (d) => context
                                    .read<CreateTicketBloc>()
                                    .add(RemoveDepartment(d)),
                                onEmployeeChanged: (v) => context
                                    .read<CreateTicketBloc>()
                                    .add(UpdateEmployee(v)),
                                onSelfAssignChanged: (v) => context
                                    .read<CreateTicketBloc>()
                                    .add(ToggleSelfAssign(v)),
                                onSubmit: _submit,
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final form = context.read<CreateTicketBloc>().state as CreateTicketFormState;

    if (form.selectedDepartments.isEmpty) {
      _showSnack(context, 'Please select at least one department',
          isError: true);
      return;
    }

    if (form.isMulti) {
      for (final dept in form.selectedDepartments) {
        final fd = _deptFormData[dept.id];
        if (fd == null ||
            fd.titleCtrl.text.trim().isEmpty ||
            fd.descCtrl.text.trim().isEmpty) {
          _showSnack(
            context,
            'Please fill Title and Description for ${dept.name}',
            isError: true,
          );
          return;
        }
      }
    }

    Map<int, ({String title, String description})>? deptTickets;
    if (form.isMulti) {
      deptTickets = {};
      for (final dept in form.selectedDepartments) {
        final fd = _deptFormData[dept.id]!;
        deptTickets[dept.id] = (
          title: fd.titleCtrl.text.trim(),
          description: fd.descCtrl.text.trim(),
        );
      }
    }

    context.read<CreateTicketBloc>().add(SubmitTicket(
          title: _title.text.trim(),
          description: _description.text.trim(),
          createdById: widget.user.id,
          createdByDept: widget.user.departmentId,
          parentTicketId: widget.parentTicketId,
          deptTickets: deptTickets,
        ));
  }

  void _resetForm() {
    _title.clear();
    _description.clear();
    for (final d in _deptFormData.values) {
      d.dispose();
    }
    _deptFormData.clear();
    _formKey.currentState?.reset();
  }

  void _showSnack(BuildContext context, String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            isError ? ThemeColors.unifiedDanger : ThemeColors.unifiedPrimary,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
