import 'package:equatable/equatable.dart';

abstract class ProjectEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProjects extends ProjectEvent {
  final String? scope;
  final String? status;
  LoadProjects({this.scope, this.status});
  @override
  List<Object?> get props => [scope, status];
}

class LoadProjectDetail extends ProjectEvent {
  final int projectId;
  LoadProjectDetail(this.projectId);
  @override
  List<Object?> get props => [projectId];
}

class CreateProject extends ProjectEvent {
  final String name;
  final String description;
  final String priority;
  final List<int>? departmentIds;
  final List<int>? memberIds;
  final List<int>? observerIds;
  final DateTime? startDate;
  final DateTime? endDate;
  CreateProject({
    required this.name,
    required this.description,
    this.priority = 'medium',
    this.departmentIds,
    this.memberIds,
    this.observerIds,
    this.startDate,
    this.endDate,
  });
  @override
  List<Object?> get props => [
    name,
    description,
    priority,
    departmentIds,
    memberIds,
    observerIds,
    startDate,
    endDate,
  ];
}

class UpdateProject extends ProjectEvent {
  final int id;
  final String? name;
  final String? description;
  final String? priority;
  final DateTime? startDate;
  final DateTime? endDate;
  UpdateProject({
    required this.id,
    this.name,
    this.description,
    this.priority,
    this.startDate,
    this.endDate,
  });
  @override
  List<Object?> get props => [
    id,
    name,
    description,
    priority,
    startDate,
    endDate,
  ];
}

class AddProjectTask extends ProjectEvent {
  final int projectId;
  final String title;
  final String description;
  final String priority;
  final int? assignedToId;
  final DateTime? dueDate;
  AddProjectTask({
    required this.projectId,
    required this.title,
    this.description = '',
    this.priority = 'medium',
    this.assignedToId,
    this.dueDate,
  });
  @override
  List<Object?> get props => [
    projectId,
    title,
    description,
    priority,
    assignedToId,
    dueDate,
  ];
}

class UpdateProjectTask extends ProjectEvent {
  final int projectId;
  final int taskId;
  final String? status;
  final int? progress;
  final String? title;
  final String? description;
  final String? priority;
  final int? assignedToId;
  UpdateProjectTask({
    required this.projectId,
    required this.taskId,
    this.status,
    this.progress,
    this.title,
    this.description,
    this.priority,
    this.assignedToId,
  });
  @override
  List<Object?> get props => [
    projectId,
    taskId,
    status,
    progress,
    title,
    description,
    priority,
    assignedToId,
  ];
}

class LoadProjectComments extends ProjectEvent {
  final int projectId;
  final int taskId;
  LoadProjectComments(this.projectId, this.taskId);
  @override
  List<Object?> get props => [projectId, taskId];
}

class AddProjectComment extends ProjectEvent {
  final int projectId;
  final int taskId;
  final String message;
  AddProjectComment({
    required this.projectId,
    required this.taskId,
    required this.message,
  });
  @override
  List<Object?> get props => [projectId, taskId, message];
}

class DeleteProjectEvent extends ProjectEvent {
  final int projectId;
  DeleteProjectEvent(this.projectId);
  @override
  List<Object?> get props => [projectId];
}

class AddProjectMembers extends ProjectEvent {
  final int projectId;
  final List<int> userIds;
  AddProjectMembers({required this.projectId, required this.userIds});
  @override
  List<Object?> get props => [projectId, userIds];
}

class RemoveProjectMember extends ProjectEvent {
  final int projectId;
  final int userId;
  RemoveProjectMember({required this.projectId, required this.userId});
  @override
  List<Object?> get props => [projectId, userId];
}

class AddProjectObservers extends ProjectEvent {
  final int projectId;
  final List<int> userIds;
  AddProjectObservers({required this.projectId, required this.userIds});
  @override
  List<Object?> get props => [projectId, userIds];
}

class RemoveProjectObserver extends ProjectEvent {
  final int projectId;
  final int userId;
  RemoveProjectObserver({required this.projectId, required this.userId});
  @override
  List<Object?> get props => [projectId, userId];
}

class AddProjectDepartments extends ProjectEvent {
  final int projectId;
  final List<int> departmentIds;
  AddProjectDepartments({required this.projectId, required this.departmentIds});
  @override
  List<Object?> get props => [projectId, departmentIds];
}

class RemoveProjectDepartment extends ProjectEvent {
  final int projectId;
  final int departmentId;
  RemoveProjectDepartment({
    required this.projectId,
    required this.departmentId,
  });
  @override
  List<Object?> get props => [projectId, departmentId];
}

class ClearProjectState extends ProjectEvent {}
