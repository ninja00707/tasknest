import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/projects/model/project_models.dart';
import 'package:tasknest/presentation/projects/widgets/ui_helpers.dart';

class ProjectStatsSection extends StatelessWidget {
  final ProjectModel project;
  const ProjectStatsSection({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final tasks = project.tasks;
    final total = tasks.length;
    final completed = tasks.where((t) => t.status == 'done').length;
    final inProgress = tasks.where((t) => t.status == 'in_progress').length;
    final overdue = tasks
        .where((t) =>
            t.dueDate != null &&
            t.dueDate!.isBefore(DateTime.now()) &&
            t.status != 'done')
        .length;

    final completionPercent = total > 0 ? completed / total : 0.0;

    final urgent = tasks.where((t) => t.priority == 'urgent').length;
    final high = tasks.where((t) => t.priority == 'high').length;
    final medium = tasks.where((t) => t.priority == 'medium').length;
    final low = tasks.where((t) => t.priority == 'low').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Eyebrow(text: 'Overview', color: ThemeColors.unifiedPrimary),
        const SizedBox(height: 8),
        SoftCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 520;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isWide
                      ? _WideMetricsRow(
                          total: total,
                          completed: completed,
                          inProgress: inProgress,
                          overdue: overdue,
                        )
                      : _CompactMetricsGrid(
                          total: total,
                          completed: completed,
                          inProgress: inProgress,
                          overdue: overdue,
                        ),
                  const SizedBox(height: 14),
                  SoftProgressBar(
                    value: completionPercent,
                    color: ThemeColors.unifiedPrimary,
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 520;
            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _ProgressCard(
                      completed: completed,
                      total: total,
                      percent: completionPercent,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _PriorityCard(
                      urgent: urgent,
                      high: high,
                      medium: medium,
                      low: low,
                      total: total,
                    ),
                  ),
                ],
              );
            }
            return Column(
              children: [
                _ProgressCard(
                  completed: completed,
                  total: total,
                  percent: completionPercent,
                ),
                const SizedBox(height: 16),
                _PriorityCard(
                  urgent: urgent,
                  high: high,
                  medium: medium,
                  low: low,
                  total: total,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _WideMetricsRow extends StatelessWidget {
  final int total;
  final int completed;
  final int inProgress;
  final int overdue;
  const _WideMetricsRow({
    required this.total,
    required this.completed,
    required this.inProgress,
    required this.overdue,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: _MetricCell(
              icon: Icons.task_alt_rounded,
              label: 'Total',
              value: '$total',
              color: ThemeColors.unifiedPrimary,
            ),
          ),
          _VerticalDivider(),
          Expanded(
            child: _MetricCell(
              icon: Icons.check_circle_outline_rounded,
              label: 'Done',
              value: '$completed',
              color: ThemeColors.unifiedSuccess,
            ),
          ),
          _VerticalDivider(),
          Expanded(
            child: _MetricCell(
              icon: Icons.autorenew_rounded,
              label: 'In Progress',
              value: '$inProgress',
              color: ThemeColors.unifiedInfo,
            ),
          ),
          _VerticalDivider(),
          Expanded(
            child: _MetricCell(
              icon: Icons.warning_amber_rounded,
              label: 'Overdue',
              value: '$overdue',
              color: ThemeColors.unifiedDanger,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactMetricsGrid extends StatelessWidget {
  final int total;
  final int completed;
  final int inProgress;
  final int overdue;
  const _CompactMetricsGrid({
    required this.total,
    required this.completed,
    required this.inProgress,
    required this.overdue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCell(
                icon: Icons.task_alt_rounded,
                label: 'Total',
                value: '$total',
                color: ThemeColors.unifiedPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCell(
                icon: Icons.check_circle_outline_rounded,
                label: 'Done',
                value: '$completed',
                color: ThemeColors.unifiedSuccess,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCell(
                icon: Icons.autorenew_rounded,
                label: 'In Progress',
                value: '$inProgress',
                color: ThemeColors.unifiedInfo,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCell(
                icon: Icons.warning_amber_rounded,
                label: 'Overdue',
                value: '$overdue',
                color: ThemeColors.unifiedDanger,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _MetricCell({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
                height: 1.1,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: ThemeColors.unifiedTextMuted,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        width: 1,
        color: ThemeColors.unifiedBorder,
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final int completed;
  final int total;
  final double percent;
  const _ProgressCard({
    required this.completed,
    required this.total,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow(text: 'Progress', color: ThemeColors.unifiedPrimary),
          const SizedBox(height: 16),
          Center(
            child: ProgressRing(
              value: percent,
              size: 100,
              strokeWidth: 9,
              color: ThemeColors.unifiedPrimary,
              trackColor: ThemeColors.unifiedInputBg,
              centerChild: Text(
                '${(percent * 100).round()}%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: ThemeColors.unifiedTextPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '$completed of $total tasks completed',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: ThemeColors.unifiedTextMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityCard extends StatelessWidget {
  final int urgent;
  final int high;
  final int medium;
  final int low;
  final int total;
  const _PriorityCard({
    required this.urgent,
    required this.high,
    required this.medium,
    required this.low,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _PriorityRow(label: 'Urgent', count: urgent, bg: ThemeColors.priorityUrgentBg, fg: ThemeColors.priorityUrgentFg, total: total),
      _PriorityRow(label: 'High', count: high, bg: ThemeColors.priorityHighBg, fg: ThemeColors.priorityHighFg, total: total),
      _PriorityRow(label: 'Medium', count: medium, bg: ThemeColors.priorityMedBg, fg: ThemeColors.priorityMedFg, total: total),
      _PriorityRow(label: 'Low', count: low, bg: ThemeColors.priorityLowBg, fg: ThemeColors.priorityLowFg, total: total),
    ];

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow(text: 'Priorities', color: ThemeColors.unifiedAccent),
          const SizedBox(height: 16),
          for (int i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _PriorityRow extends StatelessWidget {
  final String label;
  final int count;
  final Color bg;
  final Color fg;
  final int total;
  const _PriorityRow({
    required this.label,
    required this.count,
    required this.bg,
    required this.fg,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = total > 0 ? count / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            DotPill(label: label, bg: bg, fg: fg),
            const Spacer(),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SoftProgressBar(value: fraction, color: fg),
      ],
    );
  }
}
