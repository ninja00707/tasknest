import 'package:equatable/equatable.dart';
import 'package:tasknest/core/constant/const_dep.dart';

sealed class CreateTicketEvent extends Equatable {
  const CreateTicketEvent();
}

final class UpdatePriority extends CreateTicketEvent {
  final Priorities priority;
  const UpdatePriority(this.priority);
  @override
  List<Object> get props => [priority.name];
}

final class AddDepartment extends CreateTicketEvent {
  final Departments department;
  const AddDepartment(this.department);
  @override
  List<Object> get props => [department.id];
}

final class RemoveDepartment extends CreateTicketEvent {
  final Departments department;
  const RemoveDepartment(this.department);
  @override
  List<Object> get props => [department.id];
}

final class UpdateEmployee extends CreateTicketEvent {
  final dynamic employee;
  const UpdateEmployee(this.employee);
  @override
  List<Object> get props => [employee?.hashCode ?? 0];
}

final class ToggleSelfAssign extends CreateTicketEvent {
  final bool value;
  const ToggleSelfAssign(this.value);
  @override
  List<Object> get props => [value];
}

final class SubmitTicket extends CreateTicketEvent {
  final String title;
  final String description;
  final int createdById;
  final int createdByDept;
  final int? parentTicketId;
  final int? projectId;
  final Map<int, ({String title, String description})>? deptTickets;

  const SubmitTicket({
    required this.title,
    required this.description,
    required this.createdById,
    required this.createdByDept,
    this.parentTicketId,
    this.projectId,
    this.deptTickets,
  });

  @override
  List<Object> get props => [title, description, createdById, projectId ?? -1];
}

final class ResetCreateForm extends CreateTicketEvent {
  const ResetCreateForm();
  @override
  List<Object> get props => [];
}
