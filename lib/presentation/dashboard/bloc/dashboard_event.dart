import 'package:equatable/equatable.dart';


abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {}

class FilterTickets extends DashboardEvent {
  final String? status;
  final String? priority;

  const FilterTickets({this.status, this.priority});

  @override
  List<Object?> get props => [status, priority];
}

class SelfAssignTicket extends DashboardEvent {
  final int ticketId;

  const SelfAssignTicket(this.ticketId);

  @override
  List<Object?> get props => [ticketId];
}

class UpdateTicketStatus extends DashboardEvent {
  final int ticketId;
  final String status;
  final String? remark;

  const UpdateTicketStatus(this.ticketId, this.status, {this.remark});

  @override
  List<Object?> get props => [ticketId, status, remark];
}

class AssignTicketToEmployee extends DashboardEvent {
  final int ticketId;
  final int employeeId;

  const AssignTicketToEmployee(this.ticketId, this.employeeId);

  @override
  List<Object?> get props => [ticketId, employeeId];
}

class TransferTicket extends DashboardEvent {
  final int ticketId;
  final int targetDeptId;

  const TransferTicket(this.ticketId, this.targetDeptId);

  @override
  List<Object?> get props => [ticketId, targetDeptId];
}

class ReopenTicket extends DashboardEvent {
  final int ticketId;

  const ReopenTicket(this.ticketId);

  @override
  List<Object?> get props => [ticketId];
}

class CreateTicket extends DashboardEvent {
  final String title;
  final String description;
  final String priority;
  final int assignedDeptId;
  final DateTime? dueDate;
  final int? parentId;

  const CreateTicket({
    required this.title,
    required this.description,
    required this.priority,
    required this.assignedDeptId,
    this.dueDate,
    this.parentId,
  });

  @override
  List<Object?> get props => [title, description, priority, assignedDeptId, dueDate, parentId];
}

class AddTicketComment extends DashboardEvent {
  final int ticketId;
  final String message;

  const AddTicketComment(this.ticketId, this.message);

  @override
  List<Object?> get props => [ticketId, message];
}

class SidebarSelectedIndexEvent extends DashboardEvent {
  final int sidebarSelectedIndexEvent;

  const SidebarSelectedIndexEvent({required this.sidebarSelectedIndexEvent});

  @override
  List<Object> get props => [sidebarSelectedIndexEvent];
}

class LoadEmployeesForDept extends DashboardEvent {
  final int deptId;

  const LoadEmployeesForDept(this.deptId);

  @override
  List<Object> get props => [deptId];
}

class LoadManagerAnalytics extends DashboardEvent {
  final int departmentId;

  const LoadManagerAnalytics(this.departmentId);

  @override
  List<Object> get props => [departmentId];
}

class LoadCeoAnalytics extends DashboardEvent {}
