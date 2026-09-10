import 'package:flutter/material.dart';
import 'package:tasknest/core/constant/common_listview_builder.dart';
import 'package:tasknest/core/constant/common_status.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/ticket/widgets/tickets_column.dart';

/// Project tickets rendered EXACTLY like the dashboard kanban board:
/// horizontal scrollable Open / In Progress / Closed columns, each column
/// showing the same dashboard [TicketCard] rows, sorted by priority.
class ProjectTicketsBoard extends StatelessWidget {
  final List<TicketModel> tickets;
  final UserModel? user;
  const ProjectTicketsBoard({super.key, required this.tickets, this.user});

  @override
  Widget build(BuildContext context) {
    final currentUser = user;
    if (currentUser == null) {
      return const SizedBox(
        height: 420,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
      );
    }

    final Map<String, List<TicketModel>> grouped = {};
    for (final t in tickets) {
      grouped.putIfAbsent(t.status, () => []).add(t);
    }
    for (final status in CommonStatus.statuses) {
      (grouped[status] ??= []).sort(
        (a, b) => CommonStatus.priorityWeight(a.priority)
            .compareTo(CommonStatus.priorityWeight(b.priority)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final boardHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : constraints.maxWidth * 0.75;
        return SizedBox(
          height: boardHeight,
          child: CommonListViewBuilder<String>(
            shrinkWrap: false,
            scrollDirection: Axis.horizontal,
            items: CommonStatus.statuses,
            itemBuilder: (context, status, index) {
              return KanbanColumn(
                status: status,
                label: CommonStatus.statusLabel(status),
                color: CommonStatus.ticketStatusColor(status),
                tickets: grouped[status] ?? const [],
                user: currentUser,
              );
            },
          ),
        );
      },
    );
  }
}
