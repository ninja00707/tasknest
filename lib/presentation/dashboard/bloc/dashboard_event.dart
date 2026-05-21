// ══════════════════════════════════════════════════════════════
//  EVENTS
// ══════════════════════════════════════════════════════════════
import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {}

class LoadEmployeesForDept extends DashboardEvent {
  final int deptId;
  LoadEmployeesForDept(this.deptId);
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

  // ADD THESE
  final int createdById;
  final int createdByDept;
  final int? assignedToId; // New field for optional assignment
  final String? dueDate;

  CreateTicketEvent({
    required this.title,
    required this.description,
    required this.priority,
    required this.assignedDeptId,
    required this.assignedToId, // Make assignedToId required in the constructor
    // ADD THESE
    required this.createdById,
    required this.createdByDept,

    this.dueDate,
  });

  @override
  List<Object?> get props => [
    title,
    description,
    priority,
    assignedDeptId,
    createdById,
    createdByDept,
    dueDate,
    assignedToId,
  ];
}

class LoadManagerAnalytics extends DashboardEvent {
  final int departmentId;
  LoadManagerAnalytics(this.departmentId);
  @override
  List<Object?> get props => [departmentId];
}

class LoadCeoAnalytics extends DashboardEvent {}
