import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/constant/common_status.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/routes/routes_name.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/data/datasource/localstorage/sharedpreferences.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/projects/bloc/project_bloc.dart';
import 'package:tasknest/presentation/projects/bloc/project_event.dart';
import 'package:tasknest/presentation/projects/bloc/project_state.dart';
import 'package:tasknest/presentation/projects/model/project_models.dart';
import 'package:tasknest/presentation/projects/screens/add_task_screen.dart';
import 'package:tasknest/presentation/projects/screens/edit_project_screen.dart';
import 'package:tasknest/presentation/projects/widgets/UIhelpers.dart';
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
    return Scaffold(
      backgroundColor: ThemeColors.unifiedInputBg.withValues(alpha: 0.35),
      appBar: AppBar(
        backgroundColor: ThemeColors.unifiedSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          ConstStrings.projectsTitle,
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _load),
          const SizedBox(width: 4),
        ],
      ),
      body: BlocConsumer<ProjectBloc, ProjectState>(
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
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2.5),
            );
          }
          final project = state is ProjectDetailLoaded
              ? state.project
              : _lastProject;
          if (project == null) {
            return FriendlyEmptyState(
              icon: Icons.folder_off_rounded,
              message: ConstStrings.projectsNoData,
            );
          }
          return _ProjectDetailView(
            project: project,
            currentUserId: _currentUser?.id,
            onEdit: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EditProjectScreen(project: project),
                ),
              );
            },
            onDelete: () => _confirmDelete(context, project),
          );
        },
      ),
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

class _ProjectDetailView extends StatelessWidget {
  final ProjectModel project;
  final int? currentUserId;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _ProjectDetailView({
    required this.project,
    required this.currentUserId,
    required this.onEdit,
    required this.onDelete,
  });

  bool get _canManage => project.canManage;
  bool get _canEdit => project.canEdit;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 960;
        final teamColumn = <Widget>[
          _TeamSection(
            project: project,
            canManageMembers: _canManage,
            canManageObservers: project.canManageObservers,
            canManageDepartments: _canManage,
          ),
          if (_canEdit) ...[const SizedBox(height: 16), _actionsSection()],
        ];

        return ListView(
          padding: EdgeInsets.fromLTRB(16, 14, 16, 28),
          children: [
            ResponsivePageContainer(
              maxWidth: kProjectsPageMaxWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (project.isObserver) _observerBanner(),
                  _HeaderCard(project: project),
                  const SizedBox(height: 24),
                  _ticketsSection(context),
                  const SizedBox(height: 28),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _tasksSection(context),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: teamColumn,
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _tasksSection(context),
                        const SizedBox(height: 24),
                        ...teamColumn,
                      ],
                    ),
                ],
              ),
            ),
          ],
        );
      },
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

  Widget _ticketsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          icon: Icons.confirmation_number_outlined,
          title: '${ConstStrings.projectsTickets} (${project.tickets.length})',
          trailing: TextButton.icon(
            onPressed: () => _openNewTicket(context),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text(ConstStrings.projectsNewTicket),
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
          ),
        ),
        const SizedBox(height: 12),
        if (project.tickets.isEmpty)
          const FriendlyEmptyState(
            icon: Icons.confirmation_number_outlined,
            message: ConstStrings.projectsNoTickets,
          )
        else
          ProjectTicketsBoard(tickets: project.tickets),
      ],
    );
  }

  Widget _tasksSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          icon: Icons.task_alt_rounded,
          title: '${ConstStrings.projectsTasks} (${project.tasks.length})',
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
                  canUpdate:
                      _canManage ||
                      (currentUserId != null &&
                          task.assignedToId == currentUserId),
                  canManage: _canManage,
                ),
            ],
          ),
      ],
    );
  }

  Widget _actionsSection() {
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

  void _openNewTicket(BuildContext context) {
    context.go('${RouteNames.newTicket}?projectId=${project.id}');
  }
}

class _HeaderCard extends StatelessWidget {
  final ProjectModel project;
  const _HeaderCard({required this.project});

