import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/data/datasource/localstorage/sharedpreferences.dart';
import 'package:tasknest/data/datasource/ticketdatasource/ticket_remote_data_source.dart';
import 'package:tasknest/injection.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

class DepartmentAnalyticsModel {
  final int deptId;
  final String deptCode;
  final String deptName;
  final int total;
  final int open;
  final int inProgress;
  final int completed;
  final int closed;
  final int urgent;
  final int highPriority;
  final int overdue;
  final double avgResolutionHours;

  DepartmentAnalyticsModel({
    required this.deptId,
    required this.deptCode,
    required this.deptName,
    required this.total,
    required this.open,
    required this.inProgress,
    required this.completed,
    required this.closed,
    required this.urgent,
    required this.highPriority,
    required this.overdue,
    required this.avgResolutionHours,
  });

  factory DepartmentAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return DepartmentAnalyticsModel(
      deptId: json['dept_id'] ?? 0,
      deptCode: json['dept_code'] ?? '',
      deptName: json['dept_name'] ?? '',
      total: json['total'] ?? 0,
      open: json['open'] ?? 0,
      inProgress: json['in_progress'] ?? 0,
      completed: json['completed'] ?? 0,
      closed: json['closed'] ?? 0,
      urgent: json['urgent'] ?? 0,
      highPriority: json['high_priority'] ?? 0,
      overdue: json['overdue'] ?? 0,
      avgResolutionHours:
          (json['avg_resolution_hours'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CeoAnalyticsScreen extends StatefulWidget {
  const CeoAnalyticsScreen({super.key});

  @override
  State<CeoAnalyticsScreen> createState() => _CeoAnalyticsScreenState();
}

class _CeoAnalyticsScreenState extends State<CeoAnalyticsScreen> {
  late Future<List<DepartmentAnalyticsModel>> _analyticsFuture;

  @override
  void initState() {
    super.initState();
    _analyticsFuture = _fetchAnalytics();
  }

  Future<List<DepartmentAnalyticsModel>> _fetchAnalytics() async {
    try {
      final response = await apiClient.get('tickets/analytics/by-department');
      final List<dynamic> data = response['data'] ?? [];
      return data
          .map((item) => DepartmentAnalyticsModel.fromJson(item))
          .toList();
    } catch (e) {
      print('Error fetching analytics: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organization Analytics'),
        backgroundColor: ThemeColors.unifiedSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder<List<DepartmentAnalyticsModel>>(
        future: _analyticsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: ThemeColors.unifiedPrimary,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: ThemeColors.unifiedDanger,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading analytics',
                    style: TextStyle(
                      fontSize: 16,
                      color: ThemeColors.unifiedDanger,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _analyticsFuture = _fetchAnalytics();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final analytics = snapshot.data ?? [];

          if (analytics.isEmpty) {
            return const Center(
              child: Text(
                'No department data available',
                style: TextStyle(color: ThemeColors.unifiedTextMuted),
              ),
            );
          }

          final totalTickets = analytics.fold<int>(
            0,
            (sum, a) => sum + a.total,
          );
          final totalOpen = analytics.fold<int>(0, (sum, a) => sum + a.open);
          final totalInProgress = analytics.fold<int>(
            0,
            (sum, a) => sum + a.inProgress,
          );
          final totalCompleted = analytics.fold<int>(
            0,
            (sum, a) => sum + a.completed,
          );
          final totalClosed = analytics.fold<int>(
            0,
            (sum, a) => sum + a.closed,
          );
          final totalUrgent = analytics.fold<int>(
            0,
            (sum, a) => sum + a.urgent,
          );
          final totalOverdue = analytics.fold<int>(
            0,
            (sum, a) => sum + a.overdue,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Organization Overview Header
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
                      const Text(
                        'Organization Overview',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: ThemeColors.unifiedTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Real-time analytics across all ${analytics.length} departments',
                        style: TextStyle(
                          fontSize: 14,
                          color: ThemeColors.unifiedTextMuted.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Overall Metrics Grid
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
                      value: '$totalTickets',
                      // icon: Icons.receipt_outline,
                      color: ThemeColors.unifiedPrimary,
                    ),
                    _buildMetricCard(
                      title: 'Open',
                      value: '$totalOpen',
                      // icon: Icons.folder_open_outlined,
                      color: ThemeColors.unifiedSecondary,
                    ),
                    _buildMetricCard(
                      title: 'In Progress',
                      value: '$totalInProgress',
                      // icon: Icons.hourglass_bottom_outlined,
                      color: ThemeColors.unifiedWarning,
                    ),
                    _buildMetricCard(
                      title: 'Completed',
                      value: '$totalCompleted',
                      // icon: Icons.check_circle_outline,
                      color: ThemeColors.unifiedAccent,
                    ),
                    _buildMetricCard(
                      title: 'Closed',
                      value: '$totalClosed',
                      // icon: Icons.lock_outline,
                      color: ThemeColors.unifiedTextMuted,
                    ),
                    _buildMetricCard(
                      title: 'Urgent',
                      value: '$totalUrgent',
                      // icon: Icons.priority_high_outlined,
                      color: ThemeColors.unifiedDanger,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Department Breakdown
                const Text(
                  'Department Breakdown',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: ThemeColors.unifiedTextPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  itemCount: analytics.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final dept = analytics[index];
                    return _buildDepartmentCard(dept);
                  },
                ),
                const SizedBox(height: 24),

                // Performance Comparison
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
                        'Performance Metrics',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: ThemeColors.unifiedTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPerformanceRow(
                        label: 'Overall Completion Rate',
                        value: totalTickets > 0
                            ? '${((totalCompleted / totalTickets) * 100).toStringAsFixed(1)}%'
                            : '0%',
                        // icon: Icons.trending_up_outlined,
                        color: ThemeColors.unifiedAccent,
                      ),
                      const SizedBox(height: 12),
                      _buildPerformanceRow(
                        label: 'Critical Issues',
                        value: '$totalUrgent',
                        // icon: Icon,
                        color: ThemeColors.unifiedDanger,
                      ),
                      const SizedBox(height: 12),
                      _buildPerformanceRow(
                        label: 'Overdue Tickets',
                        value: '$totalOverdue',
                        // icon: Icons.schedule_outlined,
                        color: ThemeColors.unifiedWarning,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
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

  Widget _buildDepartmentCard(DepartmentAnalyticsModel dept) {
    final completionRate = dept.total > 0
        ? ((dept.completed / dept.total) * 100).toStringAsFixed(1)
        : '0.0';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.unifiedBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dept.deptName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: ThemeColors.unifiedTextPrimary,
                    ),
                  ),
                  Text(
                    '${dept.deptCode} • ${dept.total} tickets',
                    style: const TextStyle(
                      fontSize: 12,
                      color: ThemeColors.unifiedTextMuted,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: ThemeColors.unifiedAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ThemeColors.unifiedAccent.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '$completionRate% Done',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: ThemeColors.unifiedAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDeptMetricTag(
                label: 'Open',
                value: '${dept.open}',
                color: ThemeColors.unifiedSecondary,
              ),
              _buildDeptMetricTag(
                label: 'In Progress',
                value: '${dept.inProgress}',
                color: ThemeColors.unifiedWarning,
              ),
              _buildDeptMetricTag(
                label: 'Overdue',
                value: '${dept.overdue}',
                color: ThemeColors.unifiedDanger,
              ),
              _buildDeptMetricTag(
                label: 'Avg Res.',
                value: '${dept.avgResolutionHours.toStringAsFixed(1)}h',
                color: ThemeColors.unifiedPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeptMetricTag({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: ThemeColors.unifiedTextMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceRow({
    required String label,
    required String value,
    // required Icon icon,
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
