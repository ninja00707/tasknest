import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/projects/bloc/project_bloc.dart';
import 'package:tasknest/presentation/projects/bloc/project_event.dart';
import 'package:tasknest/presentation/projects/bloc/project_state.dart';
import 'package:tasknest/presentation/projects/model/project_models.dart';
import 'package:tasknest/presentation/projects/screens/create_project_screen.dart';
import 'package:tasknest/presentation/projects/screens/project_detail_screen.dart';
import 'package:tasknest/presentation/projects/widgets/ui_helpers.dart';

const List<List<Color>> kProjectPalettes = [
  [Color(0xFF1E3C72), Color(0xFF2A5298)],
  [Color(0xFF134E5E), Color(0xFF71B280)],
  [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
  [Color(0xFF614385), Color(0xFF516395)],
  [Color(0xFF834D9B), Color(0xFFD04ED6)],
  [Color(0xFF1F4037), Color(0xFF99F2C8)],
  [Color(0xFF4B6CB7), Color(0xFF182848)],
  [Color(0xFFBA8B02), Color(0xFF181818)],
];

enum ProjectViewMode { grid, list }

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  int _tab = 0;
  List<ProjectModel>? _lastProjects;
  final _searchCtrl = TextEditingController();
  String _query = '';
  String _priorityFilter = 'all';
  ProjectViewMode _viewMode = ProjectViewMode.grid;

  static const _scopes = [null, 'observed', 'mine'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async =>
      context.read<ProjectBloc>().add(LoadProjects(scope: _scopes[_tab]));

  void _navigateToCreate() => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const CreateProjectScreen()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.unifiedBackground,
      appBar: _buildAppBar(),
      body: BlocConsumer<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectListLoaded) _lastProjects = state.projects;
          if (state is ProjectActionSuccess) {
            _showSnack(context, state.message, ThemeColors.unifiedSuccess);
            _load();
          }
          if (state is ProjectActionError) {
            _showSnack(context, state.message, ThemeColors.unifiedDanger);
          }
        },
        builder: (context, state) {
          if (state is ProjectLoading && _lastProjects == null) {
            return const _FullScreenLoader(message: 'Loading projects...');
          }

          final all = state is ProjectListLoaded
              ? state.projects
              : _lastProjects ?? const <ProjectModel>[];

          final filtered = all.where((p) {
            final q = _query.toLowerCase();
            final matchQ =
                q.isEmpty ||
                p.name.toLowerCase().contains(q) ||
                p.projectCode.toLowerCase().contains(q) ||
                p.departments.any((d) => d.name.toLowerCase().contains(q));
            final matchP =
                _priorityFilter == 'all' ||
                p.priority.toLowerCase() == _priorityFilter;
            return matchQ && matchP;
          }).toList();

          return RefreshIndicator(
            onRefresh: _load,
            color: ThemeColors.unifiedPrimary,
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                final isWide = constraints.maxWidth >= 768;
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 28 : 16,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _KpiStrip(projects: all, isWide: isWide),
                      const SizedBox(height: 18),
                      _ControlsBar(
                        tab: _tab,
                        query: _query,
                        searchCtrl: _searchCtrl,
                        priorityFilter: _priorityFilter,
                        viewMode: _viewMode,
                        totalFiltered: filtered.length,
                        onTabChanged: (t) {
                          setState(() => _tab = t);
                          _load();
                        },
                        onQueryChanged: (v) => setState(() => _query = v),
                        onPriorityChanged: (v) =>
                            setState(() => _priorityFilter = v),
                        onViewModeChanged: (m) => setState(() => _viewMode = m),
                        onClearSearch: () {
                          _searchCtrl.clear();
                          setState(() {
                            _query = '';
                            _priorityFilter = 'all';
                          });
                        },
                      ),
                      const SizedBox(height: 18),
                      if (all.isEmpty)
                        _EmptyState(onCreate: _navigateToCreate)
                      else if (filtered.isEmpty)
                        _NoResults(
                          query: _query,
                          onClear: () {
                            _searchCtrl.clear();
                            setState(() {
                              _query = '';
                              _priorityFilter = 'all';
                            });
                          },
                        )
                      else if (_viewMode == ProjectViewMode.grid)
                        _ProjectGrid(projects: filtered)
                      else
                        _ProjectList(projects: filtered),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: ThemeColors.unifiedSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, size: 20),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: ThemeColors.unifiedPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.folder_special_rounded,
              size: 16,
              color: ThemeColors.unifiedPrimary,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            ConstStrings.projectsTitle,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: ThemeColors.unifiedTextPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, size: 20),
          onPressed: _load,
          tooltip: 'Refresh',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: _PrimaryButton(
            label: 'New project',
            icon: Icons.add_rounded,
            onTap: _navigateToCreate,
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 0.5, color: ThemeColors.unifiedBorder),
      ),
    );
  }

  void _showSnack(BuildContext ctx, String msg, Color color) {
    ScaffoldMessenger.of(ctx)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }
}

