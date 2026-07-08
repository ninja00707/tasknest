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

class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 24);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 24,
    );
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> old) => false;
}

class HeroHeader extends StatelessWidget {
  final UserModel user;
  final bool isWide;
  final String? departmentName, roleName, companyName;
  final String greeting;

  const HeroHeader({
    super.key,
    required this.user,
    required this.isWide,
    this.departmentName,
    this.roleName,
    this.companyName,
    required this.greeting,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
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
            Positioned(
              top: -50,
              right: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: 60,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                isWide ? 32 : 20,
                isWide ? 32 : 24,
                isWide ? 32 : 20,
                isWide ? 40 : 36,
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
                                color: Colors.white.withValues(alpha: 0.8),
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ConstStrings.dashboardSubtitle,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.7),
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
                  const SizedBox(height: 24),
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
      ),
    );
  }
}
