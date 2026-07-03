import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_bloc.dart';
import 'package:tasknest/presentation/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:tasknest/presentation/admin/presentation/screens/admin_users_screen.dart';
import 'package:tasknest/presentation/admin/presentation/screens/admin_departments_screen.dart';
import 'package:tasknest/presentation/admin/presentation/screens/admin_tickets_screen.dart';
import 'package:tasknest/presentation/admin/presentation/screens/admin_user_activity_screen.dart';
import 'package:tasknest/presentation/admin/presentation/widgets/admin_sidebar.dart';
import 'package:tasknest/presentation/login/models/auth_response_model.dart';

class AdminShellScreen extends StatefulWidget {
  final UserModel user;
  const AdminShellScreen({super.key, required this.user});

  @override
  State<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends State<AdminShellScreen> {
  int _selectedIndex = 0;
  final _pages = <Widget>[];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      AdminDashboardScreen(bloc: context.read<AdminBloc>()),
      AdminUsersScreen(bloc: context.read<AdminBloc>()),
      AdminDepartmentsScreen(bloc: context.read<AdminBloc>()),
      AdminTicketsScreen(bloc: context.read<AdminBloc>()),
      AdminUserActivityScreen(bloc: context.read<AdminBloc>()),
    ]);
  }

  void _onNav(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.unifiedBackground,
      body: SafeArea(
        child: Row(
          children: [
            AdminSidebar(
              selectedIndex: _selectedIndex,
              onNav: _onNav,
              user: widget.user,
              onBackToMain: () => context.go('/dashboard'),
            ),
            Expanded(
              child: _pages[_selectedIndex],
            ),
          ],
        ),
      ),
    );
  }
}