// ── KPI strip ─────────────────────────────────────────────────────────────────
class _KpiStrip extends StatelessWidget {
  final List<ProjectModel> projects;
  final bool isWide;
  const _KpiStrip({required this.projects, required this.isWide});

  @override
  Widget build(BuildContext context) {
    final total = projects.length;
    final inProg = projects
        .where((p) => p.progress > 0 && p.progress < 100)
        .length;
    final done = projects.where((p) => p.progress >= 100).length;
    final high = projects
        .where((p) => p.priority == 'urgent' || p.priority == 'high')
        .length;

    final cards = [
      _KpiData(
        'Total',
        '$total',
        Icons.folder_copy_outlined,
        ThemeColors.unifiedPrimary,
      ),
      _KpiData(
        'In progress',
        '$inProg',
        Icons.sync_rounded,
        ThemeColors.unifiedWarning,
      ),
      _KpiData(
        'Completed',
        '$done',
        Icons.task_alt_rounded,
        ThemeColors.unifiedSuccess,
      ),
      _KpiData(
        'High priority',
        '$high',
        Icons.flag_rounded,
        ThemeColors.unifiedDanger,
      ),
    ];

    if (isWide) {
      return Row(
        children: cards
            .asMap()
            .entries
            .map(
              (e) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: e.key < 3 ? 12 : 0),
                  child: _KpiCard(data: e.value),
                ),
              ),
            )
            .toList(),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _KpiCard(data: cards[0])),
            const SizedBox(width: 10),
            Expanded(child: _KpiCard(data: cards[1])),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _KpiCard(data: cards[2])),
            const SizedBox(width: 10),
            Expanded(child: _KpiCard(data: cards[3])),
          ],
        ),
      ],
    );
  }
}

class _KpiData {
  final String label, value;
  final IconData icon;
  final Color color;
  const _KpiData(this.label, this.value, this.icon, this.color);
}

class _KpiCard extends StatelessWidget {
  final _KpiData data;
  const _KpiCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.unifiedBorder, width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(data.icon, size: 18, color: data.color),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: data.color,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                data.label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: ThemeColors.unifiedTextMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Controls bar ──────────────────────────────────────────────────────────────
class _ControlsBar extends StatelessWidget {
  final int tab;
  final String query, priorityFilter;
  final TextEditingController searchCtrl;
  final ProjectViewMode viewMode;
  final int totalFiltered;
  final ValueChanged<int> onTabChanged;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onPriorityChanged;
  final ValueChanged<ProjectViewMode> onViewModeChanged;
  final VoidCallback onClearSearch;

  const _ControlsBar({
    required this.tab,
    required this.query,
    required this.priorityFilter,
    required this.searchCtrl,
    required this.viewMode,
    required this.totalFiltered,
    required this.onTabChanged,
    required this.onQueryChanged,
    required this.onPriorityChanged,
    required this.onViewModeChanged,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ThemeColors.unifiedBorder, width: 0.8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _ScopePill(
                        label: 'All projects',
                        selected: tab == 0,
                        onTap: () => onTabChanged(0),
                      ),
                      const SizedBox(width: 6),
                      _ScopePill(
                        label: 'Observed',
                        selected: tab == 1,
                        onTap: () => onTabChanged(1),
                      ),
                      const SizedBox(width: 6),
                      _ScopePill(
                        label: 'My projects',
                        selected: tab == 2,
                        onTap: () => onTabChanged(2),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _ViewToggle(mode: viewMode, onChanged: onViewModeChanged),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchCtrl,
                  onChanged: onQueryChanged,
                  style: const TextStyle(
                    fontSize: 13,
                    color: ThemeColors.unifiedTextPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by name, code or department...',
                    hintStyle: const TextStyle(
                      fontSize: 12,
                      color: ThemeColors.unifiedTextMuted,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 17,
                      color: ThemeColors.unifiedTextMuted,
                    ),
                    suffixIcon: query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 15,
                              color: ThemeColors.unifiedTextMuted,
                            ),
                            onPressed: onClearSearch,
                          )
                        : null,
                    isDense: true,
                    filled: true,
                    fillColor: ThemeColors.unifiedInputBg,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: ThemeColors.unifiedInputBg,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: priorityFilter,
                    icon: const Icon(
                      Icons.tune_rounded,
                      size: 15,
                      color: ThemeColors.unifiedTextMuted,
                    ),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: ThemeColors.unifiedTextPrimary,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All')),
                      DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                      DropdownMenuItem(value: 'high', child: Text('High')),
                      DropdownMenuItem(value: 'medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'low', child: Text('Low')),
                    ],
                    onChanged: (v) {
                      if (v != null) onPriorityChanged(v);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '$totalFiltered ${totalFiltered == 1 ? 'project' : 'projects'} showing',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: ThemeColors.unifiedTextMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScopePill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ScopePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? ThemeColors.unifiedPrimary
              : ThemeColors.unifiedInputBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.white : ThemeColors.unifiedTextPrimary,
          ),
        ),
      ),
    );
  }
}

