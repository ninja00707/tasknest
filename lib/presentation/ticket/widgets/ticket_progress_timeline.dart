import 'package:flutter/material.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/theme/color.dart';

class ProgressTimeline extends StatelessWidget {
  final String status;
  const ProgressTimeline({required this.status});

  bool _isPassed(int step) {
    final s = status.toLowerCase();
    if (s == 'closed') return true;
    if (s == 'completed' && step <= 3) return true;
    if (s == 'in_progress' && step <= 2) return true;
    if (s == 'open' && step <= 1) return true;
    return false;
  }

  bool _isCurrentStep(int step) {
    final s = status.toLowerCase();
    if (s == 'open' && step == 1) return true;
    if (s == 'in_progress' && step == 2) return true;
    if (s == 'completed' && step == 3) return true;
    if (s == 'closed' && step == 4) return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      TimelineStep(
        step: 1,
        icon: Icons.add_circle_outline_rounded,
        title: ConstStrings.stepTicketCreated,
        description: ConstStrings.stepTicketCreatedDesc,
        color: ThemeColors.unifiedPrimary,
      ),
      TimelineStep(
        step: 2,
        icon: Icons.assignment_ind_outlined,
        title: ConstStrings.stepInProgress,
        description: ConstStrings.stepInProgressDesc,
        color: ThemeColors.unifiedSecondary,
      ),
      TimelineStep(
        step: 3,
        icon: Icons.check_circle_outline_rounded,
        title: ConstStrings.stepCompleted,
        description: ConstStrings.stepCompletedDesc,
        color: ThemeColors.unifiedAccent,
      ),
      TimelineStep(
        step: 4,
        icon: Icons.lock_outline_rounded,
        title: ConstStrings.stepClosed,
        description: ConstStrings.stepClosedDesc,
        color: ThemeColors.unifiedTextMuted,
        isLast: true,
      ),
    ];

    return Column(
      children: steps
          .map(
            (s) => TimelineItem(
              step: s,
              isActive: _isPassed(s.step),
              isCurrent: _isCurrentStep(s.step),
            ),
          )
          .toList(),
    );
  }
}

class TimelineStep {
  final int step;
  final IconData icon;
  final String title, description;
  final Color color;
  final bool isLast;

  const TimelineStep({
    required this.step,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.isLast = false,
  });
}

class TimelineItem extends StatelessWidget {
  final TimelineStep step;
  final bool isActive, isCurrent;

  const TimelineItem({
    required this.step,
    required this.isActive,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = isActive ? step.color : ThemeColors.unifiedBorder;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isActive
                    ? step.color.withOpacity(0.1)
                    : ThemeColors.unifiedBackground,
                shape: BoxShape.circle,
                border: Border.all(
                  color: dotColor,
                  width: isCurrent ? 2.5 : 1.5,
                ),
              ),
              child: Icon(step.icon, size: 17, color: dotColor),
            ),
            if (!step.isLast)
              Container(
                width: 2,
                height: 32,
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: isActive
                      ? step.color.withOpacity(0.35)
                      : ThemeColors.unifiedBorder,
                ),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 6, bottom: step.isLast ? 0 : 22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isActive
                              ? ThemeColors.unifiedTextPrimary
                              : ThemeColors.unifiedTextMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        step.description,
                        style: const TextStyle(
                          fontSize: 11,
                          color: ThemeColors.unifiedTextMuted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCurrent)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: step.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: step.color.withOpacity(0.3)),
                    ),
                    child: Text(
                      ConstStrings.now,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: step.color,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
