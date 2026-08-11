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
import 'package:tasknest/presentation/projects/widgets/UIhelpers.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  int _tab = 0;
  List<ProjectModel>? _lastProjects;

  static const _scopes = [null, 'observed', 'mine'];
  static const _tabIcons = [
    Icons.grid_view_rounded,
    Icons.visibility_outlined,
    Icons.person_outline_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    context.read<ProjectBloc>().add(LoadProjects(scope: _scopes[_tab]));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: ThemeColors.unifiedInputBg.withValues(alpha: 0.35),
        appBar: AppBar(
          backgroundColor: ThemeColors.unifiedSurface,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(
            ConstStrings.projectsTitle,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: ThemeColors.unifiedTextPrimary,
              letterSpacing: -0.2,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 22),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 22),
              onPressed: _load,
            ),
            const SizedBox(width: 4),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Container(
                height: 54,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: ThemeColors.unifiedInputBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TabBar(
                  onTap: (i) {
                    setState(() => _tab = i);
                    _load();
                  },
                  indicator: BoxDecoration(
                    color: ThemeColors.unifiedPrimary,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  splashBorderRadius: BorderRadius.circular(11),
                  labelColor: Colors.white,
                  unselectedLabelColor: ThemeColors.unifiedTextMuted,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                  tabs: [
                    Tab(
                      icon: Icon(_tabIcons[0], size: 15),
                      iconMargin: const EdgeInsets.only(bottom: 2),
                      text: ConstStrings.projectsAll,
                    ),
                    Tab(
                      icon: Icon(_tabIcons[1], size: 15),
                      iconMargin: const EdgeInsets.only(bottom: 2),
                      text: ConstStrings.projectsObserved,
                    ),
                    Tab(
                      icon: Icon(_tabIcons[2], size: 15),
                      iconMargin: const EdgeInsets.only(bottom: 2),
                      text: ConstStrings.projectsMine,
                    ),
                  ],
                ),
              ),
            ),
          ),
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
                    CircularProgressIndicator(strokeWidth: 2.5),
                    SizedBox(height: 16),
                    Text(
                      'Loading projects...',
                      style: TextStyle(
                        color: ThemeColors.unifiedTextMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }
            final projects = state is ProjectListLoaded
                ? state.projects
                : _lastProjects ?? const <ProjectModel>[];
            if (projects.isEmpty) {
              return _EmptyState(showHint: _tab == 1);
            }
            return RefreshIndicator(
              onRefresh: () => _load(),
              color: ThemeColors.unifiedPrimary,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: projectPagePadding(constraints.maxWidth),
                    child: ResponsivePageContainer(
                      maxWidth: kProjectsPageMaxWidth,
                      child: ResponsiveCardGrid(
                        spacing: 14,
                        runSpacing: 14,
                        maxColumns: 3,
                        children: [
                          for (final project in projects)
                            _ProjectCard(project: project),
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
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CreateProjectScreen()),
            );
          },
          backgroundColor: ThemeColors.unifiedPrimary,
          foregroundColor: Colors.white,
          elevation: 2,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            ConstStrings.projectsCreate,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool showHint;
  const _EmptyState({required this.showHint});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: ThemeColors.unifiedPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Icon(
                Icons.folder_open_rounded,
                size: 42,
                color: ThemeColors.unifiedPrimary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              ConstStrings.projectsNoData,
              style: const TextStyle(
                fontSize: 16,
                color: ThemeColors.unifiedTextPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (showHint) ...[
              const SizedBox(height: 8),
              Text(
                ConstStrings.projectsObservedHint,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: ThemeColors.unifiedTextMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;
  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final (priorityBg, priorityFg) = switch (project.priority) {
      'high' => (ThemeColors.priorityHighBg, ThemeColors.priorityHighFg),
      'urgent' => (ThemeColors.priorityUrgentBg, ThemeColors.priorityUrgentFg),
      'low' => (ThemeColors.priorityLowBg, ThemeColors.priorityLowFg),
      _ => (ThemeColors.priorityMedBg, ThemeColors.priorityMedFg),
    };
    final progressColor = project.progress >= 100
        ? ThemeColors.unifiedSuccess
        : project.progress >= 50
        ? ThemeColors.unifiedAccent
        : ThemeColors.unifiedPrimary;

    return SoftCard(
      padding: const EdgeInsets.all(16),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: ThemeColors.unifiedTextPrimary,
                        letterSpacing: -0.1,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (project.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        project.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.35,
                          color: ThemeColors.unifiedTextMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              DotPill(
                label: project.priority.toUpperCase(),
                bg: priorityBg,
                fg: priorityFg,
              ),
            ],
          ),
          if (project.departments.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: project.departments
                  .map(
                    (d) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: ThemeColors.unifiedPrimary.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        d.name,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: ThemeColors.unifiedPrimary,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _MetricPill(
                icon: Icons.check_circle_rounded,
                label: '${project.doneCount}/${project.taskCount}',
                color: ThemeColors.unifiedSuccess,
              ),
              _MetricPill(
                icon: Icons.people_alt_rounded,
                label: '${project.memberCount}',
                color: ThemeColors.unifiedPrimary,
              ),
              _MetricPill(
                icon: Icons.visibility_rounded,
                label: '${project.observerCount}',
                color: ThemeColors.unifiedAccent,
              ),
              _StatusChip(status: project.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SoftProgressBar(
                  value: project.progress / 100,
                  color: progressColor,
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
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MetricPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (status) {
      'completed' => (
        ThemeColors.statusDoneBg,
        ThemeColors.statusDoneFg,
        'Completed',
      ),
      'in_progress' => (
        ThemeColors.statusProgressBg,
        ThemeColors.statusProgressFg,
        'In Progress',
      ),
      'on_hold' => (
        ThemeColors.statusClosedBg,
        ThemeColors.statusClosedFg,
        'On Hold',
      ),
      _ => (ThemeColors.statusOpenBg, ThemeColors.statusOpenFg, 'Planned'),
    };
    return DotPill(label: label, bg: bg, fg: fg, fontSize: 10.5);
  }
}
