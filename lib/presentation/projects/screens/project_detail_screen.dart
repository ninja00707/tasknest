import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/data/datasource/localstorage/sharedpreferences.dart';
import 'package:tasknest/presentation/create_ticket_module/widget/create_ticket_screen.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/projects/bloc/project_bloc.dart';
import 'package:tasknest/presentation/projects/bloc/project_event.dart';
import 'package:tasknest/presentation/projects/bloc/project_state.dart';
import 'package:tasknest/presentation/projects/model/project_models.dart';
import 'package:tasknest/presentation/projects/screens/add_task_screen.dart';
import 'package:tasknest/presentation/projects/screens/edit_project_screen.dart';
import 'package:tasknest/presentation/projects/widgets/gantt_chart.dart';
import 'package:tasknest/presentation/projects/widgets/project_calendar.dart';
import 'package:tasknest/presentation/projects/widgets/project_stats_section.dart';
import 'package:tasknest/presentation/projects/widgets/project_task_kanban_board.dart';
import 'package:tasknest/presentation/projects/widgets/project_tickets_board.dart';
import 'package:tasknest/presentation/projects/widgets/team_management_section.dart';
import 'package:tasknest/presentation/projects/widgets/ui_helpers.dart';

class ProjectDetailScreen extends StatefulWidget {
  final int projectId;
  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  UserModel? _currentUser;
  ProjectModel? _lastProject;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _load();
    LocalStorageService().getUser().then((u) {
      if (mounted) setState(() => _currentUser = u);
    });
  }

  void _load() {
    context.read<ProjectBloc>().add(LoadProjectDetail(widget.projectId));
  }

  void _confirmDelete(BuildContext context, ProjectModel project) {
    final bloc = context.read<ProjectBloc>();
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: ThemeColors.unifiedDanger),
            SizedBox(width: 8),
            Text(ConstStrings.projectsDelete),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${project.name}"?\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.unifiedDanger,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text(
              'Delete Project',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        bloc.add(DeleteProjectEvent(project.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProjectBloc, ProjectState>(
      listener: (context, state) {
        if (state is ProjectDetailLoaded) {
          _lastProject = state.project;
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
              ),
            );
          if (state.message.toLowerCase().contains('deleted')) {
            Navigator.of(context).pop();
          } else {
            _load();
          }
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
        if (state is ProjectLoading && _lastProject == null) {
          return Scaffold(
            backgroundColor: ThemeColors.unifiedBackground,
            appBar: _buildAppBar(title: 'Loading...'),
            body: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: ThemeColors.unifiedPrimary,
              ),
            ),
          );
        }

        final project = state is ProjectDetailLoaded
            ? state.project
            : _lastProject;

        if (project == null) {
          return Scaffold(
            backgroundColor: ThemeColors.unifiedBackground,
            appBar: _buildAppBar(title: 'Project Not Found'),
            body: const FriendlyEmptyState(
              icon: Icons.folder_off_rounded,
              message: ConstStrings.projectsNoData,
              hint: 'The requested project could not be found.',
            ),
          );
        }

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: ThemeColors.unifiedBackground,
          appBar: _buildAppBar(
            title: project.name,
            projectCode: project.projectCode,
            onOpenDrawer: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
          endDrawer: _ProjectDetailDrawer(
            project: project,
            currentUser: _currentUser,
            onEdit: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EditProjectScreen(project: project),
                ),
              );
            },
            onDelete: () => _confirmDelete(context, project),
          ),
          body: _ProjectDetailBody(
            project: project,
            currentUser: _currentUser,
            onEdit: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EditProjectScreen(project: project),
                ),
              );
            },
            onDelete: () => _confirmDelete(context, project),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar({
    required String title,
    String? projectCode,
    VoidCallback? onOpenDrawer,
  }) {
    return AppBar(
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
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: ThemeColors.unifiedTextPrimary,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (projectCode != null && projectCode.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: ThemeColors.unifiedInputBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: ThemeColors.unifiedBorder, width: 0.8),
              ),
              child: Text(
                projectCode,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.unifiedTextMuted,
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, size: 20),
          tooltip: 'Refresh',
          onPressed: _load,
        ),
        if (onOpenDrawer != null)
          IconButton(
            icon: const Icon(Icons.tune_rounded, size: 20),
            tooltip: 'Project details & settings',
            onPressed: onOpenDrawer,
          ),
        const SizedBox(width: 4),
      ],
    );
  }
}

