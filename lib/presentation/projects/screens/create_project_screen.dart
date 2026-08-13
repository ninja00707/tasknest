import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
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
          CreateProject(
            name: name,
            description: _descCtrl.text.trim(),
            priority: _priority,
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
      backgroundColor: ThemeColors.unifiedInputBg.withValues(alpha: 0.35),
      appBar: AppBar(
        backgroundColor: ThemeColors.unifiedSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          ConstStrings.projectsCreate,
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
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
                  content: const Text('Project created'),
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
                      icon: Icons.add_rounded,
                      title: ConstStrings.projectsCreate,
                      subtitle:
                          'Fill in the project details below to create a new project.',
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
                            decoration: projectFieldDecoration(
                              ConstStrings.projectsPriority,
                            ),
                            items: const [
                              DropdownMenuItem(value: 'low', child: Text('Low')),
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (_loadingOptions)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      )
                    else if (_optionsError != null)
                      SoftCard(
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
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      _MultiSelectSection(
                        icon: Icons.apartment_rounded,
                        title:
                            '${ConstStrings.projectsDepartments} (${_selectedDepts.length})',
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
                      const SizedBox(height: 12),
                      _MultiSelectSection(
                        icon: Icons.people_alt_rounded,
                        title:
                            '${ConstStrings.projectsMembers} (${_selectedMembers.length})',
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
                      const SizedBox(height: 12),
                      _MultiSelectSection(
                        icon: Icons.visibility_rounded,
                        title:
                            '${ConstStrings.projectsObservers} (${_selectedObservers.length})',
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
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: projectPrimaryButtonStyle(),
                        onPressed: _submitting ? null : _submit,
                        child: Text(
                          _submitting ? 'Creating…' : ConstStrings.projectsCreate,
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

    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.unifiedBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          leading: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ThemeColors.unifiedPrimary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              widget.icon,
              size: 17,
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
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: ThemeColors.unifiedTextMuted,
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: ThemeColors.unifiedInputBg,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: ThemeColors.unifiedPrimary,
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            if (filtered.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No results found.',
                  style: TextStyle(color: ThemeColors.unifiedTextMuted),
                ),
              )
            else
              ...filtered.map(
                (entry) => ListTile(
                  dense: true,
                  leading: InitialsAvatar(name: entry.label, size: 28),
                  title: Text(
                    entry.label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                  subtitle: Text(
                    entry.subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: ThemeColors.unifiedTextMuted,
                    ),
                  ),
                  trailing: entry.selected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: ThemeColors.unifiedPrimary,
                        )
                      : const Icon(
                          Icons.radio_button_unchecked_rounded,
                          color: ThemeColors.unifiedTextMuted,
                        ),
                  onTap: entry.onTap,
                ),
              ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
