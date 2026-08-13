import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:tasknest/presentation/projects/widgets/ui_helpers.dart';
import 'package:tasknest/presentation/projects/widgets/project_tickets_board.dart';
import 'package:tasknest/presentation/projects/widgets/team_manage_sheets.dart';

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
          if (state.message.contains('deleted')) {
            Navigator.of(context).pop();
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
            backgroundColor: ThemeColors.unifiedInputBg.withValues(alpha: 0.35),
            appBar: _appBar(),
            body: const Center(
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          );
        }
        final project = state is ProjectDetailLoaded
            ? state.project
            : _lastProject;
        if (project == null) {
          return Scaffold(
            backgroundColor: ThemeColors.unifiedInputBg.withValues(alpha: 0.35),
            appBar: _appBar(),
            body: FriendlyEmptyState(
              icon: Icons.folder_off_rounded,
              message: ConstStrings.projectsNoData,
            ),
          );
        }
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: ThemeColors.unifiedInputBg.withValues(alpha: 0.35),
          appBar: _appBar(),
          endDrawer: _ProjectDrawer(
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
          body: _ProjectDetailView(
            project: project,
            currentUser: _currentUser,
          ),
        );
      },
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: ThemeColors.unifiedSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: const Text(
        ConstStrings.projectsTitle,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.tune_rounded, size: 22),
          tooltip: 'Members, actions & tasks',
          onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded, size: 22),
          onPressed: _load,
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  void _confirmDelete(BuildContext context, ProjectModel project) {
    final bloc = context.read<ProjectBloc>();
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(ConstStrings.projectsDelete),
        content: Text('Delete "${project.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: ThemeColors.unifiedDanger,
                fontWeight: FontWeight.w700,
              ),
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
}

class _ProjectDetailView extends StatefulWidget {
  final ProjectModel project;
  final UserModel? currentUser;

  const _ProjectDetailView({
    required this.project,
    required this.currentUser,
  });

  @override
  State<_ProjectDetailView> createState() => _ProjectDetailViewState();
}

class _ProjectDetailViewState extends State<_ProjectDetailView> {
  void _openNewTicket() {
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

  bool get _canManage => widget.project.canManage;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        ResponsivePageContainer(
          maxWidth: kProjectsPageMaxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.project.isObserver) _observerBanner(),
              _HeaderCard(project: widget.project),
              const SizedBox(height: 24),
              _ticketsSection(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _observerBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: ThemeColors.statusOpenBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.visibility_rounded,
            color: ThemeColors.statusOpenFg,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              ConstStrings.projectsObserverBanner,
              style: TextStyle(
                color: ThemeColors.statusOpenFg,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _ticketsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          icon: Icons.confirmation_number_outlined,
          title:
              '${ConstStrings.projectsTickets} (${widget.project.tickets.length})',
          trailing: TextButton.icon(
            onPressed: _canManage ? _openNewTicket : null,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text(ConstStrings.projectsNewTicket),
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
          ),
        ),
        const SizedBox(height: 12),
        if (widget.project.tickets.isEmpty)
          const FriendlyEmptyState(
            icon: Icons.confirmation_number_outlined,
            message: ConstStrings.projectsNoTickets,
          )
        else
          ProjectTicketsBoard(
            tickets: widget.project.tickets,
            user: widget.currentUser,
          ),
      ],
    );
  }
}

class _ProjectDrawer extends StatelessWidget {
  final ProjectModel project;
  final UserModel? currentUser;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _ProjectDrawer({
    required this.project,
    required this.currentUser,
    required this.onEdit,
    required this.onDelete,
  });

  bool get _canEdit => project.canEdit;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 520,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Row(
              children: [
                const Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: ThemeColors.unifiedPrimary,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Project details',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: ThemeColors.unifiedTextPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _TeamSection(project: project),
            if (_canEdit) ...[
              const SizedBox(height: 16),
              _ActionsSection(onEdit: onEdit, onDelete: onDelete),
            ],
            const SizedBox(height: 16),
            _TasksSection(project: project, currentUser: currentUser),
          ],
        ),
      ),
    );
  }
}

class _TasksSection extends StatelessWidget {
  final ProjectModel project;
  final UserModel? currentUser;
  const _TasksSection({required this.project, this.currentUser});

