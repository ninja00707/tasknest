import 'package:flutter/material.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/widgets/hero_header.dart';
import 'package:tasknest/presentation/dashboard/widgets/role_body.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';

class DashboardView extends StatelessWidget {
  final DashboardLoaded state;
  final UserModel user;
  const DashboardView({super.key, required this.state, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ThemeColors.unifiedBackground,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeroHeader(
              user: user,
              isWide: state.isWide,
              departmentName: state.departmentName,
              roleName: state.roleName,
              companyName: state.companyName,
              greeting: state.greeting,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.fromLTRB(
                state.isWide ? 28 : 16,
                state.isWide ? 20 : 14,
                state.isWide ? 28 : 16,
                24,
              ),
              child: RoleBody(state: state, user: user),
            ),
          ],
        ),
      ),
    );
  }
}
