import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/common_status.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/domain/repositories_impl/project_impl/project_impl.dart';
import 'package:tasknest/domain/repositories_impl/ticket_impl/ticket_impl.dart';
import 'package:tasknest/injection.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/projects/bloc/project_bloc.dart';
import 'package:tasknest/presentation/projects/bloc/project_event.dart';
import 'package:tasknest/presentation/projects/model/project_models.dart';
import 'package:tasknest/presentation/projects/widgets/member_stack.dart';
import 'package:tasknest/presentation/projects/widgets/project_ticket_detail_dialog.dart';
import 'package:tasknest/presentation/projects/widgets/ui_helpers.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

/// Trello list names for the three ticket statuses.
String _listLabel(String status) => switch (status) {
      'open' => 'To Do',
      'in_progress' => 'In Progress',
      'closed' => 'Done',
      _ => CommonStatus.statusLabel(status),
    };

/// Trello style task board for a project.
///
/// Columns are the three lists (`To Do`, `In Progress`, `Done`). Every card
/// is draggable — dropping it on another list moves the task instantly with
/// no remarks, ownership checks or reopen limits, then reloads the project.
class ProjectTaskBoard extends StatefulWidget {
  final ProjectModel project;
  final UserModel? currentUser;
  final ValueChanged<String> onNewTask;

  const ProjectTaskBoard({
    super.key,
    required this.project,
    required this.currentUser,
    required this.onNewTask,
  });

  @override
  State<ProjectTaskBoard> createState() => _ProjectTaskBoardState();
}

class _ProjectTaskBoardState extends State<ProjectTaskBoard> {
  String _query = '';
  String _filter = 'all'; // all | overdue | open | in_progress | closed
  int? _busyId;

  /// Optimistic status overrides so a dropped card moves instantly while the
  /// reload is in flight. Cleared as soon as fresh project data arrives.
  final Map<int, String> _overrides = {};

