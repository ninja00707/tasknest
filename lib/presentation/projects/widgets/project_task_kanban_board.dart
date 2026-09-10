import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/projects/bloc/project_bloc.dart';
import 'package:tasknest/presentation/projects/bloc/project_event.dart';
import 'package:tasknest/presentation/projects/model/project_models.dart';
import 'package:tasknest/presentation/projects/widgets/ui_helpers.dart';

class ProjectTaskKanbanBoard extends StatelessWidget {
  final ProjectModel project;
  final UserModel? currentUser;
  final bool canManage;
  const ProjectTaskKanbanBoard({
    super.key,
    required this.project,
    required this.currentUser,
    required this.canManage,
  });

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<ProjectTaskModel>>{
      'todo': [],
      'in_progress': [],
      'done': [],
    };
    for (final t in project.tasks) {
      final key = grouped.containsKey(t.status) ? t.status : 'todo';
      grouped[key]!.add(t);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final boardHeight =
            constraints.maxHeight.isFinite ? constraints.maxHeight : 480.0;
        return SizedBox(
          height: boardHeight,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _KanbanColumn(
                    statusKey: 'todo',
                    label: 'To Do',
                    color: ThemeColors.unifiedSecondary,
                    tasks: grouped['todo']!,
                    project: project,
                    canManage: canManage,
                  ),
                  _KanbanColumn(
                    statusKey: 'in_progress',
                    label: 'In Progress',
                    color: ThemeColors.unifiedWarning,
                    tasks: grouped['in_progress']!,
                    project: project,
                    canManage: canManage,
                  ),
                  _KanbanColumn(
                    statusKey: 'done',
                    label: 'Done',
                    color: ThemeColors.unifiedSuccess,
                    tasks: grouped['done']!,
                    project: project,
                    canManage: canManage,
                  ),
                ],
              ),
            ),
          );
      },
    );
  }
}

class _KanbanColumn extends StatelessWidget {
  final String statusKey;
  final String label;
  final Color color;
  final List<ProjectTaskModel> tasks;
  final ProjectModel project;
  final bool canManage;
  const _KanbanColumn({
    required this.statusKey,
    required this.label,
    required this.color,
    required this.tasks,
    required this.project,
    required this.canManage,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<ProjectTaskModel>(
      onWillAcceptWithDetails: (details) =>
          details.data.status != statusKey && canManage,
      onAcceptWithDetails: (details) {
        context.read<ProjectBloc>().add(UpdateProjectTask(
              projectId: project.id,
              taskId: details.data.id,
              status: statusKey,
            ));
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 320,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: isHovering
                ? color.withValues(alpha: 0.06)
                : ThemeColors.unifiedSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isHovering
                  ? color.withValues(alpha: 0.35)
                  : ThemeColors.unifiedBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.06),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(13),
                  ),
                  border: Border(
                    bottom: BorderSide(color: color.withValues(alpha: 0.12)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: color.withValues(alpha: 0.85),
                        letterSpacing: 0.2,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${tasks.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 32,
                              color: ThemeColors.unifiedTextMuted
                                  .withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No tasks',
                              style: TextStyle(
                                fontSize: 13,
                                color: ThemeColors.unifiedTextMuted
                                    .withValues(alpha: 0.5),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(10),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: tasks.length,
                          itemBuilder: (context, index) => Padding(
                            key: ValueKey(tasks[index].id),
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _TaskCard(task: tasks[index]),
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

class _TaskCard extends StatelessWidget {
  final ProjectTaskModel task;
  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<ProjectTaskModel>(
      data: task,
      feedback: Material(
        color: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: _CardInner(task: task),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: _CardInner(task: task),
      ),
      child: _CardInner(task: task),
    );
  }
}

class _CardInner extends StatelessWidget {
  final ProjectTaskModel task;
  const _CardInner({required this.task});

  @override
  Widget build(BuildContext context) {
    final priorityColors = _priorityColors(task.priority);
    final dueColor =
        task.dueDate != null && task.dueDate!.isBefore(DateTime.now())
            ? ThemeColors.unifiedDanger
            : ThemeColors.unifiedTextMuted;

    return SoftCard(
      padding: const EdgeInsets.all(14),
      radius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: ThemeColors.unifiedTextPrimary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              DotPill(
                label: task.priority[0].toUpperCase() +
                    task.priority.substring(1),
                bg: priorityColors.bg,
                fg: priorityColors.fg,
                fontSize: 10,
              ),
              const Spacer(),
              if (task.assignedToName != null)
                InitialsAvatar(name: task.assignedToName!, size: 24),
            ],
          ),
          if (task.dueDate != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 12, color: dueColor),
                const SizedBox(width: 4),
                Text(
                  _formatDate(task.dueDate!),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: dueColor,
                  ),
                ),
              ],
            ),
          ],
          if (task.progress > 0) ...[
            const SizedBox(height: 10),
            SoftProgressBar(
              value: task.progress / 100.0,
              color: ThemeColors.unifiedPrimary,
              height: 5,
            ),
            const SizedBox(height: 3),
            Text(
              '${task.progress}%',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: ThemeColors.unifiedTextMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  ({Color bg, Color fg}) _priorityColors(String priority) {
    switch (priority) {
      case 'urgent':
        return (
          bg: ThemeColors.priorityUrgentBg,
          fg: ThemeColors.priorityUrgentFg,
        );
      case 'high':
        return (
          bg: ThemeColors.priorityHighBg,
          fg: ThemeColors.priorityHighFg,
        );
      case 'low':
        return (
          bg: ThemeColors.priorityLowBg,
          fg: ThemeColors.priorityLowFg,
        );
      default:
        return (
          bg: ThemeColors.priorityMedBg,
          fg: ThemeColors.priorityMedFg,
        );
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
