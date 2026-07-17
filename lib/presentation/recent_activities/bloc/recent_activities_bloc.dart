import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/presentation/recent_activities/bloc/recent_activities_event.dart';
import 'package:tasknest/presentation/recent_activities/bloc/recent_activities_state.dart';

class RecentActivitiesBloc extends Bloc<RecentActivitiesEvent, RecentActivitiesState> {
  RecentActivitiesBloc() : super(RecentActivitiesInitial()) {
    on<LoadRecentActivities>(_onLoad);
    on<RecentPageChanged>(_onPageChanged);
    on<UpdateRecentScreenSize>(_onScreenSizeChanged);
  }

  void _onLoad(LoadRecentActivities event, Emitter<RecentActivitiesState> emit) {
    final sorted = [...event.tickets]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final totalPages = sorted.isEmpty ? 1 : (sorted.length / 15).ceil().clamp(1, 9999);
    final start = 0;
    final end = sorted.length > 15 ? 15 : sorted.length;
    final paged = sorted.sublist(start, end);

    emit(RecentActivitiesLoaded(
      allTickets: sorted,
      currentPage: 1,
      totalPages: totalPages,
      pagedTickets: paged,
      isWide: event.isWide,
      screenWidth: event.screenWidth,
    ));
  }

  void _onPageChanged(RecentPageChanged event, Emitter<RecentActivitiesState> emit) {
    final current = state;
    if (current is RecentActivitiesLoaded) {
      emit(current.copyWith(currentPage: event.page));
    }
  }

  void _onScreenSizeChanged(UpdateRecentScreenSize event, Emitter<RecentActivitiesState> emit) {
    final current = state;
    if (current is RecentActivitiesLoaded) {
      emit(current.copyWith(isWide: event.isWide, screenWidth: event.screenWidth));
    }
  }
}
