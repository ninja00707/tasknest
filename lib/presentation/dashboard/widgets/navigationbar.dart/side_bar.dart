// ── Sidebar ───────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/widgets/navigationbar.dart/nav_items.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onNav;
  const Sidebar({super.key, required this.selectedIndex, required this.onNav});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: ThemeColors.unifiedSurface,
        border: Border(right: BorderSide(color: ThemeColors.unifiedBorder)),
      ),
      child: Column(
        children: [
          // Logo gradient bar
          Container(
            height: 60,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ThemeColors.unifiedGradStart,
                  ThemeColors.unifiedGradEnd,
                ],
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'TK',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Taskify',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Nav items
          NavItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            index: 0,
            selected: selectedIndex,
            onTap: onNav,
          ),
          NavItem(
            icon: Icons.task_alt_outlined,
            label: 'Tickets',
            index: 1,
            selected: selectedIndex,
            onTap: onNav,
          ),
          NavItem(
            icon: Icons.add_circle_outline,
            label: 'New Ticket',
            index: 2,
            selected: selectedIndex,
            onTap: onNav,
          ),
          NavItem(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            index: 3,
            selected: selectedIndex,
            onTap: onNav,
          ),

          const Spacer(),
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ThemeColors.unifiedBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ThemeColors.unifiedBorder),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: ThemeColors.unifiedPrimary,
                  child: const Text(
                    'M',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manager',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: ThemeColors.unifiedTextPrimary,
                        ),
                      ),
                      Text(
                        'Finance Dept',
                        style: TextStyle(
                          fontSize: 11,
                          color: ThemeColors.unifiedTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
