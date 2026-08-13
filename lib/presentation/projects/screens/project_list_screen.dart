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
              onRefresh: _load,
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
                        maxColumns: 2,
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

const List<LinearGradient> kCardGradients = [
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
  ),
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF3E0), Color(0xFFFFF8E1)],
  ),
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8F5E9), Color(0xFFE0F2F1)],
  ),
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFCE4EC), Color(0xFFF3E5F5)],
  ),
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE3F2FD), Color(0xFFE8EAF6)],
  ),
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF9C4), Color(0xFFFFF3E0)],
  ),
];

class _ProjectCard extends StatelessWidget {
  final ProjectModel project;
  const _ProjectCard({required this.project});

  String _formatDate(DateTime d) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month]} ${d.day}, ${d.year}';
  }

  String _timeLeft() {
    if (project.endDate == null) return '';
    final diff = project.endDate!.difference(DateTime.now());
    if (diff.isNegative) return 'Overdue';
    if (diff.inDays > 7) return '${(diff.inDays / 7).floor()} week left';
    if (diff.inDays > 0) return '${diff.inDays} Days Left';
    if (diff.inHours > 0) return '${diff.inHours}h left';
    return 'Today';
  }

  @override
  Widget build(BuildContext context) {
    final gradient = kCardGradients[project.id % kCardGradients.length];
    final members = project.members.take(3).toList();
    final extraCount = project.memberCount - members.length;
    final category = project.departments.isNotEmpty
        ? project.departments.first.name
        : project.description.isNotEmpty
            ? project.description
            : 'General';
    final timeLeft = _timeLeft();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProjectDetailScreen(projectId: project.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatDate(project.createdAt),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (v) {
                    if (v == 'view') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProjectDetailScreen(
                            projectId: project.id,
                          ),
                        ),
                      );
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Text('View details'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              project.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2D3436),
                letterSpacing: -0.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              category,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  'Progress',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${project.progress}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (project.progress / 100).clamp(0, 1),
                minHeight: 6,
                backgroundColor: Colors.white.withValues(alpha: 0.5),
                valueColor: AlwaysStoppedAnimation<Color>(
                  project.progress >= 100
                      ? const Color(0xFF00C853)
                      : project.progress >= 50
                          ? const Color(0xFF00BFA5)
                          : const Color(0xFF2979FF),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (members.isNotEmpty)
                  SizedBox(
                    width: (members.length * 22.0) + (members.length > 1 ? 4.0 : 0),
                    height: 26,
                    child: Stack(
                      children: [
                        for (int i = 0; i < members.length; i++)
                          Positioned(
                            left: i * 22.0,
                            child: InitialsAvatar(
                              name: members[i].name,
                              size: 26,
                            ),
                          ),
                      ],
                    ),
                  ),
                if (extraCount > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '+$extraCount',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (timeLeft.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 11,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeLeft,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
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
    );
  }
}