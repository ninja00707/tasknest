import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/constant/const_dep.dart';
import 'package:tasknest/core/constant/name_by_id.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/theme/common_section_headers.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/widgets/dashboard_stats_section.dart';
import 'package:tasknest/presentation/dashboard/widgets/dashboard_ticket_section.dart';
import 'package:tasknest/presentation/login/models/auth_response_model.dart';
import 'package:tasknest/presentation/login/bloc/login_bloc.dart';
import 'package:tasknest/presentation/login/bloc/login_event.dart';

class DashboardView extends StatelessWidget {
  final DashboardLoaded state;
  final UserModel user;
  const DashboardView({super.key, required this.state, required this.user});

  @override
  Widget build(BuildContext context) {
    final isManager = user.roleId == 0 || user.roleId == 1 || user.roleId == 3;
    return _DashboardBody(state: state, user: user, isManager: isManager);
  }
}

// ── Main scrollable body ──────────────────────────────────────────────────────
class _DashboardBody extends StatelessWidget {
  final DashboardLoaded state;
  final UserModel user;
  final bool isManager;

  const _DashboardBody({
    required this.state,
    required this.user,
    required this.isManager,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 768;
    final s = state.stats;

    final deptLookup = state.departments
        .map((d) => Departments(name: d.name, id: d.id))
        .toList();
    final departmentName = NameById.getNameById<Departments>(
      id: user.departmentId,
      items: deptLookup,
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

    return Container(
      color: ThemeColors.unifiedBackground,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero header (gradient, identity + actions baked in) ─
            _HeroHeader(
              user: user,
              isWide: isWide,
              departmentName: departmentName,
              roleName: roleName,
              companyName: companyName,
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(
                isWide ? 28 : 16,
                isWide ? 24 : 18,
                isWide ? 28 : 16,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Stats section (manager/ceo only) ────────────
                  if (isManager) DashboardStatsSection(s: s, isWide: isWide),

                  // ── Ticket section (employees only) ────────────────
                  if (!isManager) DashboardTicketSection(state: state, user: user),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero header ────────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  final UserModel user;
  final bool isWide;
  final String? departmentName, roleName, companyName;

  const _HeroHeader({
    required this.user,
    required this.isWide,
    this.departmentName,
    this.roleName,
    this.companyName,
  });

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [ThemeColors.unifiedGradStart, ThemeColors.unifiedGradEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative background blobs for depth
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            right: 80,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              isWide ? 28 : 16,
              isWide ? 28 : 20,
              isWide ? 28 : 16,
              isWide ? 26 : 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$greeting,',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withOpacity(0.8),
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.6,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Here\'s what\'s happening with your tickets today',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.75),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _HeroActionButton(
                      icon: Icons.refresh_rounded,
                      label: isWide ? 'Refresh' : null,
                      onTap: () => context.read<DashboardBloc>().add(
                        LoadDashboard(page: 1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _HeroActionButton(
                      icon: Icons.power_settings_new_rounded,
                      label: isWide ? 'Logout' : null,
                      onTap: () {
                        context.read<AuthBloc>().add(LogoutEvent());
                        context.go('/login');
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _IdentityPill(
                  userName: user.name,
                  designation: user.designation,
                  departmentName: departmentName,
                  roleName: roleName,
                  companyName: companyName,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroActionButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback onTap;

  const _HeroActionButton({
    required this.icon,
    required this.onTap,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: label != null ? 14 : 10,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.14),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.white.withOpacity(0.22),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              if (label != null) ...[
                const SizedBox(width: 6),
                Text(
                  label!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Identity pill (glassy, sits inside the hero) ────────────────────────────────
class _IdentityPill extends StatelessWidget {
  final String userName;
  final String designation;
  final String? departmentName, roleName, companyName;

  const _IdentityPill({
    required this.userName,
    this.designation = '',
    this.departmentName,
    this.roleName,
    this.companyName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.2),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                if (companyName != null) _MetaChip(companyName!),
                if (departmentName != null) _MetaChip(departmentName!),
                _MetaChip(
                  roleName?.toLowerCase() == 'ceo'
                      ? 'CEO'
                      : (designation.isNotEmpty
                            ? designation
                            : (roleName ?? '')),
                  emphasis: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String text;
  final bool emphasis;
  const _MetaChip(this.text, {this.emphasis = false});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(emphasis ? 0.24 : 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: emphasis ? FontWeight.w800 : FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
