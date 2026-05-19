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

        if (ticket == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Ticket Details'),
              backgroundColor: ThemeColors.unifiedSurface,
              elevation: 0,
            ),
            body: const Center(child: Text('Ticket not found')),
          );
        }

        return Scaffold(
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
            child: Column(
              children: [
                // Header Card
                Container(
                  padding: const EdgeInsets.all(20),
                  color: ThemeColors.unifiedSurface,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ticket.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: ThemeColors.unifiedTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  ticket.description,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: ThemeColors.unifiedTextMuted,
                                    height: 1.5,
                                  ),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            children: [
                              PriorityBadge(priority: ticket.priority),
                              const SizedBox(height: 8),
                              StatusBadge(status: ticket.status),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Ticket Info Section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ThemeColors.unifiedSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ThemeColors.unifiedBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TICKET INFORMATION',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: ThemeColors.unifiedTextMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow('Created By:', ticket.createdByName),
                      _buildInfoRow('Department:', ticket.assignedDeptName),
                      if (ticket.assignedToName != null)
                        _buildInfoRow('Assigned To:', ticket.assignedToName!),
                      _buildInfoRow(
                        'Created:',
                        '${ticket.createdAt}',

                        // DateFormat(
                        //   'MMM dd, yyyy HH:mm',
                        // ).format(ticket.createdAt),
                      ),
                      if (ticket.dueDate != null)
                        _buildInfoRow(
                          'Due Date:',
                          '${ticket.dueDate}',
                          // DateFormat('MMM dd, yyyy').format(ticket.dueDate!),
                        ),
                      if (ticket.closedAt != null)
                        _buildInfoRow(
                          'Closed:',
                          '${ticket.closedAt}',
                          // DateFormat(
                          //   'MMM dd, yyyy HH:mm',
                          // ).format(ticket.closedAt!),
                        ),
                      _buildInfoRow('Reopen Count:', '${ticket.reopenCount}'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Actions
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ThemeColors.unifiedSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ThemeColors.unifiedBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [TicketActions(ticket: ticket)],
                  ),
                ),
                const SizedBox(height: 16),

                // Ticket History Timeline
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ThemeColors.unifiedSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ThemeColors.unifiedBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TICKET HISTORY',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: ThemeColors.unifiedTextMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildHistoryTimeline(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
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
