import 'package:equatable/equatable.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

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
  final double screenWidth;
  UpdateScreenSize(this.isWide, this.screenWidth);
  @override
  List<Object?> get props => [isWide, screenWidth];
}

class UpdateLocalTicket extends DashboardEvent {
  final TicketModel ticket;
  UpdateLocalTicket(this.ticket);
  @override
  List<Object?> get props => [ticket];
}

class SocketTicketCreated extends DashboardEvent {
  final TicketModel ticket;
  SocketTicketCreated(this.ticket);
  @override
  List<Object?> get props => [ticket.id];
}

class SocketTicketUpdated extends DashboardEvent {
  final TicketModel ticket;
  SocketTicketUpdated(this.ticket);
  @override
  List<Object?> get props => [ticket.id, ticket.status, ticket.lastUpdatedAt];
}

class SocketConnectionChanged extends DashboardEvent {
  final bool connected;
  SocketConnectionChanged(this.connected);
  @override
  List<Object?> get props => [connected];
}
