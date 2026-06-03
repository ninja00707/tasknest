// ── Priority Badge ────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';

class PriorityBadge extends StatelessWidget {
  final String priority;
  const PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    switch (priority) {
      case 'urgent':
        bg = ThemeColors.priorityUrgentBg;
        fg = ThemeColors.priorityUrgentFg;
        break;
      case 'high':
        bg = ThemeColors.priorityHighBg;
        fg = ThemeColors.priorityHighFg;
        break;
      case 'medium':
        bg = ThemeColors.priorityMedBg;
        fg = ThemeColors.priorityMedFg;
        break;
      default:
        bg = ThemeColors.priorityLowBg;
        fg = ThemeColors.priorityLowFg;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w800),
      ),
    );
  }
}
