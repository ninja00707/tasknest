import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {}

/// Internal event triggered by the WebSocket
class SocketUpdateReceived extends DashboardEvent {}

class SelfAssignTicket extends DashboardEvent {
  final int ticketId;
  final int userId;
  SelfAssignTicket(this.ticketId, this.userId);
  @override
  List<Object?> get props => [ticketId, userId];
}

class UpdateTicketStatus extends DashboardEvent {
  final int ticketId;
  final String status;
  UpdateTicketStatus(this.ticketId, this.status);
  @override
  List<Object?> get props => [ticketId, status];
}

class ReopenTicket extends DashboardEvent {
  final int ticketId;
  ReopenTicket(this.ticketId);
  @override
  List<Object?> get props => [ticketId];
}

class AssignTicketToEmployee extends DashboardEvent {
  final int ticketId;
  final int employeeId;
  AssignTicketToEmployee(this.ticketId, this.employeeId);
  @override
  List<Object?> get props => [ticketId, employeeId];
}

class TransferTicket extends DashboardEvent {
  final int ticketId;
  final int deptId;
  TransferTicket(this.ticketId, this.deptId);
  @override
  List<Object?> get props => [ticketId, deptId];
}

class FilterTickets extends DashboardEvent {
  final String? status;
  final String? priority;
  FilterTickets({this.status, this.priority});
  @override
  List<Object?> get props => [status, priority];
}

class SidebarSelectedIndexEvent extends DashboardEvent {
  final int sidebarSelectedIndexEvent;
  SidebarSelectedIndexEvent({required this.sidebarSelectedIndexEvent});
  @override
  List<Object?> get props => [sidebarSelectedIndexEvent];
}

class LoadEmployeesForDept extends DashboardEvent {
  final int deptId;
  LoadEmployeesForDept(this.deptId);
  @override
  List<Object?> get props => [deptId];
}

class CreateTicketEvent extends DashboardEvent {
  final String title;
  final String description;
  final String priority;
  final int? assignedDeptId;
  final List<int>? assignedDeptIds;
  final int? assignedToId;
  final int createdById;
  final int createdByDept;
  final String? dueDate;

  CreateTicketEvent({
    required this.title,
    required this.description,
    required this.priority,
    this.assignedDeptId,
    this.assignedDeptIds,
    this.assignedToId,
    required this.createdById,
    required this.createdByDept,
    this.dueDate,
  });
}
