// ── Bottom Nav ────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/widgets/bottom_item.dart';

class BottomNav extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onNav;
  const BottomNav({required this.selectedIndex, required this.onNav});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ThemeColors.unifiedSurface,
        border: Border(top: BorderSide(color: ThemeColors.unifiedBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          BotItem(
            icon: Icons.dashboard_outlined,
            label: 'Home',
            index: 0,
            selected: selectedIndex,
            onTap: onNav,
          ),
          BotItem(
            icon: Icons.task_alt_outlined,
            label: 'Tickets',
            index: 1,
            selected: selectedIndex,
            onTap: onNav,
          ),
          BotItem(
            icon: Icons.add_circle_outline,
            label: 'New',
            index: 2,
            selected: selectedIndex,
            onTap: onNav,
          ),
          BotItem(
            icon: Icons.notifications_outlined,
            label: 'Alerts',
            index: 3,
            selected: selectedIndex,
            onTap: onNav,
          ),
        ],
      ),
    );
  }
}
