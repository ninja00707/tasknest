// ── Sidebar ───────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:tasknest/core/constant/const_dep.dart';
import 'package:tasknest/core/constant/name_by_id.dart';
import 'package:tasknest/core/theme/color.dart';

import 'package:tasknest/presentation/dashboard/widgets/navigationbar.dart/nav_items.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onNav;
  final UserModel user;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onNav,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final departmentName = NameById.getNameById<Departments>(
      id: user.departmentId,
      items: departments,
      idSelector: (e) => e.id,
      nameSelector: (e) => e.name,
    );

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
            selected: selectedIndex == 0,
            onTap: onNav,
          ),
          NavItem(
            icon: Icons.task_alt_outlined,
            label: 'Tickets',
            index: 1,
            selected: selectedIndex == 1,
            onTap: onNav,
          ),
          NavItem(
            icon: Icons.add_circle_outline,
            label: 'New Ticket',
            index: 2,
            selected: selectedIndex == 2,
            onTap: onNav,
          ),

          // Add this inside your Sidebar widget's item list
          NavItem(
            icon: Icons.history_rounded,
            label: 'Recent Activity',
            index: 3,
            selected: selectedIndex == 3,
            onTap: onNav,
          ),
          NavItem(
            icon: Icons.assignment_ind_outlined,
            label: 'Assigned to Me',
            index: 4,
            selected: selectedIndex == 4,
            onTap: onNav,
          ),
          // if (user.roleId == 1 || user.roleId == 0)
          //   NavItem(
          //     icon: Icons.analytics_outlined,
          //     label: 'Analytics',
          //     index: 4,
          //     selected: selectedIndex == 4,
          //     onTap: onNav,
          //   ),
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
                  child: Text(
                    user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: ThemeColors.unifiedTextPrimary,
                        ),
                      ),
                      Text(
                        departmentName,
                        style: const TextStyle(
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
