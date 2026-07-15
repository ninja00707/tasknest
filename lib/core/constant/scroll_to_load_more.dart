import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_bloc.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';

class ScrollToLoadMore extends StatelessWidget {
  final Widget child;
  const ScrollToLoadMore({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          final metrics = notification.metrics;
          if (metrics.maxScrollExtent > 0 &&
              metrics.pixels >= metrics.maxScrollExtent) {
            final bloc = context.read<DashboardBloc>();
            final state = bloc.state;
            DashboardLoaded? loaded;
            if (state is DashboardLoaded) {
              loaded = state;
            } else if (state is DashboardActionSuccess) {
              loaded = state.previousState;
            } else if (state is DashboardActionError) {
              loaded = state.previousState;
            } else if (state is TicketDetailLoaded) {
              loaded = state.previousState;
            }
            if (loaded != null &&
                !loaded.isLoadingMore &&
                loaded.currentPage < loaded.totalPages) {
              bloc.add(LoadMoreTickets());
            }
          }
        }
        return false;
      },
      child: child,
    );
  }
}
