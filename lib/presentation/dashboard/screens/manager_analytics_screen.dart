import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/core/constant/const_dep.dart'; // Import const_dep for departments list
import 'package:tasknest/core/constant/name_by_id.dart'; // Import NameById helper
import 'package:tasknest/data/datasource/localstorage/sharedpreferences.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

class ManagerAnalyticsScreen extends StatefulWidget {
  const ManagerAnalyticsScreen({super.key});

  @override
  State<ManagerAnalyticsScreen> createState() => _ManagerAnalyticsScreenState();
}

class _ManagerAnalyticsScreenState extends State<ManagerAnalyticsScreen> {
  // FIX: Cache the user future so FutureBuilder doesn't re-fire on every rebuild
  late final Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = LocalStorageService().getUser();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final user = await LocalStorageService().getUser();
    if (user != null && mounted) {
      context.read<DashboardBloc>().add(
        LoadManagerAnalytics(user.departmentId),
      );
    }
  }

  // FIX: Extracted shared AppBar to avoid duplication across states
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Department Analytics'),
      backgroundColor: ThemeColors.unifiedSurface,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        // FIX: Removed duplicate loading/error/empty scaffold trees; unified into one
        if (state is AnalyticsLoading) {
          return Scaffold(
            appBar: _buildAppBar(),
            body: const Center(
              child: CircularProgressIndicator(
                color: ThemeColors.unifiedPrimary,
              ),
            ),
          );
        }

        if (state is AnalyticsError) {
          return Scaffold(
            appBar: _buildAppBar(),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: ThemeColors.unifiedDanger,
                  ),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadAnalytics,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is! ManagerAnalyticsLoaded) {
          return Scaffold(appBar: _buildAppBar());
        }

        final stats = state.stats;

        return Scaffold(
          appBar: _buildAppBar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            // FIX: Use cached _userFuture instead of creating a new
            // LocalStorageService().getUser() on every rebuild
            child: FutureBuilder<UserModel?>(
              future: _userFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: Text('Loading user data...'));
                }

                final user = snapshot.data!;
                final departmentName = NameById.getNameById<Departments>(
                  id: user.departmentId,
                  items:
                      departments, // Assuming 'departments' list is available globally or passed
                  idSelector: (e) => e.id,
                  nameSelector: (e) => e.name,
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ThemeColors.unifiedGradStart.withOpacity(0.3),
                            ThemeColors.unifiedGradEnd.withOpacity(0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ThemeColors.unifiedBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Analytics for ${departmentName ?? "Your Department"}', // Use actual department name from const_dep
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: ThemeColors.unifiedTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Real-time overview of your department's ticket metrics",
                            style: TextStyle(
                              fontSize: 14,
                              color: ThemeColors.unifiedTextMuted.withOpacity(
                                0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Overview Cards Grid
                    GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 1.1,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildMetricCard(
                          title: 'Total Tickets',
                          value: '${stats.total}',
                          color: ThemeColors.unifiedPrimary,
                        ),
                        _buildMetricCard(
                          title: 'Open',
                          value: '${stats.open}',
                          color: ThemeColors.unifiedSecondary,
                        ),
                        _buildMetricCard(
                          title: 'In Progress',
                          value: '${stats.inProgress}',
                          color: ThemeColors.unifiedWarning,
                        ),
                        _buildMetricCard(
                          title: 'Completed',
                          value: '${stats.completed}',
                          color: ThemeColors.unifiedAccent,
                        ),
                        _buildMetricCard(
                          title: 'Closed',
                          value: '${stats.closed}',
                          color: ThemeColors.unifiedTextMuted,
                        ),
                        _buildMetricCard(
                          title: 'Overdue',
                          value: '${stats.overdue}',
                          color: ThemeColors.unifiedDanger,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Priority Distribution
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: ThemeColors.unifiedSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ThemeColors.unifiedBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Priority Distribution',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: ThemeColors.unifiedTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildPriorityBar(
                            label: 'Urgent',
                            value: stats.urgent,
                            total: stats.total,
                            color: ThemeColors.unifiedDanger,
                          ),
                          const SizedBox(height: 16),
                          _buildPriorityBar(
                            label: 'High',
                            value: stats.highPriority,
                            total: stats.total,
                            color: const Color(0xFFEA580C),
                          ),
                          const SizedBox(height: 16),
                          _buildPriorityBar(
                            label: 'Medium & Low',
                            value:
                                stats.total - stats.urgent - stats.highPriority,
                            total: stats.total,
                            color: ThemeColors.unifiedPrimary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Status Summary
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: ThemeColors.unifiedSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ThemeColors.unifiedBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status Summary',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: ThemeColors.unifiedTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildStatusSummaryRow(
                            status: 'Open',
                            count: stats.open,
                            percentage: stats.total > 0
                                ? ((stats.open / stats.total) * 100)
                                      .toStringAsFixed(1)
                                : '0.0',
                            color: ThemeColors.unifiedSecondary,
                          ),
                          _buildStatusSummaryRow(
                            status: 'In Progress',
                            count: stats.inProgress,
                            percentage: stats.total > 0
                                ? ((stats.inProgress / stats.total) * 100)
                                      .toStringAsFixed(1)
                                : '0.0',
                            color: ThemeColors.unifiedWarning,
                          ),
                          _buildStatusSummaryRow(
                            status: 'Completed',
                            count: stats.completed,
                            percentage: stats.total > 0
                                ? ((stats.completed / stats.total) * 100)
                                      .toStringAsFixed(1)
                                : '0.0',
                            color: ThemeColors.unifiedAccent,
                          ),
                          _buildStatusSummaryRow(
                            status: 'Closed',
                            count: stats.closed,
                            percentage: stats.total > 0
                                ? ((stats.closed / stats.total) * 100)
                                      .toStringAsFixed(1)
                                : '0.0',
                            color: ThemeColors.unifiedTextMuted,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Key Metrics
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: ThemeColors.unifiedSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ThemeColors.unifiedBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Key Metrics',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: ThemeColors.unifiedTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildMetricRow(
                            label: 'Completion Rate',
                            value:
                                '${((stats.completed / (stats.total > 0 ? stats.total : 1)) * 100).toStringAsFixed(1)}%',
                            color: ThemeColors.unifiedAccent,
                          ),
                          const SizedBox(height: 12),
                          _buildMetricRow(
                            label: 'Critical Issues',
                            value: '${stats.urgent}',
                            color: ThemeColors.unifiedDanger,
                          ),
                          const SizedBox(height: 12),
                          _buildMetricRow(
                            label: 'Overdue Tickets',
                            value: '${stats.overdue}',
                            color: ThemeColors.unifiedWarning,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  // FIX: Restored _buildMetricCard to its correct, clean implementation
  // (previously the method body was replaced with a full duplicate widget tree)
  Widget _buildMetricCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.unifiedBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: ThemeColors.unifiedTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: ThemeColors.unifiedTextMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBar({
    required String label,
    required int value,
    required int total,
    required Color color,
  }) {
    final percentage = total > 0 ? (value / total) * 100 : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ThemeColors.unifiedTextPrimary,
              ),
            ),
            Text(
              '$value (${percentage.toStringAsFixed(1)}%)',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ThemeColors.unifiedTextMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSummaryRow({
    required String status,
    required int count,
    required String percentage,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  status,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: ThemeColors.unifiedTextPrimary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$count ($percentage%)',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ThemeColors.unifiedTextMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow({
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ThemeColors.unifiedTextPrimary,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
