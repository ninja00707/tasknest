// ══════════════════════════════════════════════════════════════
//  EVENTS
// ══════════════════════════════════════════════════════════════
import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {}

class FilterTickets extends DashboardEvent {
  final String? status;
  final String? priority;
  FilterTickets({this.status, this.priority});
  @override
  List<Object?> get props => [status, priority];
}

class SelfAssignTicket extends DashboardEvent {
  final int ticketId;
  SelfAssignTicket(this.ticketId);
  @override
  List<Object?> get props => [ticketId];
}

class UpdateTicketStatus extends DashboardEvent {
  final int ticketId;
  final String status;
  UpdateTicketStatus(this.ticketId, this.status);
  @override
  List<Object?> get props => [ticketId, status];
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
  final int targetDeptId;
  TransferTicket(this.ticketId, this.targetDeptId);
  @override
  List<Object?> get props => [ticketId, targetDeptId];
}

class ReopenTicket extends DashboardEvent {
  final int ticketId;
  ReopenTicket(this.ticketId);
  @override
  List<Object?> get props => [ticketId];
}

class CreateTicketEvent extends DashboardEvent {
  final String title;
  final String description;
  final String priority;
  final int assignedDeptId;
  final String? dueDate;
  CreateTicketEvent({
    required this.title,
    required this.description,
    required this.priority,
    required this.assignedDeptId,
    this.dueDate,
  });
  @override
  List<Object?> get props => [
    title,
    description,
    priority,
    assignedDeptId,
    dueDate,
  ];
}
