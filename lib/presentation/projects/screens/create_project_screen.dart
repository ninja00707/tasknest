import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/domain/repositories_impl/ticket_impl/ticket_impl.dart';
import 'package:tasknest/presentation/projects/bloc/project_bloc.dart';
import 'package:tasknest/presentation/projects/bloc/project_event.dart';
import 'package:tasknest/presentation/projects/bloc/project_state.dart';
import 'package:tasknest/presentation/projects/screens/project_list_screen.dart';
import 'package:tasknest/presentation/projects/widgets/ui_helpers.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _ticketRepo = GetIt.instance.get<TicketRepositoryImpl>();
  String _priority = 'medium';
  DateTime? _startDate;
  DateTime? _endDate;

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
      final depts = await _ticketRepo.getDepartments();
      final employees = await _ticketRepo.getEmployees();
      if (!mounted) return;
      setState(() {
        _departments = depts;
        _employees = employees;
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

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now().add(const Duration(days: 14)));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
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
            content: Text('Please provide a project name'),
            backgroundColor: ThemeColors.unifiedDanger,
            behavior: SnackBarBehavior.floating,
          ),
        );
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
            departmentIds:
                _selectedDepts.isEmpty ? null : _selectedDepts.toList(),
            memberIds: _selectedMembers.isEmpty
                ? null
                : _selectedMembers.toList(),
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
      appBar: AppBar(
        backgroundColor: ThemeColors.unifiedSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          ConstStrings.projectsCreate,
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
              state.message == 'Project created') {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: const Text('Project created successfully!'),
                  backgroundColor: ThemeColors.unifiedSuccess,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const ProjectListScreen()),
              (route) => route.isFirst,
            );
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
                            icon: Icons.create_new_folder_rounded,
                            size: 44,
                            color: ThemeColors.unifiedPrimary,
                            iconScale: 0.5,
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'New Project Workspace',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: ThemeColors.unifiedTextPrimary,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Define milestones, assign cross-functional teams, and track delivery.',
                                  style: TextStyle(
                                    fontSize: 12.5,
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

                    // Section 1: Essentials
                    SoftCard(
                      padding: const EdgeInsets.all(18),
                      radius: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeader(
                            icon: Icons.badge_outlined,
                            title: 'Project Essentials',
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _nameCtrl,
                            decoration: projectFieldDecoration(
                              '${ConstStrings.projectsName} *',
                              hint: 'e.g. ERP Automation Migration',
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _descCtrl,
                            maxLines: 3,
                            decoration: projectFieldDecoration(
                              ConstStrings.projectsDescription,
                              hint: 'Brief summary of objectives, deliverables, and scope...',
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Section 2: Schedule & Dates
                    SoftCard(
                      padding: const EdgeInsets.all(18),
                      radius: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionHeader(
                            icon: Icons.calendar_month_rounded,
                            title: 'Schedule & Target Dates',
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _FormDatePicker(
                                  label: 'Start Date',
                                  value: _startDate,
                                  icon: Icons.event_available_rounded,
                                  onTap: () => _pickDate(isStart: true),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _FormDatePicker(
                                  label: 'Target Due Date',
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
                    const SizedBox(height: 18),

                    // Section 3: Teams & Access
                    if (_loadingOptions)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: ThemeColors.unifiedPrimary,
                          ),
                        ),
                      )
                    else if (_optionsError != null)
                      SoftCard(
                        radius: 16,
                        child: Column(
                          children: [
                            Text(
                              _optionsError!,
                              style: const TextStyle(
                                color: ThemeColors.unifiedDanger,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _loadOptions,
                              child: const Text('Retry loading teams'),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      _MultiSelectSection(
                        icon: Icons.apartment_rounded,
                        title: '${ConstStrings.projectsDepartments} (${_selectedDepts.length})',
                        allItems: _departments
                            .map(
                              (d) => _SelectEntry(
                                id: d.id,
                                label: d.name,
                                subtitle: d.code,
                                selected: _selectedDepts.contains(d.id),
                                onTap: () {
                                  setState(() {
                                    _selectedDepts.contains(d.id)
                                        ? _selectedDepts.remove(d.id)
                                        : _selectedDepts.add(d.id);
                                  });
                                },
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 14),
                      _MultiSelectSection(
                        icon: Icons.people_alt_rounded,
                        title: '${ConstStrings.projectsMembers} (${_selectedMembers.length})',
                        allItems: _employees
                            .map(
                              (e) => _SelectEntry(
                                id: e.id,
                                label: e.name,
                                subtitle: e.deptName,
                                selected: _selectedMembers.contains(e.id),
                                onTap: () {
                                  setState(() {
                                    _selectedMembers.contains(e.id)
                                        ? _selectedMembers.remove(e.id)
                                        : _selectedMembers.add(e.id);
                                  });
                                },
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 14),
                      _MultiSelectSection(
                        icon: Icons.visibility_rounded,
                        title: '${ConstStrings.projectsObservers} (${_selectedObservers.length})',
                        allItems: _employees
                            .map(
                              (e) => _SelectEntry(
                                id: e.id,
                                label: e.name,
                                subtitle: e.deptName,
                                selected: _selectedObservers.contains(e.id),
                                onTap: () {
                                  setState(() {
                                    _selectedObservers.contains(e.id)
                                        ? _selectedObservers.remove(e.id)
                                        : _selectedObservers.add(e.id);
                                  });
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 26),

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
                                ConstStrings.projectsCreate,
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

class _SelectEntry {
  final int id;
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  const _SelectEntry({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });
}

class _MultiSelectSection extends StatefulWidget {
  final IconData icon;
  final String title;
  final List<_SelectEntry> allItems;

  const _MultiSelectSection({
    required this.icon,
    required this.title,
    required this.allItems,
  });

  @override
  State<_MultiSelectSection> createState() => _MultiSelectSectionState();
}

class _MultiSelectSectionState extends State<_MultiSelectSection> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty
        ? widget.allItems
        : widget.allItems
            .where(
              (e) =>
                  e.label.toLowerCase().contains(_query.toLowerCase()) ||
                  e.subtitle.toLowerCase().contains(_query.toLowerCase()),
            )
            .toList();

    final selectedItems = widget.allItems.where((e) => e.selected).toList();

    return SoftCard(
      padding: EdgeInsets.zero,
      radius: 16,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          leading: Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ThemeColors.unifiedPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              widget.icon,
              size: 18,
              color: ThemeColors.unifiedPrimary,
            ),
          ),
          title: Text(
            widget.title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: ThemeColors.unifiedTextPrimary,
            ),
          ),
          subtitle: selectedItems.isNotEmpty
              ? Text(
                  '${selectedItems.length} selected',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.unifiedPrimary,
                  ),
                )
              : null,
          children: [
            // Selected tags row
            if (selectedItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: selectedItems.map((entry) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: ThemeColors.unifiedPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            entry.label,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: ThemeColors.unifiedPrimary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: entry.onTap,
                            child: const Icon(
                              Icons.close_rounded,
                              size: 13,
                              color: ThemeColors.unifiedPrimary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

            // Search box
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Search options...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: ThemeColors.unifiedTextMuted,
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: ThemeColors.unifiedInputBg,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            if (filtered.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No results match search.',
                  style: TextStyle(color: ThemeColors.unifiedTextMuted, fontSize: 12.5),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 250),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final entry = filtered[i];
                    return ListTile(
                      dense: true,
                      leading: InitialsAvatar(name: entry.label, size: 28),
                      title: Text(
                        entry.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        entry.subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: ThemeColors.unifiedTextMuted,
                        ),
                      ),
                      trailing: entry.selected
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: ThemeColors.unifiedPrimary,
                              size: 20,
                            )
                          : const Icon(
                              Icons.radio_button_unchecked_rounded,
                              color: ThemeColors.unifiedTextMuted,
                              size: 20,
                            ),
                      onTap: entry.onTap,
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
