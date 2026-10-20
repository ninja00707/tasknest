// ══════════════════════════════════════════════════════════════════════════════
//  SHARED FORM WIDGETS + create_project_screen + edit_project_screen
//  + add_task_screen  — all in one file for brevity, split as you prefer.
// ══════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/domain/repositories_impl/project_impl/project_impl.dart';
import 'package:tasknest/presentation/projects/bloc/project_bloc.dart';
import 'package:tasknest/presentation/projects/bloc/project_event.dart';
import 'package:tasknest/presentation/projects/bloc/project_state.dart';
import 'package:tasknest/presentation/projects/model/project_models.dart';
import 'package:tasknest/presentation/projects/screens/project_list_screen.dart';
import 'package:tasknest/presentation/projects/widgets/ui_helpers.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

// ── Shared helpers ────────────────────────────────────────────────────────────

InputDecoration _fieldDeco(String label, {String? hint}) => InputDecoration(
  labelText: label,
  labelStyle: const TextStyle(
    fontSize: 13,
    color: ThemeColors.unifiedTextMuted,
    fontWeight: FontWeight.w500,
  ),
  hintText: hint,
  hintStyle: const TextStyle(fontSize: 12, color: ThemeColors.unifiedTextMuted),
  isDense: true,
  filled: true,
  fillColor: ThemeColors.unifiedInputBg,
  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide.none,
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: ThemeColors.unifiedBorder, width: 0.8),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: const BorderSide(color: ThemeColors.unifiedPrimary, width: 1.5),
  ),
);

Widget _sectionCard({
  required IconData icon,
  required String title,
  required Widget child,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: ThemeColors.unifiedSurface,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: ThemeColors.unifiedBorder, width: 0.8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: ThemeColors.unifiedPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(icon, size: 14, color: ThemeColors.unifiedPrimary),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: ThemeColors.unifiedTextPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
}

Widget _prioritySelector(String current, void Function(String) onChanged) {
  final opts = [
    _PriOpt('low', 'Low', ThemeColors.unifiedSuccess),
    _PriOpt('medium', 'Medium', ThemeColors.priorityMedFg),
    _PriOpt('high', 'High', ThemeColors.priorityHighFg),
    _PriOpt('urgent', 'Urgent', ThemeColors.unifiedDanger),
  ];
  return Row(
    children: opts.map((o) {
      final sel = current == o.key;
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: GestureDetector(
            onTap: () => onChanged(o.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: sel
                    ? o.color.withValues(alpha: 0.12)
                    : ThemeColors.unifiedInputBg,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: sel ? o.color : ThemeColors.unifiedBorder,
                  width: sel ? 1.5 : 0.8,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                o.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                  color: sel ? o.color : ThemeColors.unifiedTextPrimary,
                ),
              ),
            ),
          ),
        ),
      );
    }).toList(),
  );
}

class _PriOpt {
  final String key, label;
  final Color color;
  const _PriOpt(this.key, this.label, this.color);
}

Widget _datePicker({
  required String label,
  required DateTime? value,
  required IconData icon,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedInputBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ThemeColors.unifiedBorder, width: 0.8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: ThemeColors.unifiedPrimary),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: ThemeColors.unifiedTextMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value != null
                      ? DateFormat('MMM d, y').format(value)
                      : 'Select date',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: value != null
                        ? ThemeColors.unifiedTextPrimary
                        : ThemeColors.unifiedTextMuted,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.calendar_month_outlined,
            size: 14,
            color: ThemeColors.unifiedTextMuted.withValues(alpha: 0.5),
          ),
        ],
      ),
    ),
  );
}

Widget _submitBtn({
  required String label,
  required bool loading,
  required VoidCallback? onTap,
}) {
  return GestureDetector(
    onTap: loading ? null : onTap,
    child: Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: loading
            ? ThemeColors.unifiedPrimary.withValues(alpha: 0.5)
            : ThemeColors.unifiedPrimary,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
    ),
  );
}

AppBar _formAppBar(BuildContext context, String title) => AppBar(
  backgroundColor: ThemeColors.unifiedSurface,
  elevation: 0,
  scrolledUnderElevation: 0,
  leading: IconButton(
    icon: const Icon(Icons.close_rounded, size: 20),
    onPressed: () => Navigator.of(context).pop(),
  ),
  title: Text(
    title,
    style: const TextStyle(
      fontWeight: FontWeight.w800,
      fontSize: 17,
      color: ThemeColors.unifiedTextPrimary,
    ),
  ),
  bottom: PreferredSize(
    preferredSize: const Size.fromHeight(0.5),
    child: Container(height: 0.5, color: ThemeColors.unifiedBorder),
  ),
);

