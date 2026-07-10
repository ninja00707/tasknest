import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {
  final int page;
  LoadDashboard({this.page = 1});
  @override
  List<Object?> get props => [page];
}

class FilterTickets extends DashboardEvent {
  final String? status;
  final String? priority;
  final String? search;
  final bool? teamOnly;
  final int page;
  FilterTickets({this.status, this.priority, this.search, this.teamOnly, this.page = 1});
  @override
  List<Object?> get props => [status, priority, search, teamOnly, page];
}

class LoadMoreTickets extends DashboardEvent {}

class UpdateNotificationCount extends DashboardEvent {
  final int count;
  UpdateNotificationCount(this.count);
  @override
  List<Object?> get props => [count];
}

class LoadManagerAnalytics extends DashboardEvent {
  final int departmentId;
  LoadManagerAnalytics(this.departmentId);
  @override
  List<Object?> get props => [departmentId];
}

class LoadCeoAnalytics extends DashboardEvent {}

class ResetDashboardEvent extends DashboardEvent {}

class LoadTicketDetail extends DashboardEvent {
  final int ticketId;
  LoadTicketDetail(this.ticketId);
  @override
  List<Object?> get props => [ticketId];
}

class ClearTicketDetail extends DashboardEvent {}

class ToggleSidebar extends DashboardEvent {}

class MarkVersionSeen extends DashboardEvent {}

class UpdateScreenSize extends DashboardEvent {
  final bool isWide;
  UpdateScreenSize(this.isWide);
  @override
  List<Object?> get props => [isWide];
}