  bool get _canManage => project.canManage;

  void _showAddTaskSheet(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddTaskScreen(
          projectId: project.id,
          projectName: project.name,
          departments: project.departments,
          members: project.members,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          icon: Icons.task_alt_rounded,
          title: ConstStrings.projectsTasks,
          trailing: _canManage
              ? TextButton.icon(
                  onPressed: () => _showAddTaskSheet(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text(ConstStrings.projectsAddTask),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 12),
        if (project.tasks.isEmpty)
          const FriendlyEmptyState(
            icon: Icons.task_alt_rounded,
            message: ConstStrings.projectsNoTasks,
          )
        else
          ResponsiveCardGrid(
            maxColumns: 2,
            children: [
              for (final task in project.tasks)
                _TaskCard(
                  task: task,
                  project: project,
                  canUpdate: _canManage ||
                      (currentUser != null &&
                          task.assignedToId == currentUser!.id),
                ),
            ],
          ),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final ProjectModel project;
  const _HeaderCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final statusBg = ThemeColors.statusOpenBg;
    final statusFg = ThemeColors.statusOpenFg;
    final statusLabel = 'Active';

    final (priorityBg, priorityFg) = switch (project.priority) {
      'high' => (ThemeColors.priorityHighBg, ThemeColors.priorityHighFg),
      'urgent' => (ThemeColors.priorityUrgentBg, ThemeColors.priorityUrgentFg),
      'low' => (ThemeColors.priorityLowBg, ThemeColors.priorityLowFg),
      _ => (ThemeColors.priorityMedBg, ThemeColors.priorityMedFg),
    };

    final (progressColor, _) = project.progress >= 100
        ? (ThemeColors.unifiedSuccess, 'Complete')
        : project.progress >= 50
            ? (ThemeColors.unifiedAccent, 'In Progress')
            : (ThemeColors.unifiedPrimary, 'To Do');

    return SoftCard(
      padding: const EdgeInsets.all(18),
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
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: ThemeColors.unifiedTextPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (project.projectCode.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: ThemeColors.statusOpenBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    project.projectCode,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: ThemeColors.statusOpenFg,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              DotPill(label: statusLabel, bg: statusBg, fg: statusFg),
              DotPill(
                label: project.priority.toUpperCase(),
                bg: priorityBg,
                fg: priorityFg,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InitialsAvatar(name: project.createdByName, size: 20),
                  const SizedBox(width: 7),
                  Text(
                    '${ConstStrings.projectsCreatedBy} ${project.createdByName}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: ThemeColors.unifiedTextMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (project.description.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              project.description,
              style: const TextStyle(
                color: ThemeColors.unifiedTextPrimary,
                height: 1.45,
                fontSize: 13.5,
              ),
            ),
          ],
          if (project.departments.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.apartment_rounded,
                  size: 14,
                  color: ThemeColors.unifiedTextMuted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    project.departments.map((d) => d.name).join(', '),
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: ThemeColors.unifiedTextMuted,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SoftProgressBar(
                  value: project.progress / 100,
                  color: progressColor,
                  height: 9,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${project.progress}%',
                style: TextStyle(
                  fontSize: 13,
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

class _TeamSection extends StatelessWidget {
  final ProjectModel project;
  const _TeamSection({required this.project});

  bool get _canManage => project.canManage;

  Future<void> _addPeople(
    BuildContext context, {
    required String title,
    required Set<int> existingIds,
    required bool isObserver,
  }) async {
    final bloc = context.read<ProjectBloc>();
    final result = await showModalBottomSheet<List<int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddPeopleSheet(title: title, existingIds: existingIds),
    );
    if (result == null || result.isEmpty) return;
    bloc.add(
      isObserver
          ? AddProjectObservers(projectId: project.id, userIds: result)
          : AddProjectMembers(projectId: project.id, userIds: result),
    );
  }

  void _removePeople(
    BuildContext context, {
    required bool isObserver,
    required int userId,
  }) {
    context.read<ProjectBloc>().add(
      isObserver
          ? RemoveProjectObserver(projectId: project.id, userId: userId)
          : RemoveProjectMember(projectId: project.id, userId: userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final members = project.members;
    final observers = project.observers;

    return SoftCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.group_rounded,
            title: ConstStrings.projectsMembers,
            trailing: _canManage
                ? _AddButton(
                    onPressed: () => _addPeople(
                      context,
                      title: 'Add members',
                      existingIds: {for (final m in members) m.id},
                      isObserver: false,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          if (members.isEmpty)
            const FriendlyEmptyState(
              icon: Icons.person_outline_rounded,
              message: 'No members assigned.',
              hint: 'Members will appear here once added.',
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in members)
                  _PeopleChip(
                    name: m.name,
                    color: ThemeColors.unifiedPrimary,
                    onRemove: _canManage
                        ? () => _removePeople(
                              context,
                              isObserver: false,
                              userId: m.id,
                            )
                        : null,
                  ),
              ],
            ),
          const SizedBox(height: 16),
          SectionHeader(
            icon: Icons.visibility_outlined,
            title: ConstStrings.projectsObservers,
            trailing: _canManage
                ? _AddButton(
                    onPressed: () => _addPeople(
                      context,
                      title: 'Add observers',
                      existingIds: {for (final o in observers) o.id},
                      isObserver: true,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          if (observers.isEmpty)
            const FriendlyEmptyState(
              icon: Icons.visibility_outlined,
              message: 'No observers.',
              hint: 'Observers can view the project.',
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final o in observers)
                  _PeopleChip(
                    name: o.name,
                    color: ThemeColors.unifiedAccent,
                    onRemove: _canManage
                        ? () => _removePeople(
                              context,
                              isObserver: true,
                              userId: o.id,
                            )
                        : null,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _PeopleChip extends StatelessWidget {
  final String name;
  final Color color;
  final VoidCallback? onRemove;
  const _PeopleChip({
    required this.name,
    required this.color,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 11,
        top: 7,
        bottom: 7,
        right: onRemove != null ? 6 : 11,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InitialsAvatar(name: name, size: 24),
          const SizedBox(width: 7),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: ThemeColors.unifiedTextPrimary,
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 4),
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: ThemeColors.unifiedTextMuted,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _AddButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add_rounded, size: 18),
      label: const Text('Add'),
      style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
    );
  }
}

class _ActionsSection extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _ActionsSection({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Project actions',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: ThemeColors.unifiedTextMuted,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text(ConstStrings.projectsEdit),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: ThemeColors.unifiedDanger),
                  ),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: ThemeColors.unifiedDanger,
                    size: 18,
                  ),
                  label: const Text(
                    ConstStrings.projectsDelete,
                    style: TextStyle(
                      color: ThemeColors.unifiedDanger,
                      fontWeight: FontWeight.w700,
                    ),
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

class _TaskCard extends StatelessWidget {
  final ProjectTaskModel task;
  final ProjectModel project;
  final bool canUpdate;
  const _TaskCard({
    required this.task,
    required this.project,
    required this.canUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: ThemeColors.unifiedTextPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _TaskStatusChip(status: task.status),
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
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 12,
                color: ThemeColors.unifiedTextMuted,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  task.dueDate != null
                      ? '${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}'
                      : 'No due date',
                  style: const TextStyle(
                    fontSize: 12,
                    color: ThemeColors.unifiedTextMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (task.progress > 0) ...[
                const SizedBox(width: 8),
                SoftProgressBar(
                  value: task.progress / 100,
                  color: ThemeColors.unifiedPrimary,
                  height: 4,
                ),
                const SizedBox(width: 4),
                Text(
                  '${task.progress}%',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: ThemeColors.unifiedPrimary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TaskStatusChip extends StatelessWidget {
  final String status;
  const _TaskStatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (status) {
      'done' => (ThemeColors.statusDoneBg, ThemeColors.statusDoneFg, 'Done'),
      'in_progress' => (
        ThemeColors.statusProgressBg,
        ThemeColors.statusProgressFg,
        'In Progress',
      ),
      _ => (ThemeColors.statusOpenBg, ThemeColors.statusOpenFg, 'To Do'),
    };
    return DotPill(label: label, bg: bg, fg: fg, fontSize: 10.5);
  }
}
