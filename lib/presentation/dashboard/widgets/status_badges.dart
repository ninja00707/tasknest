import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    String label;
    switch (status) {
      case 'open':
        bg = ThemeColors.statusOpenBg;
        fg = ThemeColors.statusOpenFg;
        label = 'Open';
        break;
      case 'in_progress':
        bg = ThemeColors.statusProgressBg;
        fg = ThemeColors.statusProgressFg;
        label = 'In Progress';
        break;
      case 'completed':
        bg = ThemeColors.statusDoneBg;
        fg = ThemeColors.statusDoneFg;
        label = 'Completed';
        break;
      default:
        bg = ThemeColors.statusClosedBg;
        fg = ThemeColors.statusClosedFg;
        label = 'Closed';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: fg, fontWeight: FontWeight.w700),
      ),
    );
  }
}
