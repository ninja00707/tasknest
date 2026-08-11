import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/projects/bloc/project_bloc.dart';
import 'package:tasknest/presentation/projects/bloc/project_event.dart';
import 'package:tasknest/presentation/projects/bloc/project_state.dart';
import 'package:tasknest/presentation/projects/model/project_models.dart';
import 'package:tasknest/presentation/projects/widgets/UIhelpers.dart';

class AddTaskScreen extends StatefulWidget {
  final int projectId;
  final String projectName;
  final List<ProjectDepartmentModel> departments;
  final List<ProjectMemberModel> members;
  const AddTaskScreen({
    super.key,
    required this.projectId,
    required this.projectName,
    required this.departments,
    required this.members,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _priority = 'medium';
  int? _assigneeId;
  DateTime? _dueDate;
  bool _submitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => _dueDate = picked);
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Task title is required')));
      return;
    }
    setState(() => _submitting = true);
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
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.unifiedInputBg.withValues(alpha: 0.35),
      appBar: AppBar(
        backgroundColor: ThemeColors.unifiedSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          ConstStrings.projectsCreateTask,
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: BlocConsumer<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectActionSuccess && state.message == 'Task added') {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: const Text('Task added'),
                  backgroundColor: ThemeColors.unifiedSuccess,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
          }
          if (state is ProjectActionError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message)));
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
                    if (widget.departments.isNotEmpty) ...[
                      SoftCard(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.apartment_rounded,
                                  size: 15,
                                  color: ThemeColors.unifiedTextMuted,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${ConstStrings.projectsDepartments} • ${widget.projectName}',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: ThemeColors.unifiedTextMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final d in widget.departments)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 11,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: ThemeColors.statusOpenBg,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      d.name,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: ThemeColors.statusOpenFg,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    SoftCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _titleCtrl,
                            decoration: projectFieldDecoration(
                              ConstStrings.projectsTaskTitle,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _descCtrl,
                            maxLines: 4,
                            decoration: projectFieldDecoration(
                              ConstStrings.projectsTaskDescription,
                            ),
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            initialValue: _priority,
                            decoration: projectFieldDecoration(
                              ConstStrings.projectsPriority,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'low',
                                child: Text('Low'),
                              ),
                              DropdownMenuItem(
                                value: 'medium',
                                child: Text('Medium'),
                              ),
                              DropdownMenuItem(
                                value: 'high',
                                child: Text('High'),
                              ),
                              DropdownMenuItem(
                                value: 'urgent',
                                child: Text('Urgent'),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => _priority = v ?? 'medium'),
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
                                  child: Text(m.name),
                                ),
                            ],
                            onChanged: (v) => setState(() => _assigneeId = v),
                          ),
                          const SizedBox(height: 14),
                          InkWell(
                            onTap: _pickDueDate,
                            borderRadius: BorderRadius.circular(12),
                            child: InputDecorator(
                              decoration: projectFieldDecoration(
                                ConstStrings.projectsDueDate,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 15,
                                    color: _dueDate == null
                                        ? ThemeColors.unifiedTextMuted
                                        : ThemeColors.unifiedPrimary,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _dueDate == null
                                          ? 'Not set'
                                          : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: _dueDate == null
                                            ? ThemeColors.unifiedTextMuted
                                            : ThemeColors.unifiedTextPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: projectPrimaryButtonStyle(),
                        onPressed: _submitting ? null : _submit,
                        child: Text(
                          _submitting
                              ? 'Saving…'
                              : ConstStrings.projectsSaveTask,
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
}