  @override
  Widget build(BuildContext context) {
    final deptNames = project.departments.map((d) => d.name).join(', ');
    final priorityColor = CommonStatus.ticketPriorityColor(project.priority);
    final (statusBg, statusFg, statusLabel) = switch (project.status) {
      'completed' => (
        ThemeColors.statusDoneBg,
        ThemeColors.statusDoneFg,
        'Completed',
      ),
      'on_hold' => (
        ThemeColors.statusProgressBg,
        ThemeColors.statusProgressFg,
        'On Hold',
      ),
      'in_progress' => (
        ThemeColors.statusProgressBg,
        ThemeColors.statusProgressFg,
        'In Progress',
      ),
      _ => (ThemeColors.statusOpenBg, ThemeColors.statusOpenFg, 'Active'),
    };

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
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: ThemeColors.unifiedTextPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
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
                bg: priorityColor.withValues(alpha: 0.12),
                fg: priorityColor,
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
          if (deptNames.isNotEmpty) ...[
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
                    deptNames,
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
                  color: ThemeColors.unifiedPrimary,
                  height: 9,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${project.progress}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: ThemeColors.unifiedPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ResponsiveCardGrid(
            maxColumns: 4,
            children: [
              _HeaderStat(
                icon: Icons.confirmation_number_outlined,
                value: '${project.tickets.length}',
                label: ConstStrings.projectsTickets,
                color: ThemeColors.unifiedPrimary,
              ),
              _HeaderStat(
                icon: Icons.task_alt_rounded,
                value: '${project.doneCount}/${project.taskCount}',
                label: 'Tasks done',
                color: ThemeColors.unifiedSuccess,
              ),
              _HeaderStat(
                icon: Icons.people_alt_rounded,
                value: '${project.members.length}',
                label: ConstStrings.projectsMembers,
                color: ThemeColors.unifiedSecondary,
              ),
              _HeaderStat(
                icon: Icons.apartment_rounded,
                value: '${project.departments.length}',
                label: ConstStrings.projectsDepartments,
                color: ThemeColors.unifiedAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _HeaderStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedInputBg.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.unifiedBorder.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: ThemeColors.unifiedTextPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: ThemeColors.unifiedTextMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamSection extends StatelessWidget {
  final ProjectModel project;
  final bool canManageMembers;
  final bool canManageObservers;
  final bool canManageDepartments;
  const _TeamSection({
    required this.project,
    required this.canManageMembers,
    required this.canManageObservers,
    required this.canManageDepartments,
  });

  Future<void> _addPeople(
    BuildContext context, {
    required String title,
    required Set<int> existingIds,
    required void Function(List<int> ids) onAdd,
  }) async {
    final ids = await showModalBottomSheet<List<int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddPeopleSheet(title: title, existingIds: existingIds),
    );
    if (ids == null || ids.isEmpty) return;
    onAdd(ids);
  }

  Future<void> _addDepartments(
    BuildContext context, {
    required String title,
    required Set<int> existingIds,
    required void Function(List<int> ids) onAdd,
  }) async {
    final ids = await showModalBottomSheet<List<int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          AddDepartmentsSheet(title: title, existingIds: existingIds),
    );
    if (ids == null || ids.isEmpty) return;
    onAdd(ids);
  }

  Future<void> _confirmRemove(
    BuildContext context,
    String label,
    VoidCallback onConfirm,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove'),
        content: Text('$label?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Remove',
              style: TextStyle(
                color: ThemeColors.unifiedDanger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (ok == true) onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TeamRow(
          icon: Icons.people_alt_rounded,
          title: '${ConstStrings.projectsMembers} (${project.members.length})',
          people: project.members.map((m) => m.name).toList(),
          ids: project.members.map((m) => m.id).toList(),
          canManage: canManageMembers,
          onAdd: canManageMembers
              ? () => _addPeople(
                  context,
                  title: ConstStrings.projectsAddMembers,
                  existingIds: project.members.map((m) => m.id).toSet(),
                  onAdd: (ids) => context.read<ProjectBloc>().add(
                    AddProjectMembers(projectId: project.id, userIds: ids),
                  ),
                )
              : null,
          onRemove: canManageMembers
              ? (userId) => _confirmRemove(
                  context,
                  'Remove this member',
                  () => context.read<ProjectBloc>().add(
                    RemoveProjectMember(projectId: project.id, userId: userId),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 10),
        _TeamRow(
          icon: Icons.visibility_rounded,
          title:
              '${ConstStrings.projectsObservers} (${project.observers.length})',
          people: project.observers.map((m) => m.name).toList(),
          ids: project.observers.map((m) => m.id).toList(),
          canManage: canManageObservers,
          onAdd: canManageObservers
              ? () => _addPeople(
                  context,
                  title: ConstStrings.projectsAddObservers,
                  existingIds: project.observers.map((m) => m.id).toSet(),
                  onAdd: (ids) => context.read<ProjectBloc>().add(
                    AddProjectObservers(projectId: project.id, userIds: ids),
                  ),
                )
              : null,
          onRemove: canManageObservers
              ? (userId) => _confirmRemove(
                  context,
                  'Remove this observer',
                  () => context.read<ProjectBloc>().add(
                    RemoveProjectObserver(
                      projectId: project.id,
                      userId: userId,
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 10),
        _TeamRow(
          icon: Icons.apartment_rounded,
          title:
              '${ConstStrings.projectsDepartments} (${project.departments.length})',
          people: project.departments.map((d) => d.name).toList(),
          ids: project.departments.map((d) => d.id).toList(),
          canManage: canManageDepartments,
          onAdd: canManageDepartments
              ? () => _addDepartments(
                  context,
                  title: ConstStrings.projectsAddDepartments,
                  existingIds: project.departments.map((d) => d.id).toSet(),
                  onAdd: (ids) => context.read<ProjectBloc>().add(
                    AddProjectDepartments(
                      projectId: project.id,
                      departmentIds: ids,
                    ),
                  ),
                )
              : null,
          onRemove: canManageDepartments
              ? (deptId) => _confirmRemove(
                  context,
                  'Remove this department',
                  () => context.read<ProjectBloc>().add(
                    RemoveProjectDepartment(
                      projectId: project.id,
                      departmentId: deptId,
                    ),
                  ),
                )
              : null,
        ),
      ],
    );
  }
}

class _TeamRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> people;
  final List<int> ids;
  final bool canManage;
  final VoidCallback? onAdd;
  final void Function(int id)? onRemove;
  const _TeamRow({
    required this.icon,
    required this.title,
    required this.people,
    required this.ids,
    required this.canManage,
    this.onAdd,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: icon,
            title: title,
            trailing: canManage && onAdd != null
                ? TextButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Add'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  )
                : null,
          ),
          if (people.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 10, left: 40),
              child: Text(
                'No one added yet',
                style: TextStyle(
                  color: ThemeColors.unifiedTextMuted,
                  fontSize: 12.5,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < people.length; i++)
                    _ChipWithRemove(
                      name: people[i],
                      onRemove: canManage && onRemove != null
                          ? () => onRemove!(ids[i])
                          : null,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ChipWithRemove extends StatelessWidget {
  final String name;
  final VoidCallback? onRemove;
  const _ChipWithRemove({required this.name, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 5,
        right: onRemove != null ? 4 : 11,
        top: 4,
        bottom: 4,
      ),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedInputBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: ThemeColors.unifiedBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InitialsAvatar(name: name, size: 22),
          const SizedBox(width: 7),
          Text(
            name,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 2),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onRemove,
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

class _TaskCard extends StatelessWidget {
  final ProjectTaskModel task;
  final bool canUpdate;
  final bool canManage;
  const _TaskCard({
    required this.task,
    required this.canUpdate,
    required this.canManage,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(14),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => _TaskDetailScreen(
              projectId: task.projectId,
              task: task,
              canUpdate: canUpdate,
              canManage: canManage,
            ),
          ),
        );
      },
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
          if (task.assignedToName != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                InitialsAvatar(name: task.assignedToName!, size: 18),
                const SizedBox(width: 6),
                Text(
                  task.assignedToName!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ThemeColors.unifiedTextMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SoftProgressBar(
                  value: task.progress / 100,
                  color: ThemeColors.unifiedPrimary,
                  height: 6,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${task.progress}%',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.unifiedTextMuted,
                ),
              ),
            ],
          ),
          if (task.commentCount > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 13,
                  color: ThemeColors.unifiedTextMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  '${task.commentCount} comment${task.commentCount == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: ThemeColors.unifiedTextMuted,
                  ),
                ),
              ],
            ),
          ],
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

class _TaskDetailScreen extends StatefulWidget {
  final int projectId;
  final ProjectTaskModel task;
  final bool canUpdate;
  final bool canManage;
  const _TaskDetailScreen({
    required this.projectId,
    required this.task,
    required this.canUpdate,
    required this.canManage,
  });

  @override
  State<_TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<_TaskDetailScreen> {
  final _commentCtrl = TextEditingController();
  int _progress = 0;
  String _status = 'todo';

  @override
  void initState() {
    super.initState();
    _progress = widget.task.progress;
    _status = widget.task.status;
    context.read<ProjectBloc>().add(
      LoadProjectComments(widget.projectId, widget.task.id),
    );
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  void _saveProgress() {
    context.read<ProjectBloc>().add(
      UpdateProjectTask(
        projectId: widget.projectId,
        taskId: widget.task.id,
        status: _status,
        progress: _progress,
      ),
    );
  }

  void _postComment() {
    final message = _commentCtrl.text.trim();
    if (message.isEmpty) return;
    context.read<ProjectBloc>().add(
      AddProjectComment(
        projectId: widget.projectId,
        taskId: widget.task.id,
        message: message,
      ),
    );
    _commentCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    return Scaffold(
      backgroundColor: ThemeColors.unifiedInputBg.withValues(alpha: 0.35),
      appBar: AppBar(
        backgroundColor: ThemeColors.unifiedSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      body: BlocListener<ProjectBloc, ProjectState>(
        listener: (context, state) {
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
          }
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            ResponsivePageContainer(
              maxWidth: kProjectsFormMaxWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (task.description.isNotEmpty) ...[
                    SoftCard(
                      padding: const EdgeInsets.all(14),
                      child: Text(
                        task.description,
                        style: const TextStyle(
                          color: ThemeColors.unifiedTextPrimary,
                          height: 1.4,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (widget.canUpdate) ...[
                    SoftCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${ConstStrings.projectsProgress}: $_progress%',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: ThemeColors.unifiedTextPrimary,
                            ),
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: ThemeColors.unifiedPrimary,
                              thumbColor: ThemeColors.unifiedPrimary,
                              overlayColor: ThemeColors.unifiedPrimary
                                  .withValues(alpha: 0.15),
                            ),
                            child: Slider(
                              value: _progress.toDouble(),
                              max: 100,
                              divisions: 20,
                              label: '$_progress%',
                              onChanged: (v) {
                                setState(() {
                                  _progress = v.round();
                                  _status = _progress >= 100
                                      ? 'done'
                                      : (_progress > 0
                                            ? 'in_progress'
                                            : 'todo');
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 4),
                          SegmentedButton<String>(
                            style: SegmentedButton.styleFrom(
                              selectedBackgroundColor:
                                  ThemeColors.unifiedPrimary,
                              selectedForegroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            segments: const [
                              ButtonSegment(
                                value: 'todo',
                                label: Text('To Do'),
                              ),
                              ButtonSegment(
                                value: 'in_progress',
                                label: Text('In Progress'),
                              ),
                              ButtonSegment(value: 'done', label: Text('Done')),
                            ],
                            selected: {_status},
                            onSelectionChanged: (s) {
                              setState(() {
                                _status = s.first;
                                if (_status == 'done') _progress = 100;
                                if (_status == 'todo') _progress = 0;
                              });
                            },
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ThemeColors.unifiedPrimary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _saveProgress,
                              child: const Text(
                                'Update Status',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  SectionHeader(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Comments',
                    trailing: BlocBuilder<ProjectBloc, ProjectState>(
                      builder: (context, state) {
                        final count =
                            state is ProjectCommentsLoaded &&
                                state.taskId == task.id
                            ? state.comments.length
                            : 0;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: ThemeColors.unifiedInputBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: ThemeColors.unifiedTextMuted,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  BlocBuilder<ProjectBloc, ProjectState>(
                    builder: (context, state) {
                      if (state is ProjectCommentsLoaded &&
                          state.taskId == task.id) {
                        if (state.comments.isEmpty) {
                          return const FriendlyEmptyState(
                            icon: Icons.chat_bubble_outline_rounded,
                            message: 'No comments yet',
                          );
                        }
                        return Column(
                          children: [
                            for (final c in state.comments)
                              _CommentTile(comment: c),
                          ],
                        );
                      }
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      );
                    },
                  ),
                  if (widget.canUpdate) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _commentCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Add a comment',
                        hintText: 'Write a comment…',
                        filled: true,
                        fillColor: ThemeColors.unifiedSurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: ThemeColors.unifiedBorder,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: ThemeColors.unifiedBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: ThemeColors.unifiedPrimary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeColors.unifiedPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _postComment,
                        child: const Text(
                          'Post Comment',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final ProjectCommentModel comment;
  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.unifiedBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InitialsAvatar(name: comment.userName, size: 30),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.userName,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: ThemeColors.unifiedPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  comment.message,
                  style: const TextStyle(
                    color: ThemeColors.unifiedTextPrimary,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
