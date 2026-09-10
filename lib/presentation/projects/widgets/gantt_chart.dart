import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/projects/model/project_models.dart';
import 'package:tasknest/presentation/projects/widgets/ui_helpers.dart';

class GanttChart extends StatelessWidget {
  final ProjectModel project;
  const GanttChart({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final tasks = project.tasks;

    if (tasks.isEmpty) {
      return SoftCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SectionHeader(
              icon: Icons.timeline_rounded,
              title: 'Timeline',
            ),
            const SizedBox(height: 12),
            const FriendlyEmptyState(
              icon: Icons.view_timeline_rounded,
              message: 'No tasks to display in timeline',
              hint: 'Add tasks to see them on the timeline',
            ),
          ],
        ),
      );
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime rangeStart = project.startDate ?? today;
    DateTime rangeEnd = project.endDate ?? today.add(const Duration(days: 30));

    for (final t in tasks) {
      final created = DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day);
      if (created.isBefore(rangeStart)) rangeStart = created;
      final end = t.dueDate != null
          ? DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day)
          : today;
      if (end.isAfter(rangeEnd)) rangeEnd = end;
    }

    final totalDays = rangeEnd.difference(rangeStart).inDays + 1;
    const dayWidth = 40.0;
    const rowHeight = 40.0;
    final timelineWidth = totalDays * dayWidth;

    final sorted = List<ProjectTaskModel>.from(tasks)..sort((a, b) {
      final aDate = a.dueDate ?? a.createdAt;
      final bDate = b.dueDate ?? b.createdAt;
      return aDate.compareTo(bDate);
    });

    return SoftCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.timeline_rounded,
            title: 'Timeline',
          ),
          const SizedBox(height: 6),
          Eyebrow(
            text: 'TIMELINE',
            color: ThemeColors.unifiedAccent,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: ThemeColors.unifiedBorder.withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
              children: [
                SizedBox(
                  height: 38,
                  child: Row(
                    children: [
                      Container(
                        width: 200,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: const BoxDecoration(
                          color: ThemeColors.unifiedInputBg,
                          border: Border(
                            right: BorderSide(color: ThemeColors.unifiedBorder, width: 0.5),
                          ),
                        ),
                        child: const Text(
                          'TASK',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                            color: ThemeColors.unifiedTextMuted,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: ThemeColors.unifiedInputBg,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: timelineWidth,
                              child: _MonthHeaders(
                                rangeStart: rangeStart,
                                totalDays: totalDays,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 1,
                  color: ThemeColors.unifiedBorder.withValues(alpha: 0.6),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 200,
                          child: Column(
                            children: [
                              for (int i = 0; i < sorted.length; i++)
                                _TaskLabel(
                                  task: sorted[i],
                                  index: i,
                                  rowHeight: rowHeight,
                                ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: timelineWidth,
                              height: sorted.length * rowHeight,
                              child: Stack(
                                children: [
                                  _GridPainter(
                                    rangeStart: rangeStart,
                                    totalDays: totalDays,
                                    today: today,
                                    rowCount: sorted.length,
                                    rowHeight: rowHeight,
                                    dayWidth: dayWidth,
                                  ),
                                  for (int i = 0; i < sorted.length; i++)
                                    _TaskBar(
                                      task: sorted[i],
                                      row: i,
                                      rangeStart: rangeStart,
                                      today: today,
                                      rowHeight: rowHeight,
                                      dayWidth: dayWidth,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }
}

class _MonthHeaders extends StatelessWidget {
  final DateTime rangeStart;
  final int totalDays;
  const _MonthHeaders({required this.rangeStart, required this.totalDays});

  @override
  Widget build(BuildContext context) {
    final months = <MapEntry<String, int>>[];
    for (int d = 0; d < totalDays; d++) {
      final date = rangeStart.add(Duration(days: d));
      final key = '${date.year}-${date.month}';
      if (months.isEmpty || months.last.key != key) {
        months.add(MapEntry(key, d));
      }
    }

    return Row(
      children: [
        for (int m = 0; m < months.length; m++)
          Builder(
            builder: (context) {
              final startDay = months[m].value;
              final endDay = m + 1 < months.length ? months[m + 1].value : totalDays;
              final width = (endDay - startDay) * 40.0;
              final date = rangeStart.add(Duration(days: startDay));
              final label = _monthLabel(date);
              return Container(
                width: width,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: m > 0
                    ? const BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: ThemeColors.unifiedBorder,
                            width: 1,
                          ),
                        ),
                      )
                    : null,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: ThemeColors.unifiedTextMuted,
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
      ],
    );
  }

  String _monthLabel(DateTime date) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month]} ${date.year}';
  }
}

class _GridPainter extends StatelessWidget {
  final DateTime rangeStart;
  final int totalDays;
  final DateTime today;
  final int rowCount;
  final double rowHeight;
  final double dayWidth;
  const _GridPainter({
    required this.rangeStart,
    required this.totalDays,
    required this.today,
    required this.rowCount,
    required this.rowHeight,
    required this.dayWidth,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(totalDays * dayWidth, rowCount * rowHeight),
      painter: _GridPainterPainter(
        rangeStart: rangeStart,
        totalDays: totalDays,
        today: today,
        rowCount: rowCount,
        rowHeight: rowHeight,
        dayWidth: dayWidth,
      ),
    );
  }
}

class _GridPainterPainter extends CustomPainter {
  final DateTime rangeStart;
  final int totalDays;
  final DateTime today;
  final int rowCount;
  final double rowHeight;
  final double dayWidth;
  _GridPainterPainter({
    required this.rangeStart,
    required this.totalDays,
    required this.today,
    required this.rowCount,
    required this.rowHeight,
    required this.dayWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (int r = 0; r < rowCount; r++) {
      if (r.isEven) {
        canvas.drawRect(
          Rect.fromLTWH(0, r * rowHeight, size.width, rowHeight),
          Paint()..color = ThemeColors.unifiedSurface,
        );
      } else {
        canvas.drawRect(
          Rect.fromLTWH(0, r * rowHeight, size.width, rowHeight),
          Paint()..color = ThemeColors.unifiedInputBg.withValues(alpha: 0.5),
        );
      }
    }

    for (int d = 0; d <= totalDays; d++) {
      final x = d * dayWidth;
      final date = rangeStart.add(Duration(days: d));
      final isMonday = date.weekday == DateTime.monday;
      final paint = Paint()
        ..color = isMonday
            ? ThemeColors.unifiedBorder.withValues(alpha: 0.7)
            : ThemeColors.unifiedBorder.withValues(alpha: 0.25)
        ..strokeWidth = isMonday ? 1.0 : 0.5;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (int r = 0; r <= rowCount; r++) {
      final y = r * rowHeight;
      final paint = Paint()
        ..color = ThemeColors.unifiedBorder.withValues(alpha: 0.3)
        ..strokeWidth = 0.5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    final todayOffset = today.difference(rangeStart).inDays;
    if (todayOffset >= 0 && todayOffset <= totalDays) {
      final x = todayOffset * dayWidth + dayWidth / 2;

      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        Paint()
          ..color = ThemeColors.unifiedDanger
          ..strokeWidth = 1.5,
      );

      final labelPainter = TextPainter(
        text: TextSpan(
          text: 'Today',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final bgRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x, -labelPainter.height / 2 - 2),
          width: labelPainter.width + 12,
          height: labelPainter.height + 6,
        ),
        const Radius.circular(4),
      );
      canvas.drawRRect(
        bgRect,
        Paint()..color = ThemeColors.unifiedDanger,
      );
      labelPainter.paint(
        canvas,
        Offset(x - labelPainter.width / 2, -labelPainter.height - 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainterPainter old) =>
      old.totalDays != totalDays ||
      old.today != today ||
      old.rowCount != rowCount;
}

class _TaskLabel extends StatelessWidget {
  final ProjectTaskModel task;
  final int index;
  final double rowHeight;
  const _TaskLabel({
    required this.task,
    required this.index,
    required this.rowHeight,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = task.status == 'done';
    return Container(
      height: rowHeight,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: index.isEven
            ? ThemeColors.unifiedSurface
            : ThemeColors.unifiedInputBg.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            color: ThemeColors.unifiedBorder.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Expanded(
            child: Text(
              task.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isDone
                    ? ThemeColors.unifiedTextMuted
                    : ThemeColors.unifiedTextPrimary,
                decoration: isDone ? TextDecoration.lineThrough : null,
                decorationColor: ThemeColors.unifiedTextMuted,
              ),
            ),
          ),
          const SizedBox(width: 6),
          _priorityPill(task.priority),
        ],
      ),
    );
  }

  Widget _priorityPill(String priority) {
    switch (priority) {
      case 'urgent':
        return DotPill(
          label: 'URG',
          bg: ThemeColors.priorityUrgentBg,
          fg: ThemeColors.priorityUrgentFg,
          fontSize: 9,
        );
      case 'high':
        return DotPill(
          label: 'HIGH',
          bg: ThemeColors.priorityHighBg,
          fg: ThemeColors.priorityHighFg,
          fontSize: 9,
        );
      case 'low':
        return DotPill(
          label: 'LOW',
          bg: ThemeColors.priorityLowBg,
          fg: ThemeColors.priorityLowFg,
          fontSize: 9,
        );
      default:
        return DotPill(
          label: 'MED',
          bg: ThemeColors.priorityMedBg,
          fg: ThemeColors.priorityMedFg,
          fontSize: 9,
        );
    }
  }
}

class _TaskBar extends StatelessWidget {
  final ProjectTaskModel task;
  final int row;
  final DateTime rangeStart;
  final DateTime today;
  final double rowHeight;
  final double dayWidth;
  const _TaskBar({
    required this.task,
    required this.row,
    required this.rangeStart,
    required this.today,
    required this.rowHeight,
    required this.dayWidth,
  });

  @override
  Widget build(BuildContext context) {
    final created = DateTime(task.createdAt.year, task.createdAt.month, task.createdAt.day);
    final end = task.dueDate != null
        ? DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day)
        : today;

    final startOffset = created.difference(rangeStart).inDays;
    final duration = end.difference(created).inDays + 1;

    final left = startOffset * dayWidth;
    final width = duration * dayWidth;
    final top = row * rowHeight + 6;
    final barHeight = 28.0;

    final color = _priorityColor(task.priority);
    final isDone = task.status == 'done';
    final showTitle = width >= 80;

    return Positioned(
      left: left,
      top: top,
      width: width.clamp(10.0, double.infinity),
      height: barHeight,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDone
                ? [color.withValues(alpha: 0.20), color.withValues(alpha: 0.12)]
                : [color.withValues(alpha: 0.90), color.withValues(alpha: 0.70)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isDone ? 0.05 : 0.18),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDone)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.check_rounded, size: 12, color: Colors.white),
              ),
            if (showTitle)
              Flexible(
                child: Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDone ? Colors.white60 : Colors.white,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return ThemeColors.unifiedDanger;
      case 'high':
        return ThemeColors.unifiedHighPriority;
      case 'medium':
        return ThemeColors.unifiedWarning;
      case 'low':
        return ThemeColors.unifiedSuccess;
      default:
        return ThemeColors.unifiedWarning;
    }
  }
}