class _ViewToggle extends StatelessWidget {
  final ProjectViewMode mode;
  final ValueChanged<ProjectViewMode> onChanged;
  const _ViewToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedInputBg,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          _VBtn(
            icon: Icons.grid_view_rounded,
            active: mode == ProjectViewMode.grid,
            onTap: () => onChanged(ProjectViewMode.grid),
          ),
          _VBtn(
            icon: Icons.view_list_rounded,
            active: mode == ProjectViewMode.list,
            onTap: () => onChanged(ProjectViewMode.list),
          ),
        ],
      ),
    );
  }
}

class _VBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _VBtn({required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: active ? ThemeColors.unifiedSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 15,
          color: active
              ? ThemeColors.unifiedPrimary
              : ThemeColors.unifiedTextMuted,
        ),
      ),
    );
  }
}

// ── Project grid ──────────────────────────────────────────────────────────────
class _ProjectGrid extends StatelessWidget {
  final List<ProjectModel> projects;
  const _ProjectGrid({required this.projects});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 768;
    return LayoutBuilder(
      builder: (ctx, c) {
        final cols = isWide ? 2 : 1;
        final rows = <Widget>[];
        for (int i = 0; i < projects.length; i += cols) {
          rows.add(
            Row(
              children: List.generate(cols, (j) {
                final idx = i + j;
                if (idx >= projects.length)
                  return const Expanded(child: SizedBox());
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: j > 0 ? 14 : 0),
                    child: _ProjectCard(project: projects[idx]),
                  ),
                );
              }),
            ),
          );
          if (i + cols < projects.length) rows.add(const SizedBox(height: 14));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows,
        );
      },
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;
  const _ProjectCard({required this.project});

  String _timeLeft() {
    if (project.endDate == null) return '';
    final diff = project.endDate!.difference(DateTime.now());
    if (diff.isNegative) return 'Overdue';
    if (diff.inDays > 7) return '${(diff.inDays / 7).floor()}w left';
    if (diff.inDays > 0) return '${diff.inDays}d left';
    return 'Due today';
  }

  @override
  Widget build(BuildContext context) {
    final palette = kProjectPalettes[project.id % kProjectPalettes.length];
    final members = project.members.map((m) => m.name).toList();
    final timeLeft = _timeLeft();
    final isOverdue = timeLeft == 'Overdue';
    final pColor = project.progress >= 100
        ? ThemeColors.unifiedSuccess
        : project.progress >= 50
        ? ThemeColors.unifiedAccent
        : ThemeColors.unifiedPrimary;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProjectDetailScreen(projectId: project.id),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: ThemeColors.unifiedSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ThemeColors.unifiedBorder, width: 0.8),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: palette,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (project.projectCode.isNotEmpty)
                        _BannerChip(project.projectCode),
                      const Spacer(),
                      _PriorityDot(project.priority),
                    ],
                  ),
                  Row(
                    children: [
                      if (project.departments.isNotEmpty)
                        _BannerChip(
                          project.departments.first.name,
                          transparent: true,
                        ),
                      const Spacer(),
                      Icon(
                        Icons.folder_copy_rounded,
                        size: 20,
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          project.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: ThemeColors.unifiedTextPrimary,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(status: project.status, fontSize: 9.5),
                    ],
                  ),
                  if (project.description.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      project.description,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: ThemeColors.unifiedTextMuted,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: project.progress / 100,
                            minHeight: 5,
                            backgroundColor: pColor.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(pColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${project.progress}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: pColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(height: 0.5, color: ThemeColors.unifiedBorder),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (members.isNotEmpty)
                        AvatarStack(names: members, size: 24, max: 4)
                      else
                        const Text(
                          'No assignees',
                          style: TextStyle(
                            fontSize: 11,
                            color: ThemeColors.unifiedTextMuted,
                          ),
                        ),
                      const Spacer(),
                      if (timeLeft.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isOverdue
                                ? ThemeColors.priorityUrgentBg
                                : ThemeColors.unifiedInputBg,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            timeLeft,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isOverdue
                                  ? ThemeColors.priorityUrgentFg
                                  : ThemeColors.unifiedTextMuted,
                            ),
                          ),
                        ),
                    ],
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

