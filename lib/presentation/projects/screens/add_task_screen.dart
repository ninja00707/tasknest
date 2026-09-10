import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/projects/bloc/project_bloc.dart';
import 'package:tasknest/presentation/projects/bloc/project_event.dart';
import 'package:tasknest/presentation/projects/bloc/project_state.dart';
import 'package:tasknest/presentation/projects/model/project_models.dart';
import 'package:tasknest/presentation/projects/widgets/ui_helpers.dart';

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

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 3)),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ThemeColors.unifiedPrimary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: ThemeColors.unifiedTextPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null || !mounted) return;
    setState(() => _dueDate = picked);
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Task title is required'),
            backgroundColor: ThemeColors.unifiedDanger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      return;
    }
    setState(() => _submitting = true);
    if (widget.task != null && widget.canUpdate) {
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
      appBar: AppBar(
        backgroundColor: ThemeColors.unifiedSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEdit
              ? ConstStrings.projectsSaveTask
              : ConstStrings.projectsCreateTask,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: ThemeColors.unifiedTextPrimary,
          ),
        ),
      ),
      body: BlocConsumer<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectActionSuccess &&
              (state.message == 'Task added' ||
                  state.message == 'Task updated')) {
            if (!mounted) return;
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(isEdit ? 'Task updated!' : 'Task added!'),
                  backgroundColor: ThemeColors.unifiedSuccess,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            Navigator.of(context).pop();
          }
          if (state is ProjectActionError) {
            if (!mounted) return;
            setState(() => _submitting = false);
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: ThemeColors.unifiedDanger,
                  behavior: SnackBarBehavior.floating,
                ),
              );
          }
        },
        builder: (context, state) => LayoutBuilder(
          builder: (context, constraints) => ListView(
            padding: projectFormPadding(constraints.maxWidth),
            children: [
              ResponsivePageContainer(
                maxWidth: kProjectsFormMaxWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header card
                    SoftCard(
                      padding: const EdgeInsets.all(18),
                      radius: 16,
                      child: Row(
                        children: [
                          IconBadge(
                            icon: isEdit
                                ? Icons.edit_note_rounded
                                : Icons.task_alt_rounded,
                            size: 44,
                            color: ThemeColors.unifiedPrimary,
                            iconScale: 0.5,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isEdit
                                      ? 'Edit Task'
                                      : 'Create New Task',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: ThemeColors.unifiedTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'In project "${widget.projectName}"',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: ThemeColors.unifiedTextMuted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Task details
                    SoftCard(
                      padding: const EdgeInsets.all(18),
                      radius: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeader(
                            icon: Icons.assignment_outlined,
                            title: 'Task Details',
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _titleCtrl,
                            decoration: projectFieldDecoration(
                              '${ConstStrings.projectsTaskTitle} *',
                              hint: 'e.g. Implement customer feedback API',
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _descCtrl,
                            maxLines: 4,
                            decoration: projectFieldDecoration(
                              ConstStrings.projectsTaskDescription,
                              hint: 'Additional acceptance criteria or notes...',
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Priority',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: ThemeColors.unifiedTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildPrioritySelector(),
                          const SizedBox(height: 18),
                          const SectionHeader(
                            icon: Icons.person_outline_rounded,
                            title: 'Assignee & Schedule',
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<int?>(
                            initialValue: _assigneeId,
                            decoration: projectFieldDecoration(
                              ConstStrings.projectsAssignee,
                            ),
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
                                      InitialsAvatar(name: m.name, size: 22),
                                      const SizedBox(width: 8),
                                      Text(m.name),
                                    ],
                                  ),
                                ),
                            ],
                            onChanged: (v) => setState(() => _assigneeId = v),
                          ),
                          const SizedBox(height: 14),
                          _FormDatePicker(
                            label: ConstStrings.projectsDueDate,
                            value: _dueDate,
                            icon: Icons.event_available_rounded,
                            onTap: _pickDueDate,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit CTA
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: projectPrimaryButtonStyle(),
                        onPressed: _submitting ? null : _submit,
                        child: _submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                isEdit
                                    ? 'Save Task Changes'
                                    : 'Create Task',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    final priorities = [
      {'key': 'low', 'label': 'Low', 'color': ThemeColors.unifiedSuccess},
      {'key': 'medium', 'label': 'Medium', 'color': ThemeColors.priorityMedFg},
      {'key': 'high', 'label': 'High', 'color': ThemeColors.priorityHighFg},
      {'key': 'urgent', 'label': 'Urgent', 'color': ThemeColors.priorityUrgentFg},
    ];

    return Row(
      children: priorities.map((p) {
        final key = p['key'] as String;
        final label = p['label'] as String;
        final color = p['color'] as Color;
        final selected = _priority == key;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => setState(() => _priority = key),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? color.withValues(alpha: 0.15) : ThemeColors.unifiedInputBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected ? color : ThemeColors.unifiedBorder,
                    width: selected ? 1.8 : 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected ? color : ThemeColors.unifiedTextPrimary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FormDatePicker extends StatelessWidget {
  final String label;
  final DateTime? value;
  final IconData icon;
  final VoidCallback onTap;

  const _FormDatePicker({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: ThemeColors.unifiedInputBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ThemeColors.unifiedBorder),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: ThemeColors.unifiedPrimary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ThemeColors.unifiedTextMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value != null
                        ? DateFormat('MMM d, y').format(value!)
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: value != null
                          ? ThemeColors.unifiedTextPrimary
                          : ThemeColors.unifiedTextMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
