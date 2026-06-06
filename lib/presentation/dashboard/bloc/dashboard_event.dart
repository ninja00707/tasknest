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
  final String? remark;
  UpdateTicketStatus(this.ticketId, this.status, {this.remark});
  @override
  List<Object?> get props => [ticketId, status, remark];
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
  final String? title;
  final String? description;
  TransferTicket(this.ticketId, this.targetDeptId, {this.title, this.description});
  @override
  List<Object?> get props => [ticketId, targetDeptId, title, description];
}

class ReopenTicket extends DashboardEvent {
  final int ticketId;
  ReopenTicket(this.ticketId);
  @override
  List<Object?> get props => [ticketId];
}

class DeptTicketData {
  final int departmentId;
  final String title;
  final String description;

  DeptTicketData({
    required this.departmentId,
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    'department_id': departmentId,
    'title': title,
    'description': description,
  };
}

class CreateTicketEvent extends DashboardEvent {
  final String title;
  final String description;
  final String priority;
  final List<int> departmentIds;
  final int createdById;
  final int createdByDept;
  final int? assignedToId;
  final String? dueDate;
  final int? parentTicketId;
  final bool selfAssign;
  final String? subTitle;
  final String? subDescription;
  final List<DeptTicketData>? deptTickets;

  CreateTicketEvent({
    required this.title,
    required this.description,
    required this.priority,
    required this.departmentIds,
    required this.assignedToId,
    required this.createdById,
    required this.createdByDept,
    this.dueDate,
    this.parentTicketId,
    this.selfAssign = false,
    this.subTitle,
    this.subDescription,
    this.deptTickets,
  });

  @override
  List<Object?> get props => [
    title, description, priority, departmentIds,
    createdById, createdByDept, dueDate, assignedToId,
    parentTicketId, selfAssign, subTitle, subDescription, deptTickets,
  ];
}

class LoadManagerAnalytics extends DashboardEvent {
  final int departmentId;
  LoadManagerAnalytics(this.departmentId);
  @override
  List<Object?> get props => [departmentId];
}

class LoadCeoAnalytics extends DashboardEvent {}

class CreateSubTicketEvent extends DashboardEvent {
  final String title;
  final String description;
  final String priority;
  final List<Map<String, dynamic>> departments;
  final String? dueDate;
  final int? parentTicketId;

  CreateSubTicketEvent({
    required this.title,
    required this.description,
    required this.priority,
    required this.departments,
    this.dueDate,
    this.parentTicketId,
  });

  @override
  List<Object?> get props => [
    title,
    description,
    priority,
    departments,
    dueDate,
    parentTicketId,
  ];
}

class UpdateSubDeptProgressEvent extends DashboardEvent {
  final int ticketId;
  final int departmentId;
  final String? status;
  final String? note;

  UpdateSubDeptProgressEvent({
    required this.ticketId,
    required this.departmentId,
    this.status,
    this.note,
  });

  @override
  List<Object?> get props => [ticketId, departmentId, status, note];
}

class AssignSubDeptEmployeeEvent extends DashboardEvent {
  final int ticketId;
  final int departmentId;
  final int employeeId;

  AssignSubDeptEmployeeEvent({
    required this.ticketId,
    required this.departmentId,
    required this.employeeId,
  });

  @override
  List<Object?> get props => [ticketId, departmentId, employeeId];
}

class SelfAssignSubDept extends DashboardEvent {
  final int ticketId;
  final int departmentId;
  SelfAssignSubDept(this.ticketId, this.departmentId);
  @override
  List<Object?> get props => [ticketId, departmentId];
}

class CompleteSubTicket extends DashboardEvent {
  final int ticketId;
  CompleteSubTicket(this.ticketId);
  @override
  List<Object?> get props => [ticketId];
}

class ReopenSubDept extends DashboardEvent {
  final int ticketId;
  final int departmentId;
  ReopenSubDept({required this.ticketId, required this.departmentId});
  @override
  List<Object?> get props => [ticketId, departmentId];
}

class AddTicketComment extends DashboardEvent {
  final int ticketId;
  final String message;

  AddTicketComment(this.ticketId, this.message);

  @override
  List<Object?> get props => [ticketId, message];
}

class UpdateNotificationCount extends DashboardEvent {
  final int count;
  UpdateNotificationCount(this.count);
  @override
  List<Object?> get props => [count];
}