  @override
  void didUpdateWidget(covariant ProjectTaskBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.project, widget.project)) {
      _overrides.clear();
      _busyId = null;
    }
  }

  String _statusOf(TicketModel t) => _overrides[t.id] ?? t.status;

  bool _textMatches(TicketModel t) {
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return t.title.toLowerCase().contains(q) ||
        t.ticketNumber.toLowerCase().contains(q) ||
        t.description.toLowerCase().contains(q);
  }

  bool _isOverdue(TicketModel t) =>
      t.dueDate != null &&
      t.dueDate!.isBefore(DateTime.now()) &&
      t.status != 'closed';

  bool _filterMatches(TicketModel t) {
    switch (_filter) {
      case 'overdue':
        return _isOverdue(t);
      case 'open':
      case 'in_progress':
      case 'closed':
        return _statusOf(t) == _filter;
      default:
        return true;
    }
  }

  void _reload() {
    if (!mounted) return;
    context.read<ProjectBloc>().add(LoadProjectDetail(widget.project.id));
  }

  void _openTicket(int id) {
    final user = widget.currentUser;
    if (user == null) {
      _snack('Your session is still loading. Try again in a moment.',
          error: true);
      return;
    }

    showProjectTicketDetailDialog(
      context,
      ticketId: id,
      user: user,
      projectTeam: widget.project.members,
    ).then((_) => _reload());
  }

  /// Trello's board menu: list the archived cards and restore any of them.
  Future<void> _openArchived() async {
    final user = widget.currentUser;
    if (user == null) return;

    List<ArchivedTaskModel> items;
    try {
      items = await sl<ProjectRepositoryImpl>()
          .getArchivedTasks(widget.project.id);
    } catch (e) {
      if (mounted) _snack(_friendlyError(e), error: true);
      return;
    }
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.archive_outlined,
                size: 20, color: ThemeColors.unifiedTextMuted),
            SizedBox(width: 8),
            Text('Archived tasks'),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: items.isEmpty
              ? const Text(
                  'No archived tasks yet.',
                  style: TextStyle(
                    fontSize: 13,
                    color: ThemeColors.unifiedTextMuted,
                  ),
                )
              : SizedBox(
                  height: 320,
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final a = items[index];
                      return ListTile(
                        dense: true,
                        title: Text(
                          a.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          a.ticketNumber,
                          style: const TextStyle(
                            fontSize: 11,
                            color: ThemeColors.unifiedTextMuted,
                          ),
                        ),
                        trailing: TextButton(
                          onPressed: () async {
                            try {
                              await sl<TicketRepositoryImpl>()
                                  .unarchiveTicket(a.id);
                              if (dialogContext.mounted) {
                                Navigator.pop(dialogContext);
                              }
                              if (mounted) {
                                _snack('Task restored to the board.');
                                _reload();
                              }
                            } catch (e) {
                              if (mounted) _snack(_friendlyError(e), error: true);
                            }
                          },
                          child: const Text('Restore'),
                        ),
                      );
                    },
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _snack(String message, {bool error = false, bool neutral = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: neutral
              ? ThemeColors.unifiedTextPrimary
              : error
                  ? ThemeColors.unifiedDanger
                  : ThemeColors.unifiedSuccess,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  String _friendlyError(Object e) {
    final raw = e.toString();
    final match = RegExp(r'Exception\((.*)\)', dotAll: true).firstMatch(raw);
    final message = match != null ? match.group(1)! : raw;
    return message.isEmpty ? 'The move could not be saved.' : message;
  }

  /// Trello-style move: drop a card on any list and it just moves — no
  /// ownership checks, closing remarks or reopen limits.
  Future<void> _move(TicketModel t, String target) async {
    final current = _statusOf(t);
    if (current == target) return;

    if (widget.currentUser == null) {
      _snack('Your session is still loading. Try again in a moment.',
          error: true);
      return;
    }
    if (widget.project.isObserver) {
      _snack('You do not have permission to move tasks in this project.',
          error: true);
      return;
    }

    setState(() {
      _overrides[t.id] = target;
      _busyId = t.id;
    });

    try {
      await sl<TicketRepositoryImpl>().updateStatus(t.id, target);

      if (mounted) {
        setState(() => _busyId = null);
      }
      _reload();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _overrides.remove(t.id);
        _busyId = null;
      });
      _snack(_friendlyError(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.currentUser;
    if (user == null) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: ThemeColors.unifiedPrimary,
        ),
      );
    }

    final tickets = widget.project.tickets;
    final visible = tickets.where((t) => _filterMatches(t) && _textMatches(t)).toList();

    final overdueCount = tickets.where(_isOverdue).length;

    final grouped = <String, List<TicketModel>>{
      for (final s in CommonStatus.statuses) s: [],
    };
    for (final t in visible) {
      final key = _statusOf(t);
      (grouped[key] ??= []).add(t);
    }
    for (final entry in grouped.entries) {
      entry.value.sort((a, b) {
        final oa = _isOverdue(a);
        final ob = _isOverdue(b);
        if (oa != ob) return oa ? -1 : 1;
        final p = CommonStatus.priorityWeight(a.priority)
            .compareTo(CommonStatus.priorityWeight(b.priority));
        if (p != 0) return p;
        return b.createdAt.compareTo(a.createdAt);
      });
    }

    return Column(
      children: [
        _Toolbar(
          query: _query,
          filter: _filter,
          total: tickets.length,
          overdue: overdueCount,
          canMove: !widget.project.isObserver,
          canCreateTask: !widget.project.isObserver || widget.project.canEdit,
          counts: {
            for (final s in CommonStatus.statuses)
              s: tickets.where((t) => _statusOf(t) == s).length,
          },
          onQuery: (v) => setState(() => _query = v),
          onFilter: (v) => setState(() => _filter = v),
          onArchived: _openArchived,
          onNewTask: widget.onNewTask,
        ),
        const SizedBox(height: 10),
        Expanded(
          child: tickets.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.view_kanban_rounded,
                      size: 46,
                      color: ThemeColors.unifiedTextMuted,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No tasks on this board yet',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: ThemeColors.unifiedTextMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.project.canEdit
                          ? 'Create a ticket and it will show up in this board.'
                          : 'Tasks will appear here once tickets are created.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: ThemeColors.unifiedTextMuted,
                      ),
                    ),
                    if (widget.project.canEdit) ...[
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: () => widget.onNewTask('open'),
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Add task'),
                      ),
                    ],
                  ],
                ),
              )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final outer = constraints.maxHeight.isFinite
                        ? constraints.maxHeight
                        : 560.0;
                    final height = outer - 28;
                    return Container(
                      width: double.infinity,
                      height: outer,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ThemeColors.unifiedGradStart.withValues(alpha: 0.12),
                            ThemeColors.unifiedAccent.withValues(alpha: 0.06),
                            ThemeColors.unifiedGradEnd.withValues(alpha: 0.12),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color:
                              ThemeColors.unifiedBorder.withValues(alpha: 0.55),
                        ),
                      ),
                      child: SizedBox(
                        height: height,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (final status in CommonStatus.statuses) ...[
                                _BoardColumn(
                                  status: status,
                                  label: _listLabel(status),
                                  color: CommonStatus.columnColor(status),
                                  tickets: grouped[status] ?? const [],
                                  height: height,
                                  user: user,
                                  project: widget.project,
                                  busyId: _busyId,
                                  onTap: _openTicket,
                                  onMove: _move,
                                  statusOf: _statusOf,
                                  onAddCard: widget.onNewTask,
                                ),
                                const SizedBox(width: 14),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Toolbar
// ---------------------------------------------------------------------------

class _Toolbar extends StatelessWidget {
  final String query;
  final String filter;
  final int total;
  final int overdue;
  final bool canMove;
  final bool canCreateTask;
  final Map<String, int> counts;
  final ValueChanged<String> onQuery;
  final ValueChanged<String> onFilter;
  final VoidCallback onArchived;
  final ValueChanged<String> onNewTask;

  const _Toolbar({
    required this.query,
    required this.filter,
    required this.total,
    required this.overdue,
    required this.canMove,
    required this.canCreateTask,
    required this.counts,
    required this.onQuery,
    required this.onFilter,
    required this.onArchived,
    required this.onNewTask,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top action & search bar row (Bitrix24 layout style)
        Row(
          children: [
            if (canCreateTask) ...[
              Material(
                color: ThemeColors.unifiedPrimary,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: () => onNewTask('open'),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.add_rounded, size: 16, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'New task',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: TextField(
                onChanged: onQuery,
                style: const TextStyle(
                  fontSize: 13,
                  color: ThemeColors.unifiedTextPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Filter and search...',
                  hintStyle: const TextStyle(
                    fontSize: 12.5,
                    color: ThemeColors.unifiedTextMuted,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: ThemeColors.unifiedTextMuted,
                  ),
                  suffixIcon: query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: ThemeColors.unifiedTextMuted,
                          ),
                          onPressed: () => onQuery(''),
                        )
                      : null,
                  isDense: true,
                  filled: true,
                  fillColor: ThemeColors.unifiedInputBg,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                      color: ThemeColors.unifiedBorder,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                      color: ThemeColors.unifiedBorder,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                      color: ThemeColors.unifiedPrimary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _Pill(
                label: 'All',
                count: total,
                active: filter == 'all',
                onTap: () => onFilter('all'),
              ),
              const SizedBox(width: 6),
              _Pill(
                label: 'Overdue',
                count: overdue,
                active: filter == 'overdue',
                danger: true,
                onTap: () => onFilter('overdue'),
              ),
              for (final status in CommonStatus.statuses) ...[
                const SizedBox(width: 6),
                _Pill(
                  label: _listLabel(status),
                  count: counts[status] ?? 0,
                  active: filter == status,
                  color: CommonStatus.columnColor(status),
                  onTap: () => onFilter(status),
                ),
              ],
              const SizedBox(width: 6),
              TextButton.icon(
                onPressed: onArchived,
                icon: const Icon(Icons.archive_outlined, size: 15),
                label: const Text('Archived'),
                style: TextButton.styleFrom(
                  foregroundColor: ThemeColors.unifiedTextMuted,
                  backgroundColor: ThemeColors.unifiedInputBg,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(0, 30),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: ThemeColors.unifiedBorder),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (canMove) ...[
          const SizedBox(height: 6),
          const Text(
            'Tip: press and hold a task card to drag it to another column.',
            style: TextStyle(
              fontSize: 10.5,
              color: ThemeColors.unifiedTextMuted,
            ),
          ),
        ],
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final int count;
  final bool active;
  final bool danger;
  final Color? color;
  final VoidCallback onTap;

  const _Pill({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
    this.danger = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final accent = danger
        ? ThemeColors.unifiedDanger
        : (color ?? ThemeColors.unifiedPrimary);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(5, 4, 11, 4),
        decoration: BoxDecoration(
          color: active
              ? ThemeColors.unifiedPrimary
              : ThemeColors.unifiedInputBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active
                ? ThemeColors.unifiedPrimary
                : danger && count > 0
                    ? ThemeColors.unifiedDanger.withValues(alpha: 0.45)
                    : ThemeColors.unifiedBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 19,
              height: 19,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active
                    ? Colors.white.withValues(alpha: 0.22)
                    : danger && count > 0
                        ? ThemeColors.unifiedDanger.withValues(alpha: 0.12)
                        : ThemeColors.unifiedSurface,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: active
                      ? Colors.white
                      : danger && count > 0
                          ? ThemeColors.unifiedDanger
                          : accent.withValues(alpha: 0.9),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                color: active ? Colors.white : ThemeColors.unifiedTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Column
// ---------------------------------------------------------------------------

class _BoardColumn extends StatelessWidget {
  final String status;
  final String label;
  final Color color;
  final List<TicketModel> tickets;
  final double height;
  final UserModel user;
  final ProjectModel project;
  final int? busyId;
  final ValueChanged<int> onTap;
  final void Function(TicketModel ticket, String target) onMove;
  final String Function(TicketModel ticket) statusOf;
  final ValueChanged<String> onAddCard;

  const _BoardColumn({
    required this.status,
    required this.label,
    required this.color,
    required this.tickets,
    required this.height,
    required this.user,
    required this.project,
    required this.busyId,
    required this.onTap,
    required this.onMove,
    required this.statusOf,
    required this.onAddCard,
  });

  @override
  Widget build(BuildContext context) {
    final canDrag = !project.isObserver;

    return DragTarget<TicketModel>(
      onWillAcceptWithDetails: (details) =>
          canDrag && statusOf(details.data) != status,
      onAcceptWithDetails: (details) => onMove(details.data, status),
      builder: (context, candidateData, rejectedData) {
        final hovering = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 312,
          height: height,
          decoration: BoxDecoration(
            color: hovering
                ? color.withValues(alpha: 0.05)
                : ThemeColors.unifiedSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hovering
                  ? color.withValues(alpha: 0.45)
                  : ThemeColors.unifiedBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.07),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                  border: Border(
                    bottom: BorderSide(color: color.withValues(alpha: 0.14)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.45),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: color.withValues(alpha: 0.95),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    Text(
                      '${tickets.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: color.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.more_horiz_rounded,
                      size: 17,
                      color: ThemeColors.unifiedTextMuted.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: tickets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 30,
                              color: ThemeColors.unifiedTextMuted
                                  .withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Drop a task here',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: ThemeColors.unifiedTextMuted
                                    .withValues(alpha: 0.55),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(10),
                        itemCount: tickets.length,
                        itemBuilder: (context, index) {
                          final t = tickets[index];
                          return Padding(
                            key: ValueKey(t.id),
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _TaskCard(
                              ticket: t,
                              user: user,
                              canDrag: canDrag,
                              busy: busyId == t.id,
                              onTap: () => onTap(t.id),
                            ),
                          );
                        },
                      ),
              ),
              if (!project.isObserver)
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 2, 6, 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onAddCard(status),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 9),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.add_rounded,
                              size: 17,
                              color: ThemeColors.unifiedTextMuted,
                            ),
                            const SizedBox(width: 7),
                            const Text(
                              'Add a card',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: ThemeColors.unifiedTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Card
// ---------------------------------------------------------------------------

class _TaskCard extends StatelessWidget {
  final TicketModel ticket;
  final UserModel user;
  final bool canDrag;
  final bool busy;
  final VoidCallback onTap;

  const _TaskCard({
    required this.ticket,
    required this.user,
    required this.canDrag,
    required this.busy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final inner = _CardInner(
      ticket: ticket,
      user: user,
      busy: busy,
      onTap: onTap,
      showDragHandle: canDrag,
    );

    if (!canDrag) return inner;

    return LongPressDraggable<TicketModel>(
      data: ticket,
      feedback: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Transform.rotate(
            angle: -0.02,
            child: _CardInner(
              ticket: ticket,
              user: user,
              busy: false,
              onTap: () {},
              dragging: true,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: _CardInner(
          ticket: ticket,
          user: user,
          busy: busy,
          onTap: onTap,
        ),
      ),
      child: inner,
    );
  }
}

class _CardInner extends StatelessWidget {
  final TicketModel ticket;
  final UserModel user;
  final bool busy;
  final bool dragging;
  final bool showDragHandle;
  final VoidCallback onTap;

  const _CardInner({
    required this.ticket,
    required this.user,
    required this.busy,
    required this.onTap,
    this.dragging = false,
    this.showDragHandle = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = ticket;
    final priorityColor = CommonStatus.ticketPriorityColor(t.priority);
    // Project tasks are flat: a task is either done (100%) or wherever the
    // tracked progress says it is.
    final progress =
        t.status == 'closed' ? 100 : t.overallProgress.clamp(0, 100);
    final overdue = t.dueDate != null &&
        t.dueDate!.isBefore(DateTime.now()) &&
        t.status != 'closed';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: ThemeColors.unifiedSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: dragging
                  ? ThemeColors.unifiedPrimary.withValues(alpha: 0.5)
                  : ThemeColors.unifiedBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: dragging ? 0.16 : 0.05),
                blurRadius: dragging ? 20 : 8,
                offset: Offset(0, dragging ? 8 : 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PriorityDot(priority: t.priority),
                  if (overdue) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color:
                            ThemeColors.unifiedDanger.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'OVERDUE',
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: ThemeColors.unifiedDanger,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (busy)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: ThemeColors.unifiedPrimary,
                      ),
                    )
                  else if (canDragHandle)
                    const Tooltip(
                      message: 'Hold and drag to move',
                      child: Icon(
                        Icons.drag_indicator_rounded,
                        size: 16,
                        color: ThemeColors.unifiedTextMuted,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                t.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.unifiedTextPrimary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SoftProgressBar(
                      value: progress / 100.0,
                      color: progress >= 100
                          ? ThemeColors.unifiedSuccess
                          : priorityColor,
                      height: 5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    progress >= 100 ? 'Done' : '$progress%',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: ThemeColors.unifiedTextMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Container(height: 1, color: ThemeColors.unifiedBorder),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: ThemeColors.unifiedInputBg,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color:
                            ThemeColors.unifiedBorder.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Text(
                      t.ticketNumber.isNotEmpty ? '#${t.ticketNumber}' : '#${t.id}',
                      style: const TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: ThemeColors.unifiedTextMuted,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.schedule_rounded,
                    size: 13,
                    color: overdue
                        ? ThemeColors.unifiedDanger
                        : ThemeColors.unifiedTextMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    t.dueDate != null ? _formatDate(t.dueDate!) : 'No date',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: overdue
                          ? ThemeColors.unifiedDanger
                          : ThemeColors.unifiedTextMuted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  MemberStack(
                    members: t.members,
                    size: 22,
                    max: 3,
                    fallbackName: t.assignedToName ?? 'Unassigned',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get canDragHandle => showDragHandle;

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class PriorityDot extends StatelessWidget {
  final String priority;
  const PriorityDot({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final color = CommonStatus.ticketPriorityColor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
