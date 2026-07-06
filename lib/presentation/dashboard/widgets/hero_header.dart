import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/core/routes/routes_name.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/widgets/hero_action_button.dart';
import 'package:tasknest/presentation/dashboard/widgets/identity_pill.dart';
import 'package:tasknest/presentation/login/bloc/login_bloc.dart';
import 'package:tasknest/presentation/login/bloc/login_event.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';

// ── Hero header ────────────────────────────────────────────────────────────────
class HeroHeader extends StatelessWidget {
  final UserModel user;
  final bool isWide;
  final String? departmentName, roleName, companyName;

  const HeroHeader({
    super.key,
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
        ? ConstStrings.goodMorning
        : hour < 17
        ? ConstStrings.goodAfternoon
        : ConstStrings.goodEvening;

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
                            ConstStrings.dashboardSubtitle,
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
                    HeroActionButton(
                      icon: Icons.refresh_rounded,
                      label: isWide ? ConstStrings.refresh : null,
                      onTap: () => context.read<DashboardBloc>().add(
                        LoadDashboard(page: 1),
                      ),
                    ),
                    const SizedBox(width: 8),
                    HeroActionButton(
                      icon: Icons.power_settings_new_rounded,
                      label: isWide ? ConstStrings.logout : null,
                      onTap: () {
                        context.read<AuthBloc>().add(LogoutEvent());
                        context.go(RouteNames.login);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                IdentityPill(
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
