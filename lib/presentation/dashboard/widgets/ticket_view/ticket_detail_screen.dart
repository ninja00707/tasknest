import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/theme/color.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';

import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/model/ticketmodel.dart';

import 'package:tasknest/presentation/dashboard/widgets/priority_badges.dart';
import 'package:tasknest/presentation/dashboard/widgets/status_badges.dart';
import 'package:tasknest/presentation/dashboard/widgets/ticket_view/ticket_action.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

class TicketDetailScreen extends StatelessWidget {
  final int ticketId;
  final UserModel user;

  const TicketDetailScreen({
    super.key,
    required this.ticketId,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isWide = screenWidth > 1000;

    return BlocBuilder<DashboardBloc, DashboardState>(
      buildWhen: (prev, curr) =>
          curr is DashboardLoaded || curr is DashboardLoading,
      builder: (context, state) {
        if (state is! DashboardLoaded) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Loading...'),
              backgroundColor: ThemeColors.unifiedSurface,
              elevation: 0,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final ticket = state.tickets.firstWhere(
          (t) => t.id == ticketId,
          orElse: () => TicketModel(
            id: 0,
            title: 'Unknown Ticket',
            description: 'No description available',
            priority: 'Low',
            status: 'Unknown',
            assignedDeptCode: '',
            assignedDeptName: '',
            createdByName: '',
            createdByDeptCode: '',
            createdAt: DateTime.now(),
            reopenCount: 0,
          ),
        );

        return Scaffold(
          backgroundColor: ThemeColors.unifiedBackground,
          appBar: AppBar(
            title: Text('Ticket #${ticket.id}'),
            backgroundColor: ThemeColors.unifiedSurface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? screenWidth * 0.1 : 16,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gradient Header
                Container(
                  padding: const EdgeInsets.all(24),
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
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticket.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: ThemeColors.unifiedTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Tracking details and history for this request",
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          PriorityBadge(priority: ticket.priority),
                          const SizedBox(height: 8),
                          StatusBadge(status: ticket.status),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Main Content Area
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildMainInfo(ticket)),
                      const SizedBox(width: 24),
                      Expanded(flex: 1, child: _buildSidePanel(ticket, user)),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildMainInfo(ticket),
                      const SizedBox(height: 24),
                      _buildSidePanel(ticket, user),
                    ],
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainInfo(TicketModel ticket) {
    return Column(
      children: [
        _buildCard(
          title: 'DESCRIPTION',
          child: Text(
            ticket.description,
            style: const TextStyle(
              fontSize: 15,
              color: ThemeColors.unifiedTextPrimary,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildCard(
          title: 'TICKET DETAILS',
          child: Column(
            children: [
              _buildInfoRow('Created By:', ticket.createdByName),
              _buildInfoRow('Department:', ticket.assignedDeptName),
              if (ticket.assignedToName != null)
                _buildInfoRow('Assigned To:', ticket.assignedToName!),
              _buildInfoRow(
                'Created At:',
                ticket.createdAt.toString().split('.').first,
              ),
              if (ticket.dueDate != null)
                _buildInfoRow('Due Date:', ticket.dueDate!.toString()),
              if (ticket.closedAt != null)
                _buildInfoRow('Closed At:', ticket.toString()),
              _buildInfoRow('Reopen Count:', '${ticket.reopenCount}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidePanel(TicketModel ticket, UserModel user) {
    return Column(
      children: [
        _buildCard(
          title: 'ACTIONS',
          child: Center(
            child: TicketActions(ticket: ticket, user: user),
          ),
        ),
        const SizedBox(height: 24),
        _buildCard(
          title: 'TICKET PROGRESS',
          child: _buildHistoryTimeline(ticket.status),
        ),
      ],
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ThemeColors.unifiedSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeColors.unifiedBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: ThemeColors.unifiedTextMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: ThemeColors.unifiedTextMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                color: ThemeColors.unifiedTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTimeline(String currentStatus) {
    final status = currentStatus.toLowerCase();

    bool isPassed(int step) {
      if (status == 'closed') return true;
      if (status == 'completed' && step <= 3) return true;
      if (status == 'in_progress' && step <= 2) return true;
      if (status == 'open' && step <= 1) return true;
      return false;
    }

    return Column(
      children: [
        _buildHistoryItem(
          icon: Icons.add_circle_outline,
          title: 'Ticket Created',
          description: 'The request has been logged in the system.',
          timestamp: 'Step 1',
          color: ThemeColors.unifiedPrimary,
          isActive: isPassed(1),
        ),
        _buildHistoryItem(
          icon: Icons.assignment_ind_outlined,
          title: 'Ticket Assigned',
          description: 'Pending pick-up or assignment to a resolver.',
          timestamp: 'Step 2',
          color: ThemeColors.unifiedSecondary,
          isActive: isPassed(2),
        ),
        _buildHistoryItem(
          icon: Icons.hourglass_bottom_outlined,
          title: 'In Progress',
          description: 'A resolver is currently working on the task.',
          timestamp: 'Step 3',
          color: ThemeColors.unifiedWarning,
          isActive: isPassed(3),
        ),
        _buildHistoryItem(
          icon: Icons.check_circle_outline,
          title: 'Completed',
          description: 'Task finished and awaiting final closure.',
          timestamp: 'Step 4',
          color: ThemeColors.unifiedAccent,
          isActive: isPassed(4),
        ),
        _buildHistoryItem(
          icon: Icons.lock_outline,
          title: 'Closed',
          description: 'Ticket is resolved and archived.',
          timestamp: 'Final',
          color: ThemeColors.unifiedTextMuted,
          isActive: status == 'closed',
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildHistoryItem({
    required IconData icon,
    required String title,
    required String description,
    required String timestamp,
    required Color color,
    required bool isActive,
    bool isLast = false,
  }) {
    final displayColor = isActive ? color : ThemeColors.unifiedBorder;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive ? color.withOpacity(0.1) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: displayColor, width: 2),
              ),
              child: Icon(icon, color: displayColor, size: 20),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: isActive
                    ? color.withOpacity(0.5)
                    : ThemeColors.unifiedBorder,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.unifiedTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: ThemeColors.unifiedTextMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                timestamp,
                style: TextStyle(
                  fontSize: 11,
                  color: ThemeColors.unifiedTextMuted.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
