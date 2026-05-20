// ── Create Ticket View ────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_dep.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_button.dart';
import 'package:tasknest/core/theme/common_decoration.dart';
import 'package:tasknest/core/theme/common_dropDown.dart';
import 'package:tasknest/core/theme/common_text.dart';
import 'package:tasknest/core/theme/common_textForm_Field.dart';
import 'package:tasknest/data/datasource/localstorage/sharedpreferences.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/model/ticketmodel.dart';

class CreateTicketView extends StatefulWidget {
  // final List<DepartmentModel> departments;
  const CreateTicketView({super.key});

  @override
  State<CreateTicketView> createState() => CreateTicketViewState();
}

class CreateTicketViewState extends State<CreateTicketView> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  Priorities priority = Priorities(name: 'medium', id: 0);

  String? _dueDate;
  Departments _selectedDepartment = Departments(id: 0, name: 'HR');

  UserModel? _user;
  EmployeeModel? _selectedEmployee;

  @override
  void initState() {
    super.initState();
    _loadUser();
    // No need to load employees here, they are loaded by DashboardBloc
  }

  void _loadUser() async {
    _user = await LocalStorageService().getUser();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final blocState = context.watch<DashboardBloc>().state;
    List<EmployeeModel> employeeList = [];
    if (blocState is DashboardLoaded) {
      employeeList = blocState.employees;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CommonText(
            'Create New Ticket',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: ThemeColors.unifiedTextPrimary,
          ),

          const SizedBox(height: 4),
          const CommonText(
            'Fill details and assign to a department.',
            fontSize: 13,
            color: ThemeColors.unifiedTextMuted,
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ThemeColors.unifiedSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ThemeColors.unifiedBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gradient top strip
                CommonDecoration().commonTopGradStrip,

                CommonText(
                  'Title',
                  customeStyle: CommonDecoration().commonFormLabelStyle,
                ),
                const SizedBox(height: 6),

                CommonTextFormField(
                  controller: _title,
                  hint: 'Enter a clear, descriptive title',
                ),
                const SizedBox(height: 16),

                CommonText(
                  'Description',
                  customeStyle: CommonDecoration().commonFormLabelStyle,
                ),
                const SizedBox(height: 6),
                CommonTextFormField(
                  controller: _description,
                  hint: 'Describe the task in detail...',
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                CommonText(
                  'Assign to Department',
                  customeStyle: CommonDecoration().commonFormLabelStyle,
                ),

                const SizedBox(height: 6),

                CommonDropdown<Departments>(
                  hint: 'Select Department',
                  items: departments.map((dept) {
                    return DropdownItem<Departments>(
                      value: dept,
                      label: dept.name,
                    );
                  }).toList(),

                  onChanged: (Departments value) {
                    setState(() {
                      _selectedDepartment = value;
                    });
                  },
                ),

                if (_user!.roleId == 1) ...[
                  // Show for managers and CEOs
                  const SizedBox(height: 16),
                  CommonText(
                    'Assign to Employee (Optional)',
                    customeStyle: CommonDecoration().commonFormLabelStyle,
                  ),
                  const SizedBox(height: 6),
                  CommonDropdown<EmployeeModel>(
                    hint: 'Select Employee',
                    items: employeeList.map((emp) {
                      return DropdownItem<EmployeeModel>(
                        // Ensure EmployeeModel is correctly used
                        value: emp,
                        label: emp.name,
                      );
                    }).toList(),
                    onChanged: (EmployeeModel value) {
                      setState(() {
                        _selectedEmployee = value;
                      });
                    },
                  ),
                ],

                const SizedBox(height: 16),
                CommonText(
                  'Priority',
                  customeStyle: CommonDecoration().commonFormLabelStyle,
                ),

                const SizedBox(height: 6),
                CommonDropdown<Priorities>(
                  hint: 'Select Priority',

                  items: priorities.map((dept) {
                    return DropdownItem<Priorities>(
                      value: dept,
                      label: dept.name,
                    );
                  }).toList(),
                  onChanged: (Priorities value) {
                    setState(() {
                      priority = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                CommonText(
                  'Due Date (optional)',
                  customeStyle: CommonDecoration().commonFormLabelStyle,
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 3)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null)
                      setState(
                        () => _dueDate = picked
                            .toIso8601String()
                            .split('T')
                            .first,
                      );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeColors.unifiedInputBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ThemeColors.unifiedBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: ThemeColors.unifiedAccent,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _dueDate ?? 'Pick a due date',
                          style: TextStyle(
                            fontSize: 14,
                            color: _dueDate != null
                                ? ThemeColors.unifiedTextPrimary
                                : ThemeColors.unifiedTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                CommonButton(onTap: _submit, buttonName: 'Submit Ticket'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submit() async {
    if (_title.text.isEmpty || _description.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: ThemeColors.unifiedDanger,
        ),
      );
      return;
    }

    final user = await LocalStorageService()
        .getUser(); // Await the async call to ensure user data is loaded

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not found'),
          backgroundColor: ThemeColors.unifiedDanger,
        ),
      );
      return;
    }
    context.read<DashboardBloc>().add(
      CreateTicketEvent(
        title: _title.text.trim(),
        description: _description.text.trim(),
        priority: priority.name,
        assignedDeptId: _selectedDepartment.id,
        assignedToId: _selectedEmployee?.id,

        // FETCHED FROM STORAGE
        createdById: user.id,
        createdByDept: user.departmentId,

        dueDate: _dueDate,
      ),
    );
  }
}
