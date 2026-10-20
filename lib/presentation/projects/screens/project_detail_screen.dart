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
import 'package:tasknest/presentation/projects/screens/edit_project_screen.dart';
import 'package:tasknest/presentation/projects/widgets/gantt_chart.dart';
import 'package:tasknest/presentation/projects/widgets/project_stats_section.dart';
import 'package:tasknest/presentation/projects/widgets/project_task_board.dart';
import 'package:tasknest/presentation/projects/widgets/team_management_section.dart';
import 'package:tasknest/presentation/projects/widgets/ui_helpers.dart';
import 'package:tasknest/presentation/projects/screens/project_list_screen.dart';

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

  void _load() =>
      context.read<ProjectBloc>().add(LoadProjectDetail(widget.projectId));

  void _confirmDelete(BuildContext ctx, ProjectModel project) {
    final bloc = ctx.read<ProjectBloc>();
    showDialog<bool>(
      context: ctx,
      builder: (dCtx) => _DeleteDialog(projectName: project.name),
    ).then((confirmed) {
      if (confirmed == true) bloc.add(DeleteProjectEvent(project.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProjectBloc, ProjectState>(
      listener: (ctx, state) {
        if (state is ProjectDetailLoaded) _lastProject = state.project;
        if (state is ProjectActionSuccess) {
          _showSnack(ctx, state.message, ThemeColors.unifiedSuccess);
          if (state.message.toLowerCase().contains('deleted')) {
            Navigator.of(ctx).pop();
          } else {
            _load();
          }
        }
        if (state is ProjectActionError) {
          _showSnack(ctx, state.message, ThemeColors.unifiedDanger);
        }
      },
      builder: (ctx, state) {
        if (state is ProjectLoading && _lastProject == null) {
          return Scaffold(
            backgroundColor: ThemeColors.unifiedBackground,
            appBar: _buildAppBar(title: 'Loading...'),
            body: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
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
            appBar: _buildAppBar(title: 'Not found'),
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
            project: project,
            onOpenDrawer: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),
          endDrawer: _DetailsDrawer(
            project: project,
            currentUser: _currentUser,
            onEdit: () => _openEdit(project),
            onDelete: () => _confirmDelete(ctx, project),
          ),
          body: Column(
            children: [
              if (project.isObserver) const _ObserverBanner(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    children: [
                      // Header card with progress + meta
                      _ProjectHeaderCard(
                        project: project,
                        onNewTicket: project.canEdit
                            ? () => _openNewTicket(project)
                            : null,
                        onEdit: project.canEdit
                            ? () => _openEdit(project)
                            : null,
                        onOpenView: (title, child) => _openView(title, child),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ProjectTaskBoard(
                          project: project,
                          currentUser: _currentUser,
                          onNewTicket: () => _openNewTicket(project),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openNewTicket(ProjectModel project) {
    if (_currentUser == null) return;
    final bloc = context.read<ProjectBloc>();
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => CreateTicketView(
              user: _currentUser!,
              initialProjectId: project.id,
            ),
          ),
        )
        .then((_) => bloc.add(LoadProjectDetail(project.id)));
  }

  void _openEdit(ProjectModel project) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EditProjectScreen(project: project)),
    );
  }

  void _openView(String title, Widget child) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: ThemeColors.unifiedBackground,
          appBar: AppBar(
            backgroundColor: ThemeColors.unifiedSurface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, size: 20),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: ThemeColors.unifiedTextPrimary,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0.5),
              child: Container(height: 0.5, color: ThemeColors.unifiedBorder),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: child,
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar({
    required String title,
    String? projectCode,
    ProjectModel? project,
    VoidCallback? onOpenDrawer,
  }) {
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
          if (project != null) ...[
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      kProjectPalettes[project.id % kProjectPalettes.length],
                ),
                borderRadius: BorderRadius.circular(7),
              ),
              alignment: Alignment.center,
              child: Text(
                title.isNotEmpty ? title[0].toUpperCase() : 'P',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              title,
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
          if (projectCode != null && projectCode.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: ThemeColors.unifiedInputBg,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: ThemeColors.unifiedBorder,
                  width: 0.8,
                ),
              ),
              child: Text(
                projectCode,
                style: const TextStyle(
                  fontSize: 10,
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
          icon: const Icon(Icons.refresh_rounded, size: 19),
          onPressed: _load,
          tooltip: 'Refresh',
        ),
        if (onOpenDrawer != null)
          IconButton(
            icon: const Icon(Icons.tune_rounded, size: 19),
            onPressed: onOpenDrawer,
            tooltip: 'Details',
          ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(0.5),
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

// ── Project header card ───────────────────────────────────────────────────────
class _ProjectHeaderCard extends StatelessWidget {
  final ProjectModel project;
  final VoidCallback? onNewTicket;
  final VoidCallback? onEdit;
  final void Function(String, Widget) onOpenView;

  const _ProjectHeaderCard({
    required this.project,
    required this.onNewTicket,
    required this.onEdit,
    required this.onOpenView,
  });

  String _dateRange() {
    final fmt = DateFormat('MMM d, y');
    final s = project.startDate;
    final e = project.endDate;
    if (s == null && e == null) return 'No dates';
    if (s != null && e != null) return '${fmt.format(s)} – ${fmt.format(e)}';
    if (s != null) return 'From ${fmt.format(s)}';
    return 'Due ${fmt.format(e!)}';
  }

  @override
  Widget build(BuildContext context) {
    final done = project.tickets.where((t) => t.status == 'closed').length;
    final total = project.tickets.length;
    final progress = total == 0 ? 0 : ((done / total) * 100).round();
    final pColor = progress >= 100
        ? ThemeColors.unifiedSuccess
        : progress >= 50
        ? ThemeColors.unifiedAccent
        : ThemeColors.unifiedPrimary;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ThemeColors.unifiedBorder, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (project.projectCode.isNotEmpty)
                      _MetaChip(
                        project.projectCode,
                        color: ThemeColors.unifiedPrimary,
                      ),
                    StatusBadge(status: project.status, fontSize: 10),
                    PriorityBadge(priority: project.priority, fontSize: 10),
                  ],
                ),
              ),
              // Views popup
              _ViewsMenu(project: project, onOpenView: onOpenView),
              if (onNewTicket != null) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onNewTicket,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeColors.unifiedPrimary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'New ticket',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (onEdit != null) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onEdit,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: ThemeColors.unifiedInputBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: ThemeColors.unifiedBorder,
                        width: 0.8,
                      ),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 15,
                      color: ThemeColors.unifiedTextMuted,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 6,
                    backgroundColor: pColor.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(pColor),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$progress%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: pColor,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: ThemeColors.unifiedInputBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$done/$total done',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: ThemeColors.unifiedTextMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              if (project.departments.isNotEmpty)
                _MetaInfo(
                  Icons.apartment_rounded,
                  project.departments.map((d) => d.name).join(', '),
                ),
              _MetaInfo(Icons.calendar_today_rounded, _dateRange()),
              _MetaInfo(
                Icons.person_outline_rounded,
                'By ${project.createdByName}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final Color color;
  const _MetaChip(this.label, {required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

class _MetaInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaInfo(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: ThemeColors.unifiedTextMuted),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: ThemeColors.unifiedTextMuted,
          ),
        ),
      ],
    );
  }
}

class _ViewsMenu extends StatelessWidget {
  final ProjectModel project;
  final void Function(String, Widget) onOpenView;
  const _ViewsMenu({required this.project, required this.onOpenView});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'More views',
      offset: const Offset(0, 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (v) {
        switch (v) {
          case 'overview':
            onOpenView('Overview', ProjectStatsSection(project: project));
          case 'timeline':
            onOpenView(
              'Timeline',
              SizedBox(
                height: 520,
                width: double.infinity,
                child: GanttChart(project: project),
              ),
            );
          case 'team':
            onOpenView(
              'Team (${project.members.length})',
              TeamManagementSection(
                project: project,
                canManage: project.canManage,
              ),
            );
        }
      },
      itemBuilder: (_) => [
        _menuItem('overview', Icons.analytics_outlined, 'Overview'),
        _menuItem('timeline', Icons.view_timeline_outlined, 'Timeline'),
        _menuItem(
          'team',
          Icons.group_outlined,
          'Team (${project.members.length})',
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: ThemeColors.unifiedInputBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ThemeColors.unifiedBorder, width: 0.8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.grid_view_rounded,
              size: 14,
              color: ThemeColors.unifiedTextMuted,
            ),
            SizedBox(width: 5),
            Text(
              'Views',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: ThemeColors.unifiedTextMuted,
              ),
            ),
            SizedBox(width: 3),
            Icon(
              Icons.expand_more_rounded,
              size: 14,
              color: ThemeColors.unifiedTextMuted,
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 16, color: ThemeColors.unifiedTextMuted),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

// ── Observer banner ───────────────────────────────────────────────────────────
class _ObserverBanner extends StatelessWidget {
  const _ObserverBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: ThemeColors.statusOpenBg,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: const Row(
        children: [
          Icon(
            Icons.visibility_rounded,
            color: ThemeColors.statusOpenFg,
            size: 15,
          ),
          SizedBox(width: 8),
          Expanded(
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

// ── Delete dialog ─────────────────────────────────────────────────────────────
class _DeleteDialog extends StatelessWidget {
  final String projectName;
  const _DeleteDialog({required this.projectName});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: ThemeColors.unifiedDanger,
            size: 20,
          ),
          SizedBox(width: 8),
          Text(
            'Delete project',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          ),
        ],
      ),
      content: Text('Delete "$projectName"? This cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: ThemeColors.unifiedDanger,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
          ),
          child: const Text(
            'Delete',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

// ── Details drawer ────────────────────────────────────────────────────────────
class _DetailsDrawer extends StatelessWidget {
  final ProjectModel project;
  final UserModel? currentUser;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DetailsDrawer({
    required this.project,
    required this.currentUser,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 420,
      backgroundColor: ThemeColors.unifiedSurface,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          kProjectPalettes[project.id %
                              kProjectPalettes.length],
                    ),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    project.name.isNotEmpty
                        ? project.name[0].toUpperCase()
                        : 'P',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    project.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: ThemeColors.unifiedTextPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (project.projectCode.isNotEmpty)
              Text(
                'Code: ${project.projectCode}',
                style: const TextStyle(
                  fontSize: 11,
                  color: ThemeColors.unifiedTextMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            Container(
              height: 0.5,
              color: ThemeColors.unifiedBorder,
              margin: const EdgeInsets.symmetric(vertical: 16),
            ),
            TeamManagementSection(
              project: project,
              canManage: project.canManage,
            ),
            if (project.canManage) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onEdit();
                },
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: const Text('Edit project'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onDelete();
                },
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 16,
                  color: ThemeColors.unifiedDanger,
                ),
                label: const Text(
                  'Delete project',
                  style: TextStyle(
                    color: ThemeColors.unifiedDanger,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: ThemeColors.unifiedDanger),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
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