Future<DateTime?> _pickDate(BuildContext ctx, DateTime? initial) =>
    showDatePicker(
      context: ctx,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: ThemeColors.unifiedPrimary,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: ThemeColors.unifiedTextPrimary,
          ),
        ),
        child: child!,
      ),
    );

void _snack(BuildContext ctx, String msg, Color color) {
  ScaffoldMessenger.of(ctx)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
}

// ══════════════════════════════════════════════════════════════════════════════
//  CREATE PROJECT SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _priority = 'medium';
  DateTime? _startDate, _endDate;
  List<DepartmentModel> _departments = [];
  List<EmployeeModel> _employees = [];
  final Set<int> _selectedDepts = {};
  final Set<int> _selectedMembers = {};
  final Set<int> _selectedObservers = {};
  bool _loadingOptions = true;
  String? _optionsError;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    setState(() {
      _loadingOptions = true;
      _optionsError = null;
    });
    try {
      final dir = await GetIt.instance
          .get<ProjectRepositoryImpl>()
          .getDirectory();
      if (!mounted) return;
      setState(() {
        _departments = dir.departments;
        _employees = dir.employees;
        _loadingOptions = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _optionsError = e.toString();
        _loadingOptions = false;
      });
    }
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _snack(context, 'Project name is required', ThemeColors.unifiedDanger);
      return;
    }
    setState(() => _submitting = true);
    context.read<ProjectBloc>().add(
      CreateProject(
        name: name,
        description: _descCtrl.text.trim(),
        priority: _priority,
        startDate: _startDate,
        endDate: _endDate,
        departmentIds: _selectedDepts.isEmpty ? null : _selectedDepts.toList(),
        memberIds: _selectedMembers.isEmpty ? null : _selectedMembers.toList(),
        observerIds: _selectedObservers.isEmpty
            ? null
            : _selectedObservers.toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.unifiedBackground,
      appBar: _formAppBar(context, ConstStrings.projectsCreate),
      body: BlocConsumer<ProjectBloc, ProjectState>(
        listener: (ctx, state) {
          if (state is ProjectActionSuccess &&
              state.message == 'Project created') {
            _snack(ctx, 'Project created!', ThemeColors.unifiedSuccess);
            Navigator.of(ctx).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const ProjectListScreen()),
              (r) => r.isFirst,
            );
          }
          if (state is ProjectActionError) {
            setState(() => _submitting = false);
            _snack(ctx, state.message, ThemeColors.unifiedDanger);
          }
        },
        builder: (ctx, state) => LayoutBuilder(
          builder: (ctx, c) => ListView(
            padding: EdgeInsets.symmetric(
              horizontal: c.maxWidth >= 768 ? 28 : 16,
              vertical: 20,
            ),
            children: [
              _FormContent(
                nameCtrl: _nameCtrl,
                descCtrl: _descCtrl,
                priority: _priority,
                startDate: _startDate,
                endDate: _endDate,
                onPriorityChanged: (v) => setState(() => _priority = v),
                onStartDateTap: () async {
                  final d = await _pickDate(context, _startDate);
                  if (d != null)
                    setState(() {
                      _startDate = d;
                      if (_endDate != null && _endDate!.isBefore(d))
                        _endDate = d.add(const Duration(days: 7));
                    });
                },
                onEndDateTap: () async {
                  final d = await _pickDate(context, _endDate);
                  if (d != null) setState(() => _endDate = d);
                },
              ),
              const SizedBox(height: 16),
              // Teams section
              if (_loadingOptions)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: ThemeColors.unifiedPrimary,
                    ),
                  ),
                )
              else if (_optionsError != null)
                _sectionCard(
                  icon: Icons.error_outline_rounded,
                  title: 'Could not load team options',
                  child: Column(
                    children: [
                      Text(
                        _optionsError!,
                        style: const TextStyle(
                          color: ThemeColors.unifiedDanger,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _loadOptions,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else ...[
                _MultiSelect(
                  icon: Icons.apartment_rounded,
                  title: 'Departments (${_selectedDepts.length})',
                  items: _departments
                      .map(
                        (d) => _MSItem(
                          id: d.id,
                          label: d.name,
                          sub: d.code,
                          selected: _selectedDepts.contains(d.id),
                          onTap: () => setState(
                            () => _selectedDepts.contains(d.id)
                                ? _selectedDepts.remove(d.id)
                                : _selectedDepts.add(d.id),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                _MultiSelect(
                  icon: Icons.people_alt_rounded,
                  title: 'Members (${_selectedMembers.length})',
                  items: _employees
                      .map(
                        (e) => _MSItem(
                          id: e.id,
                          label: e.name,
                          sub: e.deptName,
                          selected: _selectedMembers.contains(e.id),
                          onTap: () => setState(
                            () => _selectedMembers.contains(e.id)
                                ? _selectedMembers.remove(e.id)
                                : _selectedMembers.add(e.id),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                _MultiSelect(
                  icon: Icons.visibility_rounded,
                  title: 'Observers (${_selectedObservers.length})',
                  items: _employees
                      .map(
                        (e) => _MSItem(
                          id: e.id,
                          label: e.name,
                          sub: e.deptName,
                          selected: _selectedObservers.contains(e.id),
                          onTap: () => setState(
                            () => _selectedObservers.contains(e.id)
                                ? _selectedObservers.remove(e.id)
                                : _selectedObservers.add(e.id),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 24),
              _submitBtn(
                label: ConstStrings.projectsCreate,
                loading: _submitting,
                onTap: _submit,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  EDIT PROJECT SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class EditProjectScreen extends StatefulWidget {
  final ProjectModel project;
  const EditProjectScreen({super.key, required this.project});

  @override
  State<EditProjectScreen> createState() => _EditProjectScreenState();
}

class _EditProjectScreenState extends State<EditProjectScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  String _priority = 'medium';
  DateTime? _startDate, _endDate;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.project.name);
    _descCtrl = TextEditingController(text: widget.project.description);
    _priority = widget.project.priority;
    _startDate = widget.project.startDate;
    _endDate = widget.project.endDate;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _snack(context, 'Project name is required', ThemeColors.unifiedDanger);
      return;
    }
    setState(() => _submitting = true);
    context.read<ProjectBloc>().add(
      UpdateProject(
        id: widget.project.id,
        name: name,
        description: _descCtrl.text.trim(),
        priority: _priority,
        startDate: _startDate,
        endDate: _endDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.unifiedBackground,
      appBar: _formAppBar(context, ConstStrings.projectsEdit),
      body: BlocConsumer<ProjectBloc, ProjectState>(
        listener: (ctx, state) {
          if (state is ProjectActionSuccess &&
              state.message == 'Project updated') {
            _snack(ctx, 'Project updated!', ThemeColors.unifiedSuccess);
            Navigator.of(ctx).pop();
          }
          if (state is ProjectActionError) {
            setState(() => _submitting = false);
            _snack(ctx, state.message, ThemeColors.unifiedDanger);
          }
        },
        builder: (ctx, state) => LayoutBuilder(
          builder: (ctx, c) => ListView(
            padding: EdgeInsets.symmetric(
              horizontal: c.maxWidth >= 768 ? 28 : 16,
              vertical: 20,
            ),
            children: [
              _FormContent(
                nameCtrl: _nameCtrl,
                descCtrl: _descCtrl,
                priority: _priority,
                startDate: _startDate,
                endDate: _endDate,
                onPriorityChanged: (v) => setState(() => _priority = v),
                onStartDateTap: () async {
                  final d = await _pickDate(context, _startDate);
                  if (d != null)
                    setState(() {
                      _startDate = d;
                      if (_endDate != null && _endDate!.isBefore(d))
                        _endDate = d.add(const Duration(days: 7));
                    });
                },
                onEndDateTap: () async {
                  final d = await _pickDate(context, _endDate);
                  if (d != null) setState(() => _endDate = d);
                },
              ),
              const SizedBox(height: 24),
              _submitBtn(
                label: ConstStrings.projectsSaveChanges,
                loading: _submitting,
                onTap: _submit,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared form content (name / desc / priority / dates) ─────────────────────
class _FormContent extends StatelessWidget {
  final TextEditingController nameCtrl, descCtrl;
  final String priority;
  final DateTime? startDate, endDate;
  final ValueChanged<String> onPriorityChanged;
  final VoidCallback onStartDateTap, onEndDateTap;

  const _FormContent({
    required this.nameCtrl,
    required this.descCtrl,
    required this.priority,
    required this.startDate,
    required this.endDate,
    required this.onPriorityChanged,
    required this.onStartDateTap,
    required this.onEndDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _sectionCard(
          icon: Icons.badge_outlined,
          title: 'Project details',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: _fieldDeco(
                  'Project name *',
                  hint: 'e.g. ERP Automation',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: _fieldDeco(
                  'Description',
                  hint: 'Objectives and scope...',
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Priority',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.unifiedTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              _prioritySelector(priority, onPriorityChanged),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _sectionCard(
          icon: Icons.calendar_month_rounded,
          title: 'Schedule',
          child: Row(
            children: [
              Expanded(
                child: _datePicker(
                  label: 'Start date',
                  value: startDate,
                  icon: Icons.event_available_rounded,
                  onTap: onStartDateTap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _datePicker(
                  label: 'Due date',
                  value: endDate,
                  icon: Icons.event_busy_rounded,
                  onTap: onEndDateTap,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  ADD / EDIT TASK SCREEN
// ══════════════════════════════════════════════════════════════════════════════
class AddTaskScreen extends StatefulWidget {
  final int projectId;
  final String projectName;
  final List<ProjectDepartmentModel> departments;
  final List<ProjectMemberModel> members;
  final ProjectTaskModel? task;
  final bool canUpdate;

  const AddTaskScreen({
    super.key,
    required this.projectId,
    required this.projectName,
    required this.departments,
    required this.members,
    this.task,
    this.canUpdate = true,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  late final TextEditingController _titleCtrl;
  final _descCtrl = TextEditingController();
  String _priority = 'medium';
  int? _assigneeId;
  DateTime? _dueDate;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.task?.title ?? '');
    _descCtrl.text = widget.task?.description ?? '';
    _priority = widget.task?.priority ?? 'medium';
    _assigneeId = widget.task?.assignedToId;
    _dueDate = widget.task?.dueDate;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      _snack(context, 'Task title is required', ThemeColors.unifiedDanger);
      return;
    }
    setState(() => _submitting = true);
    final isEdit = widget.task != null && widget.canUpdate;
    if (isEdit) {
      context.read<ProjectBloc>().add(
        UpdateProjectTask(
          projectId: widget.projectId,
          taskId: widget.task!.id,
          title: title,
          description: _descCtrl.text.trim(),
          priority: _priority,
          assignedToId: _assigneeId,
        ),
      );
    } else {
      context.read<ProjectBloc>().add(
        AddProjectTask(
          projectId: widget.projectId,
          title: title,
          description: _descCtrl.text.trim(),
          priority: _priority,
          assignedToId: _assigneeId,
          dueDate: _dueDate,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.task != null;

    return Scaffold(
      backgroundColor: ThemeColors.unifiedBackground,
      appBar: _formAppBar(
        context,
        isEdit
            ? ConstStrings.projectsSaveTask
            : ConstStrings.projectsCreateTask,
      ),
      body: BlocConsumer<ProjectBloc, ProjectState>(
        listener: (ctx, state) {
          if (state is ProjectActionSuccess &&
              (state.message == 'Task added' ||
                  state.message == 'Task updated')) {
            if (!mounted) return;
            _snack(
              ctx,
              isEdit ? 'Task updated!' : 'Task added!',
              ThemeColors.unifiedSuccess,
            );
            Navigator.of(ctx).pop();
          }
          if (state is ProjectActionError) {
            if (!mounted) return;
            setState(() => _submitting = false);
            _snack(ctx, state.message, ThemeColors.unifiedDanger);
          }
        },
        builder: (ctx, state) => LayoutBuilder(
          builder: (ctx, c) => ListView(
            padding: EdgeInsets.symmetric(
              horizontal: c.maxWidth >= 768 ? 28 : 16,
              vertical: 20,
            ),
            children: [
              _sectionCard(
                icon: Icons.assignment_outlined,
                title: 'Task details',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ThemeColors.unifiedPrimary.withValues(
                          alpha: 0.05,
                        ),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.folder_copy_outlined,
                            size: 14,
                            color: ThemeColors.unifiedPrimary,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            'Project: ${widget.projectName}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: ThemeColors.unifiedPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _titleCtrl,
                      decoration: _fieldDeco(
                        '${ConstStrings.projectsTaskTitle} *',
                        hint: 'e.g. Implement auth API',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descCtrl,
                      maxLines: 3,
                      decoration: _fieldDeco(
                        'Description',
                        hint: 'Acceptance criteria, notes...',
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Priority',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: ThemeColors.unifiedTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _prioritySelector(
                      _priority,
                      (v) => setState(() => _priority = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _sectionCard(
                icon: Icons.person_outline_rounded,
                title: 'Assignee & schedule',
                child: Column(
                  children: [
                    DropdownButtonFormField<int?>(
                      value: _assigneeId,
                      decoration: _fieldDeco(ConstStrings.projectsAssignee),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Unassigned'),
                        ),
                        for (final m in widget.members)
                          DropdownMenuItem<int?>(
                            value: m.id,
                            child: Row(
                              children: [
                                InitialsAvatar(name: m.name, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  m.name,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (v) => setState(() => _assigneeId = v),
                    ),
                    const SizedBox(height: 12),
                    _datePicker(
                      label: ConstStrings.projectsDueDate,
                      value: _dueDate,
                      icon: Icons.event_available_rounded,
                      onTap: () async {
                        final d = await _pickDate(context, _dueDate);
                        if (d != null) setState(() => _dueDate = d);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _submitBtn(
                label: isEdit ? 'Save changes' : 'Create task',
                loading: _submitting,
                onTap: _submit,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Multi-select section ──────────────────────────────────────────────────────
class _MSItem {
  final int id;
  final String label, sub;
  final bool selected;
  final VoidCallback onTap;
  const _MSItem({
    required this.id,
    required this.label,
    required this.sub,
    required this.selected,
    required this.onTap,
  });
}

class _MultiSelect extends StatefulWidget {
  final IconData icon;
  final String title;
  final List<_MSItem> items;
  const _MultiSelect({
    required this.icon,
    required this.title,
    required this.items,
  });

  @override
  State<_MultiSelect> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<_MultiSelect> {
  final _searchCtrl = TextEditingController();
  String _q = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.items.where((i) => i.selected).toList();
    final filtered = _q.isEmpty
        ? widget.items
        : widget.items
              .where(
                (i) =>
                    i.label.toLowerCase().contains(_q.toLowerCase()) ||
                    i.sub.toLowerCase().contains(_q.toLowerCase()),
              )
              .toList();

    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ThemeColors.unifiedBorder, width: 0.8),
      ),
      clipBehavior: Clip.hardEdge,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: ThemeColors.unifiedPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              widget.icon,
              size: 16,
              color: ThemeColors.unifiedPrimary,
            ),
          ),
          title: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: ThemeColors.unifiedTextPrimary,
            ),
          ),
          subtitle: selected.isNotEmpty
              ? Text(
                  '${selected.length} selected',
                  style: const TextStyle(
                    fontSize: 11,
                    color: ThemeColors.unifiedPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : null,
          children: [
            if (selected.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: selected
                      .map(
                        (e) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: ThemeColors.unifiedPrimary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                e.label,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: ThemeColors.unifiedPrimary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: e.onTap,
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 12,
                                  color: ThemeColors.unifiedPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: TextField(
                controller: _searchCtrl,
                decoration: _fieldDeco('Search...').copyWith(
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 16,
                    color: ThemeColors.unifiedTextMuted,
                  ),
                ),
                onChanged: (v) => setState(() => _q = v),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: filtered.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No results.',
                        style: TextStyle(
                          color: ThemeColors.unifiedTextMuted,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final e = filtered[i];
                        return ListTile(
                          dense: true,
                          leading: InitialsAvatar(name: e.label, size: 26),
                          title: Text(
                            e.label,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            e.sub,
                            style: const TextStyle(
                              fontSize: 11,
                              color: ThemeColors.unifiedTextMuted,
                            ),
                          ),
                          trailing: Icon(
                            e.selected
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: e.selected
                                ? ThemeColors.unifiedPrimary
                                : ThemeColors.unifiedTextMuted,
                            size: 18,
                          ),
                          onTap: e.onTap,
                        );
                      },
                    ),
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}
