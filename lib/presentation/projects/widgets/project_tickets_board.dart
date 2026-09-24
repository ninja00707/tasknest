import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tasknest/core/constant/common_listview_builder.dart';
import 'package:tasknest/core/constant/common_status.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/projects/bloc/project_bloc.dart';
import 'package:tasknest/presentation/projects/bloc/project_event.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:tasknest/presentation/ticket/widgets/tickets_column.dart';

/// Project tickets rendered EXACTLY like the dashboard kanban board:
/// horizontal scrollable Open / In Progress / Closed columns, each column
/// showing the same dashboard [TicketCard] rows, sorted by priority.
class ProjectTicketsBoard extends StatelessWidget {
  final List<TicketModel> tickets;
  final UserModel? user;
  final int? projectId;
  const ProjectTicketsBoard({
    super.key,
    required this.tickets,
    this.user,
    this.projectId,
  });

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
                onTicketTap: (ticket) async {
                  await context.push('/ticket/${ticket.id}');
                  if (context.mounted && projectId != null) {
                    context
                        .read<ProjectBloc>()
                        .add(LoadProjectDetail(projectId!));
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}
