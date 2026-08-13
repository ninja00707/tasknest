import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/projects/bloc/project_bloc.dart';
import 'package:tasknest/presentation/projects/bloc/project_event.dart';
import 'package:tasknest/presentation/projects/bloc/project_state.dart';
import 'package:tasknest/presentation/projects/model/project_models.dart';
import 'package:tasknest/presentation/projects/widgets/ui_helpers.dart';

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
  DateTime? _startDate;
  DateTime? _endDate;
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

  Future<void> _pickDate({required bool isStart}) async {
    final first = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: first ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Project name is required')),
        );
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
      backgroundColor: ThemeColors.unifiedInputBg.withValues(alpha: 0.35),
      appBar: AppBar(
        backgroundColor: ThemeColors.unifiedSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          ConstStrings.projectsEdit,
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: BlocConsumer<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectActionSuccess &&
              state.message == 'Project updated') {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: const Text('Project updated'),
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
            setState(() => _submitting = false);
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
                    _FormHeader(
                      icon: Icons.edit_outlined,
                      title: ConstStrings.projectsEdit,
                      subtitle: 'Editing "${widget.project.name}"',
                    ),
                    const SizedBox(height: 20),
                    SoftCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _nameCtrl,
                            decoration: projectFieldDecoration(
                              ConstStrings.projectsName,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _descCtrl,
                            maxLines: 4,
                            decoration: projectFieldDecoration(
                              ConstStrings.projectsDescription,
                            ),
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            initialValue: _priority,
                            decoration:
                                projectFieldDecoration(ConstStrings.projectsPriority),
                            items: const [
                              DropdownMenuItem(
                                  value: 'low', child: Text('Low')),
                              DropdownMenuItem(
                                  value: 'medium', child: Text('Medium')),
                              DropdownMenuItem(
                                  value: 'high', child: Text('High')),
                              DropdownMenuItem(
                                  value: 'urgent', child: Text('Urgent')),
                            ],
                            onChanged: (v) =>
                                setState(() => _priority = v ?? 'medium'),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _DateField(
                                  label: ConstStrings.projectsStartDate,
                                  value: _startDate,
                                  onTap: () => _pickDate(isStart: true),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _DateField(
                                  label: ConstStrings.projectsEndDate,
                                  value: _endDate,
                                  onTap: () => _pickDate(isStart: false),
                                ),
                              ),
                            ],
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
                              : ConstStrings.projectsSaveChanges,
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

class _FormHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _FormHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ThemeColors.unifiedPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: ThemeColors.unifiedPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: ThemeColors.unifiedTextPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: ThemeColors.unifiedTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: projectFieldDecoration(label),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 15,
              color: value == null
                  ? ThemeColors.unifiedTextMuted
                  : ThemeColors.unifiedPrimary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value == null
                    ? 'Not set'
                    : '${value!.day}/${value!.month}/${value!.year}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: value == null
                      ? ThemeColors.unifiedTextMuted
                      : ThemeColors.unifiedTextPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
