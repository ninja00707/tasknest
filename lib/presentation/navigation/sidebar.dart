import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/constant/const_dep.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/constant/name_by_id.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/navigation/nav_item.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/notification/widgets/notification_panel.dart';

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
    final dbState = context.read<DashboardBloc>().state;
    final deptList = dbState is DashboardLoaded
        ? dbState.departments
              .map((d) => Departments(name: d.name, id: d.id))
              .toList()
        : <Departments>[];
    final departmentName =
        NameById.getNameById<Departments>(
          id: user.departmentId,
          items: deptList,
          idSelector: (e) => e.id,
          nameSelector: (e) => e.name,
        );
    final roleName =
        NameById.getNameById<Roles>(
          id: user.roleId,
          items: roles,
          idSelector: (e) => e.id,
          nameSelector: (e) => e.name,
        );
    final companyName =
        NameById.getNameById<Company>(
          id: user.companyId,
          items: CompanyNames,
          idSelector: (e) => e.id,
          nameSelector: (e) => e.name,
        );

    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: ThemeColors.unifiedSurface,
        border: Border(right: BorderSide(color: ThemeColors.unifiedBorder)),
      ),
      child: Column(
        children: [
          // Logo section — clean, minimal
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        ThemeColors.unifiedGradStart,
                        ThemeColors.unifiedGradEnd,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'TK',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  ConstStrings.taskify,
                  style: const TextStyle(
                    color: ThemeColors.unifiedTextPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            color: ThemeColors.unifiedBorder.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),

          // Nav items
          NavItem(
            icon: Icons.dashboard_outlined,
            label: ConstStrings.navDashboard,
            index: 0,
            selected: selectedIndex == 0,
            onTap: onNav,
          ),
          NavItem(
            icon: Icons.auto_awesome_outlined,
            label: (user.roleId == 0 || user.roleId == 3)
                ? ConstStrings.navAllDeptTickets
                : user.roleId == 1
                ? ConstStrings.navDeptTickets
                : user.roleId == 2
                ? ConstStrings.navMyTickets
                : '',
            index: 1,
            selected: selectedIndex == 1,
            onTap: onNav,
          ),
          NavItem(
            icon: Icons.add_circle_outline,
            label: ConstStrings.navNewTicket,
            index: 2,
            selected: selectedIndex == 2,
            onTap: onNav,
          ),

          if (user.roleId != 0 && user.roleId != 3)
            NavItem(
              icon: Icons.hub_outlined,
              label: ConstStrings.navSentSubTickets,
              index: 3,
              selected: selectedIndex == 3,
              onTap: onNav,
            ),
          NavItem(
            icon: Icons.task_alt_outlined,
            label: ConstStrings.navRecentActivities,
            index: 4,
            selected: selectedIndex == 4,
            onTap: onNav,
          ),
          NavItem(
            icon: Icons.category_outlined,
            label: ConstStrings.navTicketTypes,
            index: 5,
            selected: selectedIndex == 5,
            onTap: onNav,
          ),
          NavItem(
            icon: Icons.gavel_rounded,
            label: ConstStrings.navDisputes,
            index: 6,
            selected: selectedIndex == 6,
            onTap: onNav,
          ),
          NavItem(
            icon: Icons.folder_outlined,
            label: ConstStrings.navProjects,
            index: 7,
            selected: selectedIndex == 7,
            onTap: onNav,
          ),

          // Admin Panel — only for Developer/CEO
          if (user.roleId == 3 || user.email == 'qasim@um.com') ...[
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              color: ThemeColors.unifiedBorder.withValues(alpha: 0.5),
            ),
            NavItem(
              icon: Icons.admin_panel_settings,
              label: ConstStrings.navAdminPanel,
              index: 99,
              selected: false,
              onTap: (i) => context.go('/admin'),
            ),
          ],

          // Notification bell
          BlocSelector<DashboardBloc, DashboardState, int>(
            selector: (state) =>
                state is DashboardLoaded ? state.unreadNotificationCount : 0,
            builder: (context, count) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: InkWell(
                onTap: () => NotificationPanel.show(context),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(
                            Icons.notifications_outlined,
                            size: 19,
                            color: ThemeColors.unifiedTextMuted,
                          ),
                          Positioned(
                            right: -6,
                            top: -6,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: count > 0
                                    ? ThemeColors.unifiedDanger
                                    : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: Text(
                                count > 99 ? '99+' : '$count',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Text(
                        ConstStrings.navNotifications,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: ThemeColors.unifiedTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),

          // User info section
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ThemeColors.unifiedBackground,
              borderRadius: BorderRadius.circular(12),
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
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: ThemeColors.unifiedTextPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '$companyName · ${roleName.toLowerCase() == 'ceo'
                            ? 'CEO'
                            : user.designation.isNotEmpty
                            ? user.designation
                            : roleName} · $departmentName',
                        style: const TextStyle(
                          fontSize: 11,
                          color: ThemeColors.unifiedTextMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
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