class _ProjectDetailBody extends StatefulWidget {
  final ProjectModel project;
  final UserModel? currentUser;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProjectDetailBody({
    required this.project,
    required this.currentUser,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_ProjectDetailBody> createState() => _ProjectDetailBodyState();
}

class _ProjectDetailBodyState extends State<_ProjectDetailBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openAddTaskModal() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddTaskScreen(
          projectId: widget.project.id,
          projectName: widget.project.name,
          departments: widget.project.departments,
          members: widget.project.members,
        ),
      ),
    );
  }

  void _openNewTicketModal() {
    if (widget.currentUser == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateTicketView(
          user: widget.currentUser!,
          initialProjectId: widget.project.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.project.isObserver) _buildObserverBanner(),

        // Project Hero Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: ResponsivePageContainer(
            maxWidth: kProjectsPageMaxWidth,
            child: _ModernProjectHeader(
              project: widget.project,
              onAddTask: widget.project.canManage ? _openAddTaskModal : null,
              onNewTicket: _openNewTicketModal,
              onEdit: widget.project.canEdit ? widget.onEdit : null,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Modern Tab Navigation
        Container(
          decoration: const BoxDecoration(
            color: ThemeColors.unifiedSurface,
            border: Border(
              bottom: BorderSide(
                color: ThemeColors.unifiedBorder,
                width: 1,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ResponsivePageContainer(
              maxWidth: kProjectsPageMaxWidth,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: ThemeColors.unifiedPrimary,
                indicatorWeight: 3,
                labelColor: ThemeColors.unifiedPrimary,
                unselectedLabelColor: ThemeColors.unifiedTextMuted,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                tabs: [
                  const Tab(
                    icon: Icon(Icons.analytics_outlined, size: 16),
                    text: 'Overview',
                  ),
                  Tab(
                    icon: const Icon(Icons.task_alt_rounded, size: 16),
                    text: 'Tasks (${widget.project.tasks.length})',
                  ),
                  const Tab(
                    icon: Icon(Icons.view_kanban_rounded, size: 16),
                    text: 'Board',
                  ),
                  const Tab(
                    icon: Icon(Icons.view_timeline_rounded, size: 16),
                    text: 'Timeline',
                  ),
                  const Tab(
                    icon: Icon(Icons.calendar_month_rounded, size: 16),
                    text: 'Calendar',
                  ),
                  Tab(
                    icon: const Icon(Icons.group_rounded, size: 16),
                    text: 'Team (${widget.project.members.length})',
                  ),
                ],
              ),
            ),
          ),
        ),

        // Tab views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // 1. Overview Tab
              _ProjectOverviewTab(
                project: widget.project,
                currentUser: widget.currentUser,
                onAddTask: widget.project.canManage ? _openAddTaskModal : null,
                onNewTicket: _openNewTicketModal,
              ),
              // 2. Tasks Tab
              _ProjectTasksTab(
                project: widget.project,
                currentUser: widget.currentUser,
                onAddTask: widget.project.canManage ? _openAddTaskModal : null,
              ),
              // 3. Board Tab (Switchable Task Kanban / Ticket Kanban)
              _ProjectBoardTab(
                project: widget.project,
                currentUser: widget.currentUser,
              ),
              // 4. Timeline (Gantt Chart)
              Padding(
                padding: const EdgeInsets.all(16),
                child: GanttChart(project: widget.project),
              ),
              // 5. Calendar
              Padding(
                padding: const EdgeInsets.all(16),
                child: ProjectCalendar(project: widget.project),
              ),
              // 6. Team & Access
              _ProjectTeamTab(
                project: widget.project,
                canManage: widget.project.canManage,
                onEdit: widget.onEdit,
                onDelete: widget.onDelete,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildObserverBanner() {
    return Container(
      width: double.infinity,
      color: ThemeColors.statusOpenBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.visibility_rounded,
            color: ThemeColors.statusOpenFg,
            size: 16,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              ConstStrings.projectsObserverBanner,
              style: TextStyle(
                color: ThemeColors.statusOpenFg,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernProjectHeader extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback? onAddTask;
  final VoidCallback? onNewTicket;
  final VoidCallback? onEdit;

  const _ModernProjectHeader({
    required this.project,
    this.onAddTask,
    this.onNewTicket,
    this.onEdit,
  });

  String _formatDateRange() {
    final start = project.startDate;
    final end = project.endDate;
    if (start == null && end == null) return 'No dates scheduled';
    final fmt = DateFormat('MMM d, y');
    if (start != null && end != null) {
      return '${fmt.format(start)} – ${fmt.format(end)}';
    }
    if (start != null) return 'From ${fmt.format(start)}';
    return 'Due ${fmt.format(end!)}';
  }

  @override
  Widget build(BuildContext context) {
    final progressColor = project.progress >= 100
        ? ThemeColors.unifiedSuccess
        : project.progress >= 50
            ? ThemeColors.unifiedAccent
            : ThemeColors.unifiedPrimary;

    final completedTasks = project.tasks.where((t) => t.status == 'done').length;

    return SoftCard(
      padding: const EdgeInsets.all(18),
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Code + Status + Priority + Created By
          Row(
            children: [
              if (project.projectCode.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: ThemeColors.unifiedPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    project.projectCode,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: ThemeColors.unifiedPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              StatusBadge(status: project.status, fontSize: 10.5),
              const SizedBox(width: 6),
              PriorityBadge(priority: project.priority, fontSize: 10.5),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InitialsAvatar(name: project.createdByName, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Created by ${project.createdByName}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: ThemeColors.unifiedTextMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title & Action Buttons
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
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: ThemeColors.unifiedTextPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    if (project.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        project.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: ThemeColors.unifiedTextMuted,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Action Buttons
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: [
                  if (onAddTask != null)
                    ElevatedButton.icon(
                      onPressed: onAddTask,
                      icon: const Icon(Icons.add_task_rounded, size: 16),
                      label: const Text(
                        'Add Task',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeColors.unifiedPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  if (onNewTicket != null)
                    OutlinedButton.icon(
                      onPressed: onNewTicket,
                      icon: const Icon(Icons.confirmation_number_outlined, size: 16),
                      label: const Text(
                        'New Ticket',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ThemeColors.unifiedPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                        side: const BorderSide(color: ThemeColors.unifiedPrimary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      tooltip: 'Edit project info',
                      onPressed: onEdit,
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Department & Date metadata
          Row(
            children: [
              if (project.departments.isNotEmpty) ...[
                const Icon(
                  Icons.apartment_rounded,
                  size: 14,
                  color: ThemeColors.unifiedTextMuted,
                ),
                const SizedBox(width: 5),
                Text(
                  project.departments.map((d) => d.name).join(', '),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.unifiedTextMuted,
                  ),
                ),
                const SizedBox(width: 14),
              ],
              const Icon(
                Icons.calendar_today_rounded,
                size: 13,
                color: ThemeColors.unifiedTextMuted,
              ),
              const SizedBox(width: 5),
              Text(
                _formatDateRange(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ThemeColors.unifiedTextMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Progress bar + quick counts
          Row(
            children: [
              Expanded(
                child: SoftProgressBar(
                  value: project.progress / 100,
                  color: progressColor,
                  height: 8,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${project.progress}% completed',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: progressColor,
                ),
              ),
              const SizedBox(width: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: ThemeColors.unifiedInputBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$completedTasks/${project.tasks.length} tasks done',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: ThemeColors.unifiedTextMuted,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProjectOverviewTab extends StatelessWidget {
  final ProjectModel project;
  final UserModel? currentUser;
  final VoidCallback? onAddTask;
  final VoidCallback? onNewTicket;

  const _ProjectOverviewTab({
    required this.project,
    required this.currentUser,
    this.onAddTask,
    this.onNewTicket,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        ResponsivePageContainer(
          maxWidth: kProjectsPageMaxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Detailed Health & Progress Stats
              ProjectStatsSection(project: project),
              const SizedBox(height: 24),

              // Linked Tickets Board
              if (project.tickets.isNotEmpty) ...[
                SectionHeader(
                  icon: Icons.confirmation_number_outlined,
                  title: 'Linked Tickets',
                  trailing: onNewTicket != null
                      ? TextButton.icon(
                          onPressed: onNewTicket,
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text('Add Ticket'),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                ProjectTicketsBoard(
                  tickets: project.tickets,
                  user: currentUser,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ProjectTasksTab extends StatefulWidget {
  final ProjectModel project;
  final UserModel? currentUser;
  final VoidCallback? onAddTask;

  const _ProjectTasksTab({
    required this.project,
    required this.currentUser,
    this.onAddTask,
  });

  @override
  State<_ProjectTasksTab> createState() => _ProjectTasksTabState();
}

class _ProjectTasksTabState extends State<_ProjectTasksTab> {
  String _filter = 'all'; // all, todo, in_progress, done
  String _taskQuery = '';

  @override
  Widget build(BuildContext context) {
    final allTasks = widget.project.tasks;
    final filtered = allTasks.where((t) {
      final matchesFilter = switch (_filter) {
        'todo' => t.status == 'todo' || t.status == 'open',
        'in_progress' => t.status == 'in_progress',
        'done' => t.status == 'done' || t.status == 'completed',
        _ => true,
      };
      final matchesQuery = _taskQuery.isEmpty ||
          t.title.toLowerCase().contains(_taskQuery.toLowerCase()) ||
          t.description.toLowerCase().contains(_taskQuery.toLowerCase());
      return matchesFilter && matchesQuery;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        ResponsivePageContainer(
          maxWidth: kProjectsPageMaxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Add Task button
              SectionHeader(
                icon: Icons.task_alt_rounded,
                title: 'Project Tasks',
                trailing: widget.onAddTask != null
                    ? ElevatedButton.icon(
                        onPressed: widget.onAddTask,
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text(
                          'New Task',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeColors.unifiedPrimary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 14),

              // Filter & Search Row
              SoftCard(
                padding: const EdgeInsets.all(12),
                radius: 14,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _taskQuery = v),
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Search tasks...',
                          hintStyle: const TextStyle(fontSize: 12),
                          prefixIcon: const Icon(Icons.search_rounded, size: 18),
                          isDense: true,
                          filled: true,
                          fillColor: ThemeColors.unifiedInputBg,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Status filter tabs
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _filterButton('All', 'all'),
                          const SizedBox(width: 6),
                          _filterButton('To Do', 'todo'),
                          const SizedBox(width: 6),
                          _filterButton('In Progress', 'in_progress'),
                          const SizedBox(width: 6),
                          _filterButton('Done', 'done'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Tasks List or Empty State
              if (allTasks.isEmpty)
                const FriendlyEmptyState(
                  icon: Icons.task_alt_rounded,
                  message: ConstStrings.projectsNoTasks,
                  hint: 'Click "New Task" above to add the first task to this project.',
                )
              else if (filtered.isEmpty)
                const FriendlyEmptyState(
                  icon: Icons.search_off_rounded,
                  message: 'No tasks match current filter',
                  hint: 'Try changing the status filter or clearing search.',
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final task = filtered[i];
                    return _TaskListItem(
                      task: task,
                      project: widget.project,
                      canUpdate: widget.project.canManage ||
                          (widget.currentUser != null &&
                              task.assignedToId == widget.currentUser!.id),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filterButton(String label, String key) {
    final active = _filter == key;
    return InkWell(
      onTap: () => setState(() => _filter = key),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: active ? ThemeColors.unifiedPrimary : ThemeColors.unifiedInputBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: active ? FontWeight.w700 : FontWeight.w600,
            color: active ? Colors.white : ThemeColors.unifiedTextPrimary,
          ),
        ),
      ),
    );
  }
}

class _TaskListItem extends StatelessWidget {
  final ProjectTaskModel task;
  final ProjectModel project;
  final bool canUpdate;

  const _TaskListItem({
    required this.task,
    required this.project,
    required this.canUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = task.status == 'done';
    final progressColor = isDone
        ? ThemeColors.unifiedSuccess
        : task.progress >= 50
            ? ThemeColors.unifiedAccent
            : ThemeColors.unifiedPrimary;

    return SoftCard(
      padding: const EdgeInsets.all(14),
      radius: 14,
      onTap: canUpdate
          ? () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddTaskScreen(
                    projectId: project.id,
                    projectName: project.name,
                    departments: project.departments,
                    members: project.members,
                    task: task,
                    canUpdate: project.canManage,
                  ),
                ),
              );
            }
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Inline Checkbox
          InkWell(
            onTap: canUpdate
                ? () {
                    final nextStatus = isDone ? 'todo' : 'done';
                    final nextProgress = isDone ? 0 : 100;
                    context.read<ProjectBloc>().add(
                          UpdateProjectTask(
                            projectId: project.id,
                            taskId: task.id,
                            status: nextStatus,
                            progress: nextProgress,
                          ),
                        );
                  }
                : null,
            child: Container(
              margin: const EdgeInsets.only(top: 2, right: 12),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isDone
                    ? ThemeColors.unifiedSuccess
                    : ThemeColors.unifiedInputBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone
                      ? ThemeColors.unifiedSuccess
                      : ThemeColors.unifiedBorder,
                  width: 1.5,
                ),
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDone
                              ? ThemeColors.unifiedTextMuted
                              : ThemeColors.unifiedTextPrimary,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PriorityBadge(priority: task.priority, fontSize: 9.5),
                    const SizedBox(width: 6),
                    StatusBadge(status: task.status, fontSize: 9.5),
                  ],
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: ThemeColors.unifiedTextMuted,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 10),

                // Meta row: Assignee + Due Date + Progress
                Row(
                  children: [
                    if (task.assignedToName != null &&
                        task.assignedToName!.isNotEmpty) ...[
                      InitialsAvatar(name: task.assignedToName!, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        task.assignedToName!,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: ThemeColors.unifiedTextPrimary,
                        ),
                      ),
                      const SizedBox(width: 14),
                    ],
                    const Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: ThemeColors.unifiedTextMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      task.dueDate != null
                          ? DateFormat('MMM d, y').format(task.dueDate!)
                          : 'No deadline',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: ThemeColors.unifiedTextMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (task.progress > 0) ...[
                      SizedBox(
                        width: 70,
                        child: SoftProgressBar(
                          value: task.progress / 100,
                          color: progressColor,
                          height: 5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${task.progress}%',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: progressColor,
                        ),
                      ),
                    ],
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

class _ProjectBoardTab extends StatefulWidget {
  final ProjectModel project;
  final UserModel? currentUser;

  const _ProjectBoardTab({required this.project, required this.currentUser});

  @override
  State<_ProjectBoardTab> createState() => _ProjectBoardTabState();
}

class _ProjectBoardTabState extends State<_ProjectBoardTab> {
  int _boardType = 0; // 0: Tasks Kanban, 1: Tickets Kanban

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        children: [
          // Switcher between Task Kanban and Ticket Kanban
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: ThemeColors.unifiedInputBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    _toggleTab('Tasks Board (${widget.project.tasks.length})', 0),
                    _toggleTab('Tickets Board (${widget.project.tickets.length})', 1),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Board Content
          Expanded(
            child: _boardType == 0
                ? (widget.project.tasks.isEmpty
                    ? const FriendlyEmptyState(
                        icon: Icons.view_kanban_rounded,
                        message: 'No tasks yet',
                        hint: 'Add tasks to organize them on the Kanban board.',
                      )
                    : ProjectTaskKanbanBoard(
                        project: widget.project,
                        currentUser: widget.currentUser,
                        canManage: widget.project.canManage,
                      ))
                : (widget.project.tickets.isEmpty
                    ? const FriendlyEmptyState(
                        icon: Icons.confirmation_number_outlined,
                        message: 'No tickets linked to this project',
                        hint: 'Create or link tickets to see them here.',
                      )
                    : ProjectTicketsBoard(
                        tickets: widget.project.tickets,
                        user: widget.currentUser,
                      )),
          ),
        ],
      ),
    );
  }

  Widget _toggleTab(String label, int index) {
    final active = _boardType == index;
    return InkWell(
      onTap: () => setState(() => _boardType = index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? ThemeColors.unifiedSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
            color: active
                ? ThemeColors.unifiedPrimary
                : ThemeColors.unifiedTextMuted,
          ),
        ),
      ),
    );
  }
}

class _ProjectTeamTab extends StatelessWidget {
  final ProjectModel project;
  final bool canManage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProjectTeamTab({
    required this.project,
    required this.canManage,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        ResponsivePageContainer(
          maxWidth: kProjectsPageMaxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Team and Department Management
              TeamManagementSection(project: project, canManage: canManage),
              const SizedBox(height: 20),

              // Project Actions & Management (If allowed)
              if (canManage) ...[
                SoftCard(
                  padding: const EdgeInsets.all(16),
                  radius: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Project Management',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: ThemeColors.unifiedTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Modify project settings, milestones, dates or remove this project completely.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: ThemeColors.unifiedTextMuted,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: onEdit,
                              icon: const Icon(Icons.edit_rounded, size: 16),
                              label: const Text('Edit Project Details'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: onDelete,
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 16,
                                color: ThemeColors.unifiedDanger,
                              ),
                              label: const Text(
                                'Delete Project',
                                style: TextStyle(
                                  color: ThemeColors.unifiedDanger,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: ThemeColors.unifiedDanger,
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ProjectDetailDrawer extends StatelessWidget {
  final ProjectModel project;
  final UserModel? currentUser;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProjectDetailDrawer({
    required this.project,
    required this.currentUser,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 480,
      backgroundColor: ThemeColors.unifiedSurface,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                const Icon(
                  Icons.tune_rounded,
                  color: ThemeColors.unifiedPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Project Configuration',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: ThemeColors.unifiedTextPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              project.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: ThemeColors.unifiedTextPrimary,
              ),
            ),
            if (project.projectCode.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Code: ${project.projectCode}',
                style: const TextStyle(
                  fontSize: 12,
                  color: ThemeColors.unifiedTextMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 16),
            TeamManagementSection(
              project: project,
              canManage: project.canManage,
            ),
            const SizedBox(height: 20),
            if (project.canManage) ...[
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onEdit();
                },
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Edit Project Details'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onDelete();
                },
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: ThemeColors.unifiedDanger,
                ),
                label: const Text(
                  'Delete Project',
                  style: TextStyle(
                    color: ThemeColors.unifiedDanger,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: ThemeColors.unifiedDanger),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
