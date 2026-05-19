import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/theme/color.dart';
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
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Analytics'),
              backgroundColor: ThemeColors.unifiedSurface,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
            body: const Center(
              child: CircularProgressIndicator(
                color: ThemeColors.unifiedPrimary,
              ),
            ),
          );
        }

        if (state is! DashboardLoaded) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Analytics'),
              backgroundColor: ThemeColors.unifiedSurface,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
          );
        }

        final stats = state.stats;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Department Analytics'),
            backgroundColor: ThemeColors.unifiedSurface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder<UserModel?>(
              future: LocalStorageService().getUser(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: Text('Loading user data...'));
                }

                final user = snapshot.data!;

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
                            'Analytics for ',
                            // 'Analytics for ${user.departmentName}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: ThemeColors.unifiedTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Real-time overview of your department\'s ticket metrics',
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
                          // icon: Icons.receipt_outline,
                          color: ThemeColors.unifiedPrimary,
                        ),
                        _buildMetricCard(
                          title: 'Open',
                          value: '${stats.open}',
                          // icon: Icons.folder_open_outlined,
                          color: ThemeColors.unifiedSecondary,
                        ),
                        _buildMetricCard(
                          title: 'In Progress',
                          value: '${stats.inProgress}',
                          // icon: Icons.hourglass_bottom_outlined,
                          color: ThemeColors.unifiedWarning,
                        ),
                        _buildMetricCard(
                          title: 'Completed',
                          value: '${stats.completed}',
                          // icon: Icons.check_circle_outline,
                          color: ThemeColors.unifiedAccent,
                        ),
                        _buildMetricCard(
                          title: 'Closed',
                          value: '${stats.closed}',
                          // icon: Icons.lock_outline,
                          color: ThemeColors.unifiedTextMuted,
                        ),
                        _buildMetricCard(
                          title: 'Overdue',
                          value: '${stats.overdue}',
                          // icon: Icons.schedule_outlined,
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
                            // icon: Icons.trending_up_outlined,
                            color: ThemeColors.unifiedAccent,
                          ),
                          const SizedBox(height: 12),
                          _buildMetricRow(
                            label: 'Critical Issues',
                            value: '${stats.urgent}',
                            // icon: Icons.warning_outline,
                            color: ThemeColors.unifiedDanger,
                          ),
                          const SizedBox(height: 12),
                          _buildMetricRow(
                            label: 'Overdue Tickets',
                            value: '${stats.overdue}',
                            // icon: Icons.schedule_outlined,
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

  Widget _buildMetricCard({
    required String title,
    required String value,
    // required IconData icon,
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
            // child: Icon(icon, color: color, size: 20),
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
    // required IconData icon,
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
              // child: Icon(icon, color: color, size: 18),
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
