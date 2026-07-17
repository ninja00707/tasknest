import 'package:flutter/material.dart';
import 'package:tasknest/core/constant/common_listview_builder.dart';
import 'package:tasknest/core/constant/common_status.dart';
import 'package:tasknest/presentation/login/models/user_model.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/ticket/widgets/tickets_column.dart';

class KanbanBoard extends StatefulWidget {
  final DashboardLoaded state;
  final UserModel user;
  const KanbanBoard({super.key, required this.state, required this.user});

  @override
  State<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<KanbanBoard> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : widget.state.screenWidth * 0.75;
        return SizedBox(
          height: boardHeight,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 64, 0),
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              trackVisibility: true,
              scrollbarOrientation: ScrollbarOrientation.bottom,
              child: CommonListViewBuilder<String>(
                controller: _scrollController,
                shrinkWrap: false,
                scrollDirection: Axis.horizontal,
                items: CommonStatus.statuses,
                itemBuilder: (context, status, index) {
                  return KanbanColumn(
                    status: status,
                    label: CommonStatus.statusLabel(status),
                    color: CommonStatus.ticketStatusColor(status),
                    tickets: widget.state.groupedTickets[status] ?? [],
                    user: widget.user,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
