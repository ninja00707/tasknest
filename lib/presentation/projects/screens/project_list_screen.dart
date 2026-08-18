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

/// Two-tone "cover" palettes cycled by project id — every project gets a
/// consistent, book-jacket-like identity across the whole gallery.
const List<List<Color>> kCoverPalettes = [
  [Color(0xFF1B4B43), Color(0xFF2F6F62)], // pine
  [Color(0xFF7A3B2E), Color(0xFFB5624A)], // terracotta
  [Color(0xFF1E3A5F), Color(0xFF2F6690)], // ink navy
  [Color(0xFF5B3A6B), Color(0xFF8C5A9E)], // plum
  [Color(0xFF6B4E1D), Color(0xFFA97F33)], // bronze
  [Color(0xFF39494A), Color(0xFF5E7677)], // slate
];

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

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  static const _scopes = [null, 'observed', 'mine'];
  static const _tabIcons = [
    Icons.auto_stories_rounded,
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
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 22),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                ConstStrings.projectsTitle,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: ThemeColors.unifiedTextPrimary,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, size: 22),
              onPressed: _load,
            ),
            const SizedBox(width: 4),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TabBar(
                  isScrollable: true,
                  onTap: (i) {
                    setState(() {
                      _tab = i;
                      _searchCtrl.clear();
                      _query = '';
                    });
                    _load();
                  },
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(
                      color: ThemeColors.unifiedPrimary,
                      width: 3,
                    ),
                    insets: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  dividerColor: Colors.transparent,
                  labelColor: ThemeColors.unifiedPrimary,
                  unselectedLabelColor: ThemeColors.unifiedTextMuted,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                  tabs: [
                    Tab(
                      height: 40,
                      icon: Icon(_tabIcons[0], size: 16),
                      iconMargin: const EdgeInsets.only(bottom: 2),
                      text: ConstStrings.projectsAll,
                    ),
                    Tab(
                      height: 40,
                      icon: Icon(_tabIcons[1], size: 16),
                      iconMargin: const EdgeInsets.only(bottom: 2),
                      text: ConstStrings.projectsObserved,
                    ),
                    Tab(
                      height: 40,
                      icon: Icon(_tabIcons[2], size: 16),
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
            final filtered = _query.isEmpty
                ? projects
                : projects
                    .where(
                      (p) =>
                          p.name.toLowerCase().contains(_query.toLowerCase()),
                    )
                    .toList();
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _searchCtrl,
                            onChanged: (v) => setState(() => _query = v),
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: ThemeColors.unifiedTextPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search projects...',
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                size: 20,
                                color: ThemeColors.unifiedTextMuted,
                              ),
                              suffixIcon: _query.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        size: 18,
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
                              fillColor: ThemeColors.unifiedSurface,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: ThemeColors.unifiedPrimary,
                                  width: 1.4,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            '${filtered.length} ${filtered.length == 1 ? 'project' : 'projects'}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: ThemeColors.unifiedTextMuted,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 14),
                          if (filtered.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Text(
                                  'No projects match "$_query"',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: ThemeColors.unifiedTextMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                          else
                            ResponsiveCardGrid(
                              spacing: 16,
                              runSpacing: 16,
                              maxColumns: 2,
                              children: [
                                for (final project in filtered)
                                  _ProjectCard(project: project),
                              ],
                            ),
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
            IconBadge(
              icon: Icons.auto_stories_rounded,
              size: 88,
              color: ThemeColors.unifiedPrimary,
              iconScale: 0.42,
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
    final palette = kCoverPalettes[project.id % kCoverPalettes.length];
    final members = project.members.take(4).toList();
    final extraCount = project.memberCount - members.length;
    final category = project.departments.isNotEmpty
        ? project.departments.first.name
        : 'General';
    final timeLeft = _timeLeft();
    final progressColor = project.progress >= 100
        ? ThemeColors.unifiedSuccess
        : project.progress >= 50
        ? ThemeColors.unifiedAccent
        : ThemeColors.unifiedPrimary;

    return SoftCard(
      radius: 20,
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
          // Cover banner — the "book jacket" for this project.
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
            child: Container(
              height: 96,
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
                  Positioned(
                    right: -10,
                    bottom: -18,
                    child: Icon(
                      Icons.auto_stories_rounded,
                      size: 96,
                      color: Colors.white.withValues(alpha: 0.09),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 10, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _formatDate(project.createdAt),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Spacer(),
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert_rounded,
                            size: 18,
                            color: Colors.white,
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
                  ),
                  Positioned(
                    left: 14,
                    bottom: 10,
                    right: 14,
                    child: Eyebrow(text: category, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: ThemeColors.unifiedTextPrimary,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (project.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
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
                Container(height: 1, color: ThemeColors.unifiedBorder),
                const SizedBox(height: 14),
                Row(
                  children: [
                    ProgressRing(
                      value: project.progress / 100,
                      size: 38,
                      strokeWidth: 4,
                      color: progressColor,
                      trackColor: ThemeColors.unifiedInputBg,
                      centerChild: Text(
                        '${project.progress}',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: progressColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (members.isNotEmpty)
                      SizedBox(
                        width: (members.length * 18.0) + 6,
                        height: 24,
                        child: Stack(
                          children: [
                            for (int i = 0; i < members.length; i++)
                              Positioned(
                                left: i * 18.0,
                                child: InitialsAvatar(
                                  name: members[i].name,
                                  size: 24,
                                ),
                              ),
                          ],
                        ),
                      ),
                    if (extraCount > 0) ...[
                      const SizedBox(width: 2),
                      Text(
                        '+$extraCount',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: ThemeColors.unifiedTextMuted,
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
                          color: ThemeColors.unifiedInputBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          timeLeft,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: ThemeColors.unifiedTextMuted,
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
    );
  }
}
