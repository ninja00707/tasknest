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
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = _startDate!.add(const Duration(days: 7));
        }
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
          const SnackBar(
            content: Text('Project name is required'),
            backgroundColor: ThemeColors.unifiedDanger,
            behavior: SnackBarBehavior.floating,
          ),
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
      backgroundColor: ThemeColors.unifiedBackground,
      appBar: AppBar(
        backgroundColor: ThemeColors.unifiedSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          ConstStrings.projectsEdit,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: ThemeColors.unifiedTextPrimary,
          ),
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
                  content: const Text('Project updated successfully!'),
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
                            icon: Icons.edit_note_rounded,
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
                                  'Edit "${widget.project.name}"',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: ThemeColors.unifiedTextPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                if (widget.project.projectCode.isNotEmpty)
                                  Text(
                                    'Code: ${widget.project.projectCode}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: ThemeColors.unifiedTextMuted,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Section: Details & Priority
                    SoftCard(
                      padding: const EdgeInsets.all(18),
                      radius: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeader(
                            icon: Icons.edit_rounded,
                            title: 'Project Information',
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _nameCtrl,
                            decoration: projectFieldDecoration(
                              '${ConstStrings.projectsName} *',
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
                          const SizedBox(height: 16),
                          const Text(
                            'Project Priority',
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
                            icon: Icons.calendar_month_rounded,
                            title: 'Schedule Dates',
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _FormDatePicker(
                                  label: ConstStrings.projectsStartDate,
                                  value: _startDate,
                                  icon: Icons.event_available_rounded,
                                  onTap: () => _pickDate(isStart: true),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _FormDatePicker(
                                  label: ConstStrings.projectsEndDate,
                                  value: _endDate,
                                  icon: Icons.event_busy_rounded,
                                  onTap: () => _pickDate(isStart: false),
                                ),
                              ),
                            ],
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
                            : const Text(
                                ConstStrings.projectsSaveChanges,
                                style: TextStyle(
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
