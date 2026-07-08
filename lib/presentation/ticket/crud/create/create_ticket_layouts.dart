import 'package:flutter/material.dart' hide FormField;
import 'package:tasknest/core/constant/const_dep.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/ticket/crud/create/create_ticket_form.dart';

class WideFormLayout extends StatelessWidget {
  final TextEditingController titleCtrl, descCtrl;
  final Priorities priority;
  final EmployeeModel? selectedEmployee;
  final List<EmployeeModel> employeeList;
  final bool canAssignEmployee, submitting, selfAssign, isMulti;
  final List<Departments> selectedDepartments;
  final List<Departments> availableDepartments;
  final Map<int, DeptFormData> deptFormData;
  final ValueChanged<Priorities> onPriorityChanged;
  final ValueChanged<Departments> onAddDepartment;
  final ValueChanged<Departments> onRemoveDepartment;
  final ValueChanged<EmployeeModel> onEmployeeChanged;
  final ValueChanged<bool> onSelfAssignChanged;
  final VoidCallback onSubmit;

  const WideFormLayout({super.key, 
    required this.titleCtrl,
    required this.descCtrl,
    required this.priority,
    required this.selectedEmployee,
    required this.employeeList,
    required this.canAssignEmployee,
    required this.selfAssign,
    required this.submitting,
    required this.isMulti,
    required this.selectedDepartments,
    required this.availableDepartments,
    required this.deptFormData,
    required this.onPriorityChanged,
    required this.onAddDepartment,
    required this.onRemoveDepartment,
    required this.onEmployeeChanged,
    required this.onSelfAssignChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FormField(label: 'Title', icon: Icons.title_rounded, required: true),
        const SizedBox(height: 8),
        StyledTextField(
          controller: titleCtrl,
          hint: 'Enter a clear, descriptive title',
          validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
        ),
        const SizedBox(height: 20),
        FormField(
          label: 'Description',
          icon: Icons.notes_rounded,
          required: true,
        ),
        const SizedBox(height: 8),
        StyledTextField(
          controller: descCtrl,
          hint: 'Describe the task in full detail...',
          maxLines: 4,
          validator: (v) =>
              v == null || v.isEmpty ? 'Description is required' : null,
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormField(
                    label: isMulti
                        ? 'Assign to Departments'
                        : 'Assign to Department',
                    icon: Icons.business_outlined,
                    required: true,
                  ),
                  const SizedBox(height: 8),
                  StyledDropdown<Departments>(
                    hint: 'Add department...',
                    value: null,
                    items: availableDepartments
                        .where(
                          (d) => !selectedDepartments.any((s) => s.id == d.id),
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
                      children: selectedDepartments.map((d) {
                        return DepartmentChip(
                          department: d,
                          onRemove: () => onRemoveDepartment(d),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormField(
                    label: 'Priority',
                    icon: Icons.flag_outlined,
                    required: true,
                  ),
                  const SizedBox(height: 8),
                  PrioritySelector(
                    selected: priority,
                    onChanged: onPriorityChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
        if (isMulti) ...[
          const SizedBox(height: 24),
          MultiDeptSection(
            departments: selectedDepartments,
            formData: deptFormData,
          ),
        ],
        if (!isMulti && canAssignEmployee) const SizedBox(height: 20),
        if (!isMulti && canAssignEmployee)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormField(
                label: 'Assign to Employee',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 8),
              StyledDropdown<EmployeeModel>(
                hint: selectedDepartments.length != 1
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
            ],
          ),
        if (!isMulti && canAssignEmployee) const SizedBox(height: 28),
        if (!canAssignEmployee) const SizedBox(height: 20),

        Align(
          alignment: Alignment.centerRight,
          child: SubmitButton(
            submitting: submitting,
            onTap: onSubmit,
            wide: true,
          ),
        ),
      ],
    );
  }
}

class NarrowFormLayout extends StatelessWidget {
  final TextEditingController titleCtrl, descCtrl;
  final Priorities priority;
  final EmployeeModel? selectedEmployee;
  final List<EmployeeModel> employeeList;
  final bool canAssignEmployee, submitting, selfAssign, isMulti;
  final List<Departments> selectedDepartments;
  final List<Departments> availableDepartments;
  final Map<int, DeptFormData> deptFormData;
  final ValueChanged<Priorities> onPriorityChanged;
  final ValueChanged<Departments> onAddDepartment;
  final ValueChanged<Departments> onRemoveDepartment;
  final ValueChanged<EmployeeModel> onEmployeeChanged;
  final ValueChanged<bool> onSelfAssignChanged;
  final VoidCallback onSubmit;

  const NarrowFormLayout({super.key, 
    required this.titleCtrl,
    required this.descCtrl,
    required this.priority,
    required this.selectedEmployee,
    required this.employeeList,
    required this.canAssignEmployee,
    required this.selfAssign,
    required this.submitting,
    required this.isMulti,
    required this.selectedDepartments,
    required this.availableDepartments,
    required this.deptFormData,
    required this.onPriorityChanged,
    required this.onAddDepartment,
    required this.onRemoveDepartment,
    required this.onEmployeeChanged,
    required this.onSelfAssignChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormField(label: 'Title', icon: Icons.title_rounded, required: true),
        const SizedBox(height: 8),
        StyledTextField(
          controller: titleCtrl,
          hint: 'Enter a clear, descriptive title',
          validator: (v) => v == null || v.isEmpty ? 'Title is required' : null,
        ),
        const SizedBox(height: 20),

        FormField(
          label: 'Description',
          icon: Icons.notes_rounded,
          required: true,
        ),
        const SizedBox(height: 8),
        StyledTextField(
          controller: descCtrl,
          hint: 'Describe the task in full detail...',
          maxLines: 4,
          validator: (v) =>
              v == null || v.isEmpty ? 'Description is required' : null,
        ),
        const SizedBox(height: 20),

        FormField(
          label: isMulti ? 'Assign to Departments' : 'Assign to Department',
          icon: Icons.business_outlined,
          required: true,
        ),
        const SizedBox(height: 8),
        StyledDropdown<Departments>(
          hint: 'Add department...',
          value: null,
          items: availableDepartments
              .where((d) => !selectedDepartments.any((s) => s.id == d.id))
              .toList(),
          labelBuilder: (e) => e.name,
          onChanged: onAddDepartment,
        ),
        if (selectedDepartments.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: selectedDepartments.map((d) {
              return DepartmentChip(
                department: d,
                onRemove: () => onRemoveDepartment(d),
              );
            }).toList(),
          ),
        ],
        if (isMulti) ...[
          const SizedBox(height: 20),
          MultiDeptSection(
            departments: selectedDepartments,
            formData: deptFormData,
          ),
        ],
        const SizedBox(height: 20),

        FormField(
          label: 'Priority',
          icon: Icons.flag_outlined,
          required: true,
        ),
        const SizedBox(height: 8),
        PrioritySelector(selected: priority, onChanged: onPriorityChanged),
        const SizedBox(height: 20),

        if (!isMulti && canAssignEmployee) ...[
          FormField(
            label: 'Assign to Employee',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 8),
          StyledDropdown<EmployeeModel>(
            hint: selectedDepartments.length != 1
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

        const SizedBox(height: 20),

        SubmitButton(submitting: submitting, onTap: onSubmit, wide: false),
      ],
    );
  }
}
