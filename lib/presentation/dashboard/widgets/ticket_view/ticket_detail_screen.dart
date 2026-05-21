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

class TicketDetailScreen extends StatefulWidget {
  final int ticketId;

  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isWide = screenWidth > 1000;

    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is! DashboardLoaded) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Ticket Details'),
              backgroundColor: ThemeColors.unifiedSurface,
              elevation: 0,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final ticket = state.tickets.firstWhere(
          (t) => t.id == widget.ticketId,
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
                      Expanded(flex: 1, child: _buildSidePanel(ticket)),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildMainInfo(ticket),
                      const SizedBox(height: 24),
                      _buildSidePanel(ticket),
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

  Widget _buildSidePanel(TicketModel ticket) {
    return Column(
      children: [
        _buildCard(
          title: 'ACTIONS',
          child: Center(child: TicketActions(ticket: ticket)),
        ),
        const SizedBox(height: 24),
        _buildCard(title: 'HISTORY', child: _buildHistoryTimeline()),
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

  Widget _buildHistoryTimeline() {
    return Column(
      children: [
        _buildHistoryItem(
          icon: Icons.add_circle_outline,
          title: 'Ticket Created',
          description: 'Ticket was created',
          timestamp: 'Created',
          color: ThemeColors.unifiedPrimary,
        ),
        _buildHistoryItem(
          icon: Icons.assignment_ind_outlined,
          title: 'Ticket Assigned',
          description: 'Assigned to department',
          timestamp: 'Status: Open',
          color: ThemeColors.unifiedSecondary,
        ),
        _buildHistoryItem(
          icon: Icons.hourglass_bottom_outlined,
          title: 'In Progress',
          description: 'Work started on ticket',
          timestamp: 'Status: In Progress',
          color: ThemeColors.unifiedWarning,
        ),
        _buildHistoryItem(
          icon: Icons.check_circle_outline,
          title: 'Completed',
          description: 'Work marked as complete',
          timestamp: 'Status: Completed',
          color: ThemeColors.unifiedAccent,
        ),
        _buildHistoryItem(
          icon: Icons.lock_outline,
          title: 'Closed',
          description: 'Ticket was closed',
          timestamp: 'Status: Closed',
          color: ThemeColors.unifiedTextMuted,
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
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            if (!isLast)
              Container(width: 2, height: 30, color: ThemeColors.unifiedBorder),
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
