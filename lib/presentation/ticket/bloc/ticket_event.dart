import 'package:equatable/equatable.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

abstract class TicketEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SelfAssignTicket extends TicketEvent {
  final int ticketId;
  SelfAssignTicket(this.ticketId);
  @override
  List<Object?> get props => [ticketId];
}

class UpdateTicketStatus extends TicketEvent {
  final int ticketId;
  final String status;
  final String? remark;
  UpdateTicketStatus(this.ticketId, this.status, {this.remark});
  @override
  List<Object?> get props => [ticketId, status, remark];
}

class AssignTicketToEmployee extends TicketEvent {
  final int ticketId;
  final int employeeId;
  AssignTicketToEmployee(this.ticketId, this.employeeId);
  @override
  List<Object?> get props => [ticketId, employeeId];
}

class TransferTicket extends TicketEvent {
  final int ticketId;
  final int targetDeptId;
  final String? title;
  final String? description;
  TransferTicket(
    this.ticketId,
    this.targetDeptId, {
    this.title,
    this.description,
  });
  @override
  List<Object?> get props => [ticketId, targetDeptId, title, description];
}

class ReopenTicket extends TicketEvent {
  final int ticketId;
  ReopenTicket(this.ticketId);
  @override
  List<Object?> get props => [ticketId];
}

class UpdateTicketDescription extends TicketEvent {
  final int ticketId;
  final String description;
  UpdateTicketDescription(this.ticketId, this.description);
  @override
  List<Object?> get props => [ticketId, description];
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

class CreateTicketEvent extends TicketEvent {
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
    title,
    description,
    priority,
    departmentIds,
    createdById,
    createdByDept,
    dueDate,
    assignedToId,
    parentTicketId,
    selfAssign,
    subTitle,
    subDescription,
    deptTickets,
  ];
}

class CreateSubTicketEvent extends TicketEvent {
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

class UpdateSubDeptProgressEvent extends TicketEvent {
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

class AssignSubDeptEmployeeEvent extends TicketEvent {
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

class SelfAssignSubDept extends TicketEvent {
  final int ticketId;
  final int departmentId;
  SelfAssignSubDept(this.ticketId, this.departmentId);
  @override
  List<Object?> get props => [ticketId, departmentId];
}

class CompleteSubTicket extends TicketEvent {
  final int ticketId;
  CompleteSubTicket(this.ticketId);
  @override
  List<Object?> get props => [ticketId];
}

class ReopenSubDept extends TicketEvent {
  final int ticketId;
  final int departmentId;
  ReopenSubDept({required this.ticketId, required this.departmentId});
  @override
  List<Object?> get props => [ticketId, departmentId];
}

class AddTicketComment extends TicketEvent {
  final int ticketId;
  final String message;
  AddTicketComment(this.ticketId, this.message);
  @override
  List<Object?> get props => [ticketId, message];
}

class LoadTicketDetail extends TicketEvent {
  final int ticketId;
  final bool silent;
  LoadTicketDetail(this.ticketId, {this.silent = false});
  @override
  List<Object?> get props => [ticketId, silent];
}

class ClearTicketDetail extends TicketEvent {}

class SocketTicketDetailUpdated extends TicketEvent {
  final TicketModel ticket;
  SocketTicketDetailUpdated(this.ticket);
  @override
  List<Object?> get props => [ticket.id, ticket.status, ticket.lastUpdatedAt];
}

class MarkTicketAsDone extends TicketEvent {
  final int ticketId;
  final String? remark;
  MarkTicketAsDone(this.ticketId, {this.remark});
  @override
  List<Object?> get props => [ticketId, remark];
}

class FinalizeTicket extends TicketEvent {
  final int ticketId;
  final String? remark;
  FinalizeTicket(this.ticketId, {this.remark});
  @override
  List<Object?> get props => [ticketId, remark];
}

class CloseTicket extends TicketEvent {
  final int ticketId;
  final String? remark;
  CloseTicket(this.ticketId, {this.remark});
  @override
  List<Object?> get props => [ticketId, remark];
}

class DisputeTicket extends TicketEvent {
  final int ticketId;
  final String argument;
  DisputeTicket(this.ticketId, this.argument);
  @override
  List<Object?> get props => [ticketId, argument];
}