class _BannerChip extends StatelessWidget {
  final String label;
  final bool transparent;
  const _BannerChip(this.label, {this.transparent = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: transparent
            ? Colors.white.withValues(alpha: 0.18)
            : Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _PriorityDot extends StatelessWidget {
  final String priority;
  const _PriorityDot(this.priority);

  Color get _color {
    switch (priority) {
      case 'urgent':
        return const Color(0xFFEF4444);
      case 'high':
        return const Color(0xFFF97316);
      case 'medium':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF10B981);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        priority[0].toUpperCase() + priority.substring(1),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: _color.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

// ── List view ─────────────────────────────────────────────────────────────────
class _ProjectList extends StatelessWidget {
  final List<ProjectModel> projects;
  const _ProjectList({required this.projects});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ThemeColors.unifiedBorder, width: 0.8),
      ),
      clipBehavior: Clip.hardEdge,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: projects.length,
        separatorBuilder: (_, __) =>
            Container(height: 0.5, color: ThemeColors.unifiedBorder),
        itemBuilder: (ctx, i) => _ListRow(project: projects[i]),
      ),
    );
  }
}

class _ListRow extends StatelessWidget {
  final ProjectModel project;
  const _ListRow({required this.project});

  @override
  Widget build(BuildContext context) {
    final palette = kProjectPalettes[project.id % kProjectPalettes.length];
    final pColor = project.progress >= 100
        ? ThemeColors.unifiedSuccess
        : project.progress >= 50
        ? ThemeColors.unifiedAccent
        : ThemeColors.unifiedPrimary;

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ProjectDetailScreen(projectId: project.id),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: palette),
                borderRadius: BorderRadius.circular(9),
              ),
              alignment: Alignment.center,
              child: Text(
                project.name.isNotEmpty ? project.name[0].toUpperCase() : 'P',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: ThemeColors.unifiedTextPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (project.departments.isNotEmpty)
                    Text(
                      project.departments.first.name,
                      style: const TextStyle(
                        fontSize: 11,
                        color: ThemeColors.unifiedTextMuted,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 100,
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: LinearProgressIndicator(
                        value: project.progress / 100,
                        minHeight: 4,
                        backgroundColor: pColor.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(pColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    '${project.progress}%',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: pColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: ThemeColors.unifiedTextMuted,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty / no results ────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: ThemeColors.unifiedPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.folder_open_rounded,
                size: 30,
                color: ThemeColors.unifiedPrimary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No projects yet',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: ThemeColors.unifiedTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Create your first project to get started.',
              style: TextStyle(
                fontSize: 13,
                color: ThemeColors.unifiedTextMuted,
              ),
            ),
            const SizedBox(height: 20),
            _PrimaryButton(
              label: 'New project',
              icon: Icons.add_rounded,
              onTap: onCreate,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  final String query;
  final VoidCallback onClear;
  const _NoResults({required this.query, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 40,
              color: ThemeColors.unifiedTextMuted,
            ),
            const SizedBox(height: 12),
            Text(
              'No results for "$query"',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ThemeColors.unifiedTextPrimary,
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.clear_rounded, size: 15),
              label: const Text('Clear filters'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullScreenLoader extends StatelessWidget {
  final String message;
  const _FullScreenLoader({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            strokeWidth: 2,
            color: ThemeColors.unifiedPrimary,
          ),
          const SizedBox(height: 14),
          Text(
            message,
            style: const TextStyle(
              fontSize: 13,
              color: ThemeColors.unifiedTextMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: ThemeColors.unifiedPrimary,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
