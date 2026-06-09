import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_bloc.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_event.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_state.dart';

class AdminDashboardScreen extends StatefulWidget {
  final AdminBloc bloc;
  const AdminDashboardScreen({super.key, required this.bloc});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    widget.bloc.add(LoadAdminDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Admin Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: ThemeColors.unifiedTextPrimary)),
              const SizedBox(height: 8),
              Text('System overview and management', style: TextStyle(fontSize: 14, color: ThemeColors.unifiedTextMuted)),
              const SizedBox(height: 24),
              if (state is AdminLoading) const Center(child: CircularProgressIndicator())
              else if (state is AdminDashboardLoaded) _buildStats(state.stats)
              else if (state is AdminError) Center(child: Text(state.message, style: const TextStyle(color: ThemeColors.unifiedDanger)))
              else const SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStats(dynamic stats) {
    return Column(
      children: [
        Row(
          children: [
            _card('Total Users', '${stats.totalUsers}', Icons.people, ThemeColors.unifiedPrimary),
            const SizedBox(width: 16),
            _card('Total Departments', '${stats.totalDepartments}', Icons.business, ThemeColors.unifiedSecondary),
            const SizedBox(width: 16),
            _card('Total Tickets', '${stats.totalTickets}', Icons.confirmation_number, Colors.orange),
            const SizedBox(width: 16),
            _card('Companies', '${stats.totalCompanies}', Icons.apartment, ThemeColors.unifiedAccent),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _card('Open', '${stats.openTickets}', Icons.pending, ThemeColors.statusOpenFg),
            const SizedBox(width: 16),
            _card('In Progress', '${stats.inProgressTickets}', Icons.play_circle, ThemeColors.statusProgressFg),
            const SizedBox(width: 16),
            _card('Completed', '${stats.completedTickets}', Icons.check_circle, ThemeColors.statusDoneFg),
            const SizedBox(width: 16),
            _card('Closed', '${stats.closedTickets}', Icons.archive, ThemeColors.statusClosedFg),
          ],
        ),
      ],
    );
  }

  Widget _card(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ThemeColors.unifiedBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color)),
                const SizedBox(height: 2),
                Text(label, style: const TextStyle(fontSize: 13, color: ThemeColors.unifiedTextMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
