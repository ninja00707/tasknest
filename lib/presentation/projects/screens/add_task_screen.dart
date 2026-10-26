import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tasknest/core/constant/common_status.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/domain/repositories_impl/ticket_impl/ticket_impl.dart';
import 'package:tasknest/injection.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/projects/model/project_models.dart';
import 'package:tasknest/presentation/projects/widgets/ui_helpers.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

/// Trello-style "Add task" screen for the project module.
///
/// Completely separate from the ticket workflow screen: no multi-department
/// picker, no project link, no employee assignment. A task is created with a
/// title, description, priority, due date, a starting list (To Do / In
/// Progress / Done) and its team members — straight onto the project board
/// as `UMP-TA-000…`.
class AddTaskScreen extends StatefulWidget {
  final UserModel user;
  final int projectId;
  final String projectName;
  final List<ProjectMemberModel> projectTeam;

  /// The list the card should land in ('open' | 'in_progress' | 'closed').
  final String initialStatus;

  const AddTaskScreen({
    super.key,
    required this.user,
    required this.projectId,
    required this.projectName,
    this.projectTeam = const [],
    this.initialStatus = 'open',
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  static const Map<String, String> _listNames = {
    'open': 'To Do',
    'in_progress': 'In Progress',
    'closed': 'Done',
  };

  late final TextEditingController _titleCtrl;
  final _descCtrl = TextEditingController();
  final _memberSearch = TextEditingController();

  String _priority = 'medium';
  String _status = 'open';
  DateTime? _dueDate;

  List<TicketMemberModel> _candidates = [];
  final List<TicketMemberModel> _selected = [];
  bool _loadingCandidates = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _status = _listNames.containsKey(widget.initialStatus)
        ? widget.initialStatus
        : 'open';
    _loadCandidates();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _memberSearch.dispose();
    super.dispose();
  }

  /// Candidate pool = the project team + (for managers/CEOs) the employee
  /// directory. A 403 from the directory is quietly ignored.
  Future<void> _loadCandidates() async {
    setState(() => _loadingCandidates = true);
    final byId = <int, TicketMemberModel>{};

    for (final m in widget.projectTeam) {
      byId[m.id] = TicketMemberModel(
        id: m.id,
        name: m.name,
        deptCode: m.code,
        deptName: m.departmentName,
      );
    }

    try {
      final employees = await sl<TicketRepositoryImpl>().getEmployees();
      for (final e in employees) {
        byId[e.id] = TicketMemberModel(
          id: e.id,
          name: e.name,
          deptCode: e.deptCode,
          deptName: e.deptName,
        );
      }
    } catch (_) {
      // Not a manager / CEO — the project team is the pool.
    }

    if (!mounted) return;
    setState(() {
      _candidates = byId.values.toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      _loadingCandidates = false;
    });
  }

  bool _isSelected(TicketMemberModel m) => _selected.any((e) => e.id == m.id);

  void _toggleMember(TicketMemberModel m) {
    setState(() {
      if (_isSelected(m)) {
        _selected.removeWhere((e) => e.id == m.id);
      } else {
        _selected.add(m);
      }
    });
  }

  List<TicketMemberModel> get _filteredCandidates {
    final q = _memberSearch.text.trim().toLowerCase();
    if (q.isEmpty) return _candidates;
    return _candidates
        .where((m) =>
            m.name.toLowerCase().contains(q) ||
            m.deptCode.toLowerCase().contains(q) ||
            m.deptName.toLowerCase().contains(q))
        .toList();
  }

  String _dateIso(DateTime d) =>
      DateTime(d.year, d.month, d.day).toIso8601String().split('T').first;

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

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: ThemeColors.unifiedDanger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  String _friendlyError(Object e) {
    final raw = e.toString();
    final match = RegExp(r'Exception\((.*)\)', dotAll: true).firstMatch(raw);
    final message = match != null ? match.group(1)! : raw;
    return message.isEmpty ? 'The task could not be added.' : message;
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final description = _descCtrl.text.trim();
    if (title.isEmpty) {
      _showError('Task title is required');
      return;
    }
    if (description.isEmpty) {
      _showError('A short description is required');
      return;
    }

    setState(() => _submitting = true);
    try {
      final task = await sl<TicketRepositoryImpl>().createProjectTask(
        title: title,
        description: description,
        projectId: widget.projectId,
        assignedDeptId: widget.user.departmentId,
        priority: _priority,
        dueDate: _dueDate != null ? _dateIso(_dueDate!) : null,
        status: _status,
        memberIds: _selected.map((m) => m.id).toList(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              task.ticketNumber.isNotEmpty
                  ? 'Task ${task.ticketNumber} added!'
                  : 'Task added!',
            ),
            backgroundColor: ThemeColors.unifiedSuccess,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      Navigator.of(context).pop(task.id);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      _showError(_friendlyError(e));
    }
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
          'Add task',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: ThemeColors.unifiedTextPrimary,
          ),
        ),
      ),
      body: LayoutBuilder(
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
                        const IconBadge(
                          icon: Icons.add_task_rounded,
                          size: 44,
                          color: ThemeColors.unifiedPrimary,
                          iconScale: 0.5,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Add a new task',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: ThemeColors.unifiedTextPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'In project "${widget.projectName}" · Trello board',
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
                            'Task title *',
                            hint: 'e.g. Design the new pricing page',
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _descCtrl,
                          maxLines: 4,
                          decoration: projectFieldDecoration(
                            'Description *',
                            hint: 'What needs to be done, and how do we know it is done?',
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // List & schedule
                  SoftCard(
                    padding: const EdgeInsets.all(18),
                    radius: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(
                          icon: Icons.view_column_outlined,
                          title: 'Add to list',
                        ),
                        const SizedBox(height: 14),
                        _buildListSelector(),
                        const SizedBox(height: 6),
                        Text(
                          'The card will appear in "${_listNames[_status]}" on the board.',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: ThemeColors.unifiedTextMuted,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _FormDatePicker(
                          label: 'Due date',
                          value: _dueDate,
                          icon: Icons.event_available_rounded,
                          onTap: _pickDueDate,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Team members
                  SoftCard(
                    padding: const EdgeInsets.all(18),
                    radius: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          icon: Icons.groups_outlined,
                          title: 'Team members',
                          trailing: Text(
                            '${_selected.length} selected',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: ThemeColors.unifiedTextMuted,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _memberSearch,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(fontSize: 13),
                          decoration: projectFieldDecoration(
                            'Search people…',
                            hint: 'Name or department',
                          ).copyWith(
                            prefixIcon: const Icon(Icons.search_rounded, size: 18),
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_loadingCandidates)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: ThemeColors.unifiedPrimary,
                                ),
                              ),
                            ),
                          )
                        else if (_candidates.isEmpty)
                          const Text(
                            'No team members found yet.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: ThemeColors.unifiedTextMuted,
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final m in _filteredCandidates)
                                _MemberChip(
                                  member: m,
                                  selected: _isSelected(m),
                                  onTap: () => _toggleMember(m),
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
                              'Add task',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
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
                  color: selected
                      ? color.withValues(alpha: 0.15)
                      : ThemeColors.unifiedInputBg,
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

  Widget _buildListSelector() {
    return Row(
      children: [
        for (final status in _listNames.keys) ...[
          Expanded(
            child: Builder(
              builder: (context) {
                final selected = _status == status;
                final color = CommonStatus.columnColor(status);
                return InkWell(
                  onTap: () => setState(() => _status = status),
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: selected
                          ? color.withValues(alpha: 0.14)
                          : ThemeColors.unifiedInputBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? color : ThemeColors.unifiedBorder,
                        width: selected ? 1.8 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 8, color: color),
                        const SizedBox(width: 6),
                        Text(
                          _listNames[status]!,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight:
                                selected ? FontWeight.w800 : FontWeight.w600,
                            color: selected
                                ? color
                                : ThemeColors.unifiedTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (status != 'closed') const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _MemberChip extends StatelessWidget {
  final TicketMemberModel member;
  final bool selected;
  final VoidCallback onTap;

  const _MemberChip({
    required this.member,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? ThemeColors.unifiedPrimary.withValues(alpha: 0.12)
              : ThemeColors.unifiedInputBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? ThemeColors.unifiedPrimary : ThemeColors.unifiedBorder,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InitialsAvatar(name: member.name, size: 22),
            const SizedBox(width: 7),
            Text(
              member.name,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: ThemeColors.unifiedTextPrimary,
              ),
            ),
            if (selected) ...[
              const SizedBox(width: 5),
              const Icon(
                Icons.check_circle_rounded,
                size: 14,
                color: ThemeColors.unifiedPrimary,
              ),
            ],
          ],
        ),
      ),
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
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 18, color: ThemeColors.unifiedTextMuted),
          ],
        ),
      ),
    );
  }
}
