import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/projects/model/project_models.dart';
import 'package:tasknest/presentation/projects/widgets/ui_helpers.dart';

class ProjectCalendar extends StatefulWidget {
  final ProjectModel project;
  const ProjectCalendar({super.key, required this.project});

  @override
  State<ProjectCalendar> createState() => _ProjectCalendarState();
}

class _ProjectCalendarState extends State<ProjectCalendar> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
  }

  void _prevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  Map<DateTime, List<ProjectTaskModel>> _tasksByDate() {
    final map = <DateTime, List<ProjectTaskModel>>{};
    for (final task in widget.project.tasks) {
      if (task.dueDate != null) {
        final day = DateTime(
          task.dueDate!.year,
          task.dueDate!.month,
          task.dueDate!.day,
        );
        map.putIfAbsent(day, () => []).add(task);
      }
    }
    return map;
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return ThemeColors.priorityUrgentFg;
      case 'high':
        return ThemeColors.priorityHighFg;
      case 'medium':
        return ThemeColors.priorityMedFg;
      case 'low':
        return ThemeColors.priorityLowFg;
      default:
        return ThemeColors.unifiedTextMuted;
    }
  }

  String _priorityLabel(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return 'Urgent';
      case 'high':
        return 'High';
      case 'medium':
        return 'Medium';
      case 'low':
        return 'Low';
      default:
        return priority;
    }
  }

  Color _priorityBg(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return ThemeColors.priorityUrgentBg;
      case 'high':
        return ThemeColors.priorityHighBg;
      case 'medium':
        return ThemeColors.priorityMedBg;
      case 'low':
        return ThemeColors.priorityLowBg;
      default:
        return ThemeColors.unifiedInputBg;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return ThemeColors.statusOpenFg;
      case 'in_progress':
      case 'in progress':
      case 'progress':
        return ThemeColors.statusProgressFg;
      case 'done':
      case 'completed':
        return ThemeColors.statusDoneFg;
      case 'closed':
        return ThemeColors.statusClosedFg;
      default:
        return ThemeColors.unifiedTextMuted;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return 'Open';
      case 'in_progress':
      case 'in progress':
      case 'progress':
        return 'In Progress';
      case 'done':
      case 'completed':
        return 'Done';
      case 'closed':
        return 'Closed';
      case 'todo':
        return 'To Do';
      default:
        return status;
    }
  }

  Color _statusBg(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return ThemeColors.statusOpenBg;
      case 'in_progress':
      case 'in progress':
      case 'progress':
        return ThemeColors.statusProgressBg;
      case 'done':
      case 'completed':
        return ThemeColors.statusDoneBg;
      case 'closed':
        return ThemeColors.statusClosedBg;
      case 'todo':
        return ThemeColors.statusOpenBg;
      default:
        return ThemeColors.unifiedInputBg;
    }
  }

  void _showDayTasks(DateTime day, List<ProjectTaskModel> tasks) {
    final formatted =
        '${_monthName(day.month)} ${day.day}, ${day.year}';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.45,
          minChildSize: 0.25,
          maxChildSize: 0.85,
          builder: (ctx, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: ThemeColors.unifiedSurface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 30,
                    offset: Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: ThemeColors.unifiedBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        IconBadge(
                          icon: Icons.calendar_today_rounded,
                          size: 30,
                          color: ThemeColors.unifiedPrimary,
                          iconScale: 0.5,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            formatted,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: ThemeColors.unifiedTextPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: ThemeColors.unifiedPrimary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${tasks.length} task${tasks.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: ThemeColors.unifiedPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1, color: ThemeColors.unifiedBorder),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      itemCount: tasks.length,
                      itemBuilder: (ctx, i) {
                        final task = tasks[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: ThemeColors.unifiedSurface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: ThemeColors.unifiedBorder,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      task.title,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: ThemeColors.unifiedTextPrimary,
                                      ),
                                    ),
                                  ),
                                  if (task.assignedToName != null &&
                                      task.assignedToName!.isNotEmpty)
                                    InitialsAvatar(
                                      name: task.assignedToName!,
                                      size: 26,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  DotPill(
                                    label: _priorityLabel(task.priority),
                                    bg: _priorityBg(task.priority),
                                    fg: _priorityColor(task.priority),
                                  ),
                                  DotPill(
                                    label: _statusLabel(task.status),
                                    bg: _statusBg(task.status),
                                    fg: _statusColor(task.status),
                                  ),
                                ],
                              ),
                              if (task.assignedToName != null &&
                                  task.assignedToName!.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    InitialsAvatar(
                                      name: task.assignedToName!,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        task.assignedToName!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              ThemeColors.unifiedTextMuted,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _monthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final tasksByDate = _tasksByDate();
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          icon: Icons.calendar_month_rounded,
          title: 'Calendar',
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final cellSize = constraints.maxWidth > 500 ? 56.0 : 44.0;

            return Container(
              decoration: BoxDecoration(
                color: ThemeColors.unifiedSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: ThemeColors.unifiedBorder,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.035),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  _buildDowRow(),
                  _buildGrid(
                    tasksByDate: tasksByDate,
                    todayKey: todayKey,
                    cellSize: cellSize,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          IconBadge(
            icon: Icons.calendar_month_rounded,
            size: 32,
            color: ThemeColors.unifiedPrimary,
            iconScale: 0.5,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${_monthName(_focusedMonth.month)} ${_focusedMonth.year}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: ThemeColors.unifiedTextPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ),
          _arrowButton(
            icon: Icons.chevron_left_rounded,
            onTap: _prevMonth,
          ),
          const SizedBox(width: 4),
          _arrowButton(
            icon: Icons.chevron_right_rounded,
            onTap: _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _arrowButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ThemeColors.unifiedSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ThemeColors.unifiedBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: ThemeColors.unifiedTextPrimary),
      ),
    );
  }

  Widget _buildDowRow() {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          for (int i = 0; i < 7; i++)
            Expanded(
              child: Center(
                child: Text(
                  days[i],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: (i == 0 || i == 6)
                        ? ThemeColors.unifiedTextMuted.withValues(alpha: 0.7)
                        : ThemeColors.unifiedTextMuted,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGrid({
    required Map<DateTime, List<ProjectTaskModel>> tasksByDate,
    required DateTime todayKey,
    required double cellSize,
  }) {
    final year = _focusedMonth.year;
    final month = _focusedMonth.month;
    final firstDay = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startDow = firstDay.weekday % 7;

    final cells = <Widget>[];
    for (int i = 0; i < startDow; i++) {
      cells.add(SizedBox(width: cellSize, height: cellSize));
    }
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final isToday = date == todayKey;
      final dayTasks = tasksByDate[date] ?? [];
      final isWeekend = date.weekday == 7 || date.weekday == 6;

      cells.add(
        _DayCell(
          day: day,
          isToday: isToday,
          isWeekend: isWeekend,
          tasks: dayTasks,
          cellSize: cellSize,
          onTap: dayTasks.isNotEmpty ? () => _showDayTasks(date, dayTasks) : null,
        ),
      );
    }
    while (cells.length % 7 != 0) {
      cells.add(SizedBox(width: cellSize, height: cellSize));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 14),
      child: Wrap(
        spacing: 2,
        runSpacing: 2,
        children: cells,
      ),
    );
  }
}

class _DayCell extends StatefulWidget {
  final int day;
  final bool isToday;
  final bool isWeekend;
  final List<ProjectTaskModel> tasks;
  final double cellSize;
  final VoidCallback? onTap;

  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isWeekend,
    required this.tasks,
    required this.cellSize,
    this.onTap,
  });

  @override
  State<_DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<_DayCell> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final interactive = widget.onTap != null;
    final bg = widget.isToday
        ? ThemeColors.unifiedPrimary
        : _hovered
            ? ThemeColors.unifiedInputBg
            : Colors.transparent;

    final textColor = widget.isToday
        ? Colors.white
        : widget.isWeekend
            ? ThemeColors.unifiedTextMuted.withValues(alpha: 0.7)
            : ThemeColors.unifiedTextPrimary;

    final cell = Container(
      width: widget.cellSize,
      height: widget.cellSize,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: widget.isToday
            ? null
            : _hovered
                ? Border.all(
                    color: ThemeColors.unifiedBorder,
                    width: 1,
                  )
                : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${widget.day}',
            style: TextStyle(
              fontSize: widget.cellSize > 48 ? 14 : 13,
              fontWeight: widget.isToday ? FontWeight.w800 : FontWeight.w600,
              color: textColor,
            ),
          ),
          if (widget.tasks.isNotEmpty) ...[
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < widget.tasks.length && i < 3; i++)
                  Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: widget.isToday
                          ? Colors.white.withValues(alpha: 0.85)
                          : _priorityColor(widget.tasks[i].priority),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );

    if (!interactive) return cell;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: cell,
      ),
    );
  }

  Color _priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return ThemeColors.priorityUrgentFg;
      case 'high':
        return ThemeColors.priorityHighFg;
      case 'medium':
        return ThemeColors.priorityMedFg;
      case 'low':
        return ThemeColors.priorityLowFg;
      default:
        return ThemeColors.unifiedTextMuted;
    }
  }
}
