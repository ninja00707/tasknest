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

/// Refined modern palettes for project identity headers
const List<List<Color>> kProjectPalettes = [
  [Color(0xFF1E3C72), Color(0xFF2A5298)], // Royal Azure
  [Color(0xFF134E5E), Color(0xFF71B280)], // Emerald Teal
  [Color(0xFF2C3E50), Color(0xFF4CA1AF)], // Steel Blue
  [Color(0xFF614385), Color(0xFF516395)], // Modern Indigo
  [Color(0xFF834D9B), Color(0xFFD04ED6)], // Plum Berry
  [Color(0xFF1F4037), Color(0xFF99F2C8)], // Deep Forest
  [Color(0xFF4B6CB7), Color(0xFF182848)], // Deep Navy
  [Color(0xFFBA8B02), Color(0xFF181818)], // Amber Obsidian
];

enum ProjectViewMode { grid, list }

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  int _tab = 0; // 0: All, 1: Observed, 2: Mine
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

  Future<void> _load() async {
    context.read<ProjectBloc>().add(LoadProjects(scope: _scopes[_tab]));
  }

  void _navigateToCreate() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreateProjectScreen()),
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
        shadowColor: Colors.black.withValues(alpha: 0.05),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: ThemeColors.unifiedPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.folder_special_rounded,
                size: 20,
                color: ThemeColors.unifiedPrimary,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              ConstStrings.projectsTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: ThemeColors.unifiedTextPrimary,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: 'Refresh',
            onPressed: _load,
          ),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: ElevatedButton.icon(
              onPressed: _navigateToCreate,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text(
                'New Project',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.unifiedPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<ProjectBloc, ProjectState>(
        listener: (context, state) {
          if (state is ProjectListLoaded) {
            _lastProjects = state.projects;
          }
          if (state is ProjectActionSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: ThemeColors.unifiedSuccess,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  duration: const Duration(seconds: 3),
                ),
              );
            _load();
          }
          if (state is ProjectActionError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: ThemeColors.unifiedDanger,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
          }
        },
        builder: (context, state) {
          if (state is ProjectLoading && _lastProjects == null) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: ThemeColors.unifiedPrimary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading projects...',
                    style: TextStyle(
                      color: ThemeColors.unifiedTextMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            );
          }

          final allProjects = state is ProjectListLoaded
              ? state.projects
              : _lastProjects ?? const <ProjectModel>[];

          // Compute KPI counts
          final totalCount = allProjects.length;
          final inProgressCount = allProjects.where((p) => p.progress > 0 && p.progress < 100).length;
          final completedCount = allProjects.where((p) => p.progress >= 100).length;
          final highPriorityCount = allProjects.where((p) => p.priority == 'urgent' || p.priority == 'high').length;

          // Apply filters
          final filtered = allProjects.where((p) {
            final matchesQuery = _query.isEmpty ||
                p.name.toLowerCase().contains(_query.toLowerCase()) ||
                p.projectCode.toLowerCase().contains(_query.toLowerCase()) ||
                p.departments.any((d) => d.name.toLowerCase().contains(_query.toLowerCase()));

            final matchesPriority = _priorityFilter == 'all' ||
                p.priority.toLowerCase() == _priorityFilter.toLowerCase();

            return matchesQuery && matchesPriority;
          }).toList();

          return RefreshIndicator(
            onRefresh: _load,
            color: ThemeColors.unifiedPrimary,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 768;
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: projectPagePadding(constraints.maxWidth),
                  child: ResponsivePageContainer(
                    maxWidth: kProjectsPageMaxWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // KPI Metric Cards Row
                        _buildKpiMetricsRow(
                          total: totalCount,
                          inProgress: inProgressCount,
                          completed: completedCount,
                          highPriority: highPriorityCount,
                          isWide: isWide,
                        ),
                        const SizedBox(height: 20),

                        // Scope & Filter Tabs Bar
                        _buildControlsBar(isWide: isWide, totalFiltered: filtered.length),
                        const SizedBox(height: 18),

                        // Project Grid or List View
                        if (allProjects.isEmpty)
                          _EmptyProjectsView(
                            isObserverTab: _tab == 1,
                            onCreate: _navigateToCreate,
                          )
                        else if (filtered.isEmpty)
                          _NoSearchResultsView(
                            query: _query,
                            onClear: () {
                              setState(() {
                                _searchCtrl.clear();
                                _query = '';
                                _priorityFilter = 'all';
                              });
                            },
                          )
                        else if (_viewMode == ProjectViewMode.grid)
                          ResponsiveCardGrid(
                            spacing: 16,
                            runSpacing: 16,
                            maxColumns: 2,
                            children: [
                              for (final project in filtered)
                                _ProjectCard(project: project),
                            ],
                          )
                        else
                          _buildListView(filtered),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreate,
        backgroundColor: ThemeColors.unifiedPrimary,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text(
          ConstStrings.projectsCreate,
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
        ),
      ),
    );
  }

  Widget _buildKpiMetricsRow({
    required int total,
    required int inProgress,
    required int completed,
    required int highPriority,
    required bool isWide,
  }) {
    final cards = [
      StatMetricCard(
        icon: Icons.folder_copy_outlined,
        title: 'Total Projects',
        value: '$total',
        subtitle: 'In current workspace',
        accentColor: ThemeColors.unifiedPrimary,
      ),
      StatMetricCard(
        icon: Icons.sync_rounded,
        title: 'In Progress',
        value: '$inProgress',
        subtitle: 'Active development',
        accentColor: ThemeColors.unifiedSecondary,
      ),
      StatMetricCard(
        icon: Icons.task_alt_rounded,
        title: 'Completed',
        value: '$completed',
        subtitle: 'Delivered successfully',
        accentColor: ThemeColors.unifiedSuccess,
      ),
      StatMetricCard(
        icon: Icons.flag_rounded,
        title: 'High Priority',
        value: '$highPriority',
        subtitle: 'Needs attention',
        accentColor: ThemeColors.priorityHighFg,
      ),
    ];

    if (isWide) {
      return Row(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            Expanded(child: cards[i]),
            if (i < cards.length - 1) const SizedBox(width: 14),
          ],
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 12),
            Expanded(child: cards[1]),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: cards[2]),
            const SizedBox(width: 12),
            Expanded(child: cards[3]),
          ],
        ),
      ],
    );
  }

  Widget _buildControlsBar({required bool isWide, required int totalFiltered}) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      radius: 16,
      child: Column(
        children: [
          // Row 1: Scope Pills + View Mode Toggles
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _ScopePill(
                        label: 'All Projects',
                        icon: Icons.grid_view_rounded,
                        selected: _tab == 0,
                        onTap: () {
                          if (_tab != 0) {
                            setState(() => _tab = 0);
                            _load();
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      _ScopePill(
                        label: 'Observed',
                        icon: Icons.visibility_outlined,
                        selected: _tab == 1,
                        onTap: () {
                          if (_tab != 1) {
                            setState(() => _tab = 1);
                            _load();
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      _ScopePill(
                        label: 'My Projects',
                        icon: Icons.person_outline_rounded,
                        selected: _tab == 2,
                        onTap: () {
                          if (_tab != 2) {
                            setState(() => _tab = 2);
                            _load();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // View mode switch
              Container(
                decoration: BoxDecoration(
                  color: ThemeColors.unifiedInputBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ViewModeIconButton(
                      icon: Icons.grid_view_rounded,
                      active: _viewMode == ProjectViewMode.grid,
                      tooltip: 'Grid view',
                      onTap: () => setState(() => _viewMode = ProjectViewMode.grid),
                    ),
                    _ViewModeIconButton(
                      icon: Icons.view_list_rounded,
                      active: _viewMode == ProjectViewMode.list,
                      tooltip: 'List view',
                      onTap: () => setState(() => _viewMode = ProjectViewMode.list),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Row 2: Search input + Priority Filters
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: ThemeColors.unifiedTextPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by project name, code, or department...',
                    hintStyle: const TextStyle(
                      fontSize: 12.5,
                      color: ThemeColors.unifiedTextMuted,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 18,
                      color: ThemeColors.unifiedTextMuted,
                    ),
                    suffixIcon: _query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 16,
                              color: ThemeColors.unifiedTextMuted,
                            ),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _query = '');
                            },
                          )
                        : null,
                    isDense: true,
                    filled: true,
                    fillColor: ThemeColors.unifiedInputBg,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Priority filter dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: ThemeColors.unifiedInputBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _priorityFilter,
                    icon: const Icon(Icons.tune_rounded, size: 16),
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: ThemeColors.unifiedTextPrimary,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All Priorities')),
                      DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                      DropdownMenuItem(value: 'high', child: Text('High')),
                      DropdownMenuItem(value: 'medium', child: Text('Medium')),
                      DropdownMenuItem(value: 'low', child: Text('Low')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _priorityFilter = v);
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
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: ThemeColors.unifiedTextMuted,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<ProjectModel> projects) {
    return SoftCard(
      padding: EdgeInsets.zero,
      radius: 16,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: projects.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          thickness: 1,
          color: ThemeColors.unifiedBorder,
        ),
        itemBuilder: (context, i) {
          final p = projects[i];
          return _ProjectListRow(project: p);
        },
      ),
    );
  }
}

class _ScopePill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ScopePill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? ThemeColors.unifiedPrimary
              : ThemeColors.unifiedInputBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: selected ? Colors.white : ThemeColors.unifiedTextMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? Colors.white : ThemeColors.unifiedTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewModeIconButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final String tooltip;
  final VoidCallback onTap;

  const _ViewModeIconButton({
    required this.icon,
    required this.active,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: active ? ThemeColors.unifiedSurface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Icon(
            icon,
            size: 16,
            color: active
                ? ThemeColors.unifiedPrimary
                : ThemeColors.unifiedTextMuted,
          ),
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;
  const _ProjectCard({required this.project});

  String _formatDate(DateTime d) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month]} ${d.day}, ${d.year}';
  }

  String _timeLeft() {
    if (project.endDate == null) return '';
    final diff = project.endDate!.difference(DateTime.now());
    if (diff.isNegative) return 'Overdue';
    if (diff.inDays > 7) return '${(diff.inDays / 7).floor()}w left';
    if (diff.inDays > 0) return '${diff.inDays}d left';
    if (diff.inHours > 0) return '${diff.inHours}h left';
    return 'Due today';
  }

  @override
  Widget build(BuildContext context) {
    final palette = kProjectPalettes[project.id % kProjectPalettes.length];
    final memberNames = project.members.map((m) => m.name).toList();
    final departmentName = project.departments.isNotEmpty
        ? project.departments.first.name
        : 'General';
    final timeLeft = _timeLeft();
    final isOverdue = timeLeft == 'Overdue';

    final progressColor = project.progress >= 100
        ? ThemeColors.unifiedSuccess
        : project.progress >= 50
            ? ThemeColors.unifiedAccent
            : ThemeColors.unifiedPrimary;

    return SoftCard(
      radius: 18,
      padding: EdgeInsets.zero,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProjectDetailScreen(projectId: project.id),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Elegant Header Gradient Banner
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
            child: Container(
              height: 92,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: palette,
                ),
              ),
              child: Stack(
                children: [
                  // Subtle watermark icon
                  Positioned(
                    right: -10,
                    bottom: -16,
                    child: Icon(
                      Icons.folder_copy_rounded,
                      size: 90,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 12, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (project.projectCode.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  project.projectCode,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            const Spacer(),
                            PriorityBadge(
                              priority: project.priority,
                              fontSize: 9.5,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                departmentName,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatDate(project.createdAt),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.8),
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
          ),

          // Card Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        project.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: ThemeColors.unifiedTextPrimary,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(status: project.status, fontSize: 10),
                  ],
                ),
                if (project.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    project.description,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: ThemeColors.unifiedTextMuted,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 14),

                // Linear Progress bar & %
                Row(
                  children: [
                    Expanded(
                      child: SoftProgressBar(
                        value: project.progress / 100,
                        color: progressColor,
                        height: 6,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${project.progress}%',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: progressColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(height: 1, color: ThemeColors.unifiedBorder),
                const SizedBox(height: 12),

                // Footer: Avatars + Remaining Time
                Row(
                  children: [
                    if (memberNames.isNotEmpty)
                      AvatarStack(names: memberNames, size: 26, max: 4)
                    else
                      const Text(
                        'No assignees',
                        style: TextStyle(
                          fontSize: 11,
                          color: ThemeColors.unifiedTextMuted,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    const Spacer(),
                    if (timeLeft.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isOverdue
                              ? ThemeColors.priorityUrgentBg
                              : ThemeColors.unifiedInputBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isOverdue
                                  ? Icons.error_outline_rounded
                                  : Icons.schedule_rounded,
                              size: 13,
                              color: isOverdue
                                  ? ThemeColors.priorityUrgentFg
                                  : ThemeColors.unifiedTextMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              timeLeft,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: isOverdue
                                    ? ThemeColors.priorityUrgentFg
                                    : ThemeColors.unifiedTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectListRow extends StatelessWidget {
  final ProjectModel project;
  const _ProjectListRow({required this.project});

  @override
  Widget build(BuildContext context) {
    final memberNames = project.members.map((m) => m.name).toList();
    final progressColor = project.progress >= 100
        ? ThemeColors.unifiedSuccess
        : project.progress >= 50
            ? ThemeColors.unifiedAccent
            : ThemeColors.unifiedPrimary;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProjectDetailScreen(projectId: project.id),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: progressColor,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        project.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: ThemeColors.unifiedTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (project.projectCode.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          '[${project.projectCode}]',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: ThemeColors.unifiedTextMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (project.departments.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      project.departments.first.name,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: ThemeColors.unifiedTextMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            PriorityBadge(priority: project.priority, fontSize: 10),
            const SizedBox(width: 14),
            SizedBox(
              width: 110,
              child: Row(
                children: [
                  Expanded(
                    child: SoftProgressBar(
                      value: project.progress / 100,
                      color: progressColor,
                      height: 5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${project.progress}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: progressColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            if (memberNames.isNotEmpty)
              AvatarStack(names: memberNames, size: 24, max: 3)
            else
              const SizedBox(width: 40),
            const SizedBox(width: 10),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: ThemeColors.unifiedTextMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyProjectsView extends StatelessWidget {
  final bool isObserverTab;
  final VoidCallback onCreate;

  const _EmptyProjectsView({
    required this.isObserverTab,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconBadge(
              icon: isObserverTab
                  ? Icons.visibility_outlined
                  : Icons.folder_open_rounded,
              size: 80,
              color: ThemeColors.unifiedPrimary,
              iconScale: 0.44,
            ),
            const SizedBox(height: 20),
            Text(
              isObserverTab
                  ? 'No observed projects yet'
                  : ConstStrings.projectsNoData,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: ThemeColors.unifiedTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isObserverTab
                  ? ConstStrings.projectsObservedHint
                  : 'Start by creating your first project to track tasks, timelines, and milestones.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: ThemeColors.unifiedTextMuted,
              ),
            ),
            if (!isObserverTab) ...[
              const SizedBox(height: 22),
              ElevatedButton.icon(
                onPressed: onCreate,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text(ConstStrings.projectsCreate),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeColors.unifiedPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NoSearchResultsView extends StatelessWidget {
  final String query;
  final VoidCallback onClear;

  const _NoSearchResultsView({required this.query, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconBadge(
              icon: Icons.search_off_rounded,
              size: 64,
              color: ThemeColors.unifiedTextMuted,
              iconScale: 0.45,
            ),
            const SizedBox(height: 16),
            Text(
              'No projects found matching "$query"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: ThemeColors.unifiedTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try checking for typos or clear filters to view all projects.',
              style: TextStyle(
                fontSize: 12.5,
                color: ThemeColors.unifiedTextMuted,
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.clear_rounded, size: 16),
              label: const Text('Clear Search & Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
