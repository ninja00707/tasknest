import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/constant/const_dep.dart';
import 'package:tasknest/core/constant/name_by_id.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_button.dart';
import 'package:tasknest/core/theme/common_decoration.dart';
import 'package:tasknest/core/theme/common_text.dart';
import 'package:tasknest/data/datasource/localstorage/sharedpreferences.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/widgets/state_card.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/ticket_card.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';
import 'package:tasknest/presentation/login/bloc/login_bloc.dart';
import 'package:tasknest/presentation/login/bloc/login_event.dart';

class DashboardView extends StatelessWidget {
  final DashboardLoaded state;
  const DashboardView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final s = state.stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: FutureBuilder<UserModel?>(
        future: LocalStorageService().getUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: ThemeColors.unifiedPrimary,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("No user found"));
          }

          final user = snapshot.data!;
          final departmentName = NameById.getNameById<Departments>(
            id: user.departmentId,
            items: departments,
            idSelector: (e) => e.id,
            nameSelector: (e) => e.name,
          );

          final roleName = NameById.getNameById<Roles>(
            id: user.roleId,
            items: roles,
            idSelector: (e) => e.id,
            nameSelector: (e) => e.name,
          );

          final companyName = NameById.getNameById<Company>(
            id: user.companyId,
            items: CompanyNames,
            idSelector: (e) => e.id,
            nameSelector: (e) => e.name,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome Back ${user.name.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: ThemeColors.unifiedTextPrimary,
                        ),
                      ),
                      CommonText(
                        'Your department ticket overview',
                        customeStyle: CommonDecoration().commonFontstyle,
                      ),
                    ],
                  ),
                  const Spacer(),
                  CommonButton(
                    width: 150,
                    onTap: () {
                      context.read<DashboardBloc>().add(LoadDashboard());
                    },
                    buttonName: 'Refresh',
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                  const SizedBox(width: 20),
                  CommonButton(
                    width: 150,
                    onTap: () {
                      context.read<AuthBloc>().add(LogoutEvent());
                      // LocalStorageService().clearToken();
                      context.go("/login");
                    },
                    buttonName: 'Logout',
                    icon: const Icon(Icons.power_settings_new),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ThemeColors.unifiedGradStart.withOpacity(0.1),
                      ThemeColors.unifiedGradEnd.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: ThemeColors.unifiedBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: ThemeColors.unifiedPrimary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${user.name.toUpperCase()} · '
                        '$departmentName · '
                        '$roleName · '
                        '$companyName',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: ThemeColors.unifiedTextPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Full dept visibility',
                      style: TextStyle(
                        fontSize: 12,
                        color: ThemeColors.unifiedTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cols = constraints.maxWidth > 500 ? 4 : 4;
                  return GridView.count(
                    crossAxisCount: cols,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      StatCard(
                        label: 'Total',
                        count: s.total,
                        color: ThemeColors.unifiedAccent,
                        icon: Icons.inbox_outlined,
                      ),
                      StatCard(
                        label: 'Open',
                        count: s.open,
                        color: ThemeColors.unifiedSecondary,
                        icon: Icons.radio_button_unchecked,
                      ),
                      StatCard(
                        label: 'In Progress',
                        count: s.inProgress,
                        color: ThemeColors.unifiedWarning,
                        icon: Icons.pending_outlined,
                      ),
                      StatCard(
                        label: 'Completed',
                        count: s.completed,
                        color: ThemeColors.unifiedPrimary,
                        icon: Icons.check_circle_outline,
                      ),
                      StatCard(
                        label: 'Closed',
                        count: s.closed,
                        color: ThemeColors.unifiedTextMuted,
                        icon: Icons.lock_outline,
                      ),
                      StatCard(
                        label: 'Urgent',
                        count: s.urgent,
                        color: ThemeColors.unifiedDanger,
                        icon: Icons.warning_amber_rounded,
                      ),
                      StatCard(
                        label: 'High Pri.',
                        count: s.highPriority,
                        color: const Color(0xFFEA580C),
                        icon: Icons.priority_high,
                      ),
                      StatCard(
                        label: 'Overdue',
                        count: s.overdue,
                        color: ThemeColors.unifiedDanger,
                        icon: Icons.access_time_rounded,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Tickets',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: ThemeColors.unifiedTextPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.read<DashboardBloc>().add(
                      SidebarSelectedIndexEvent(sidebarSelectedIndexEvent: 1),
                    ),
                    child: const Text(
                      'View all',
                      style: TextStyle(color: ThemeColors.unifiedSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (state.tickets.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No tickets found.',
                      style: TextStyle(color: ThemeColors.unifiedTextMuted),
                    ),
                  ),
                )
              else
                ...state.tickets.take(5).map((t) => TicketCard(ticket: t)),
              const SizedBox(height: 24),
              if (state.sentTickets.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Transferred From Your Department',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: ThemeColors.unifiedTextPrimary,
                      ),
                    ),
                    const Text(
                      'Sent tickets',
                      style: TextStyle(color: ThemeColors.unifiedTextMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...state.sentTickets.take(5).map((t) => TicketCard(ticket: t)),
              ],
            ],
          );
        },
      ),
    );
  }
}
