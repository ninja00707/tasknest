import 'package:equatable/equatable.dart';
import 'package:tasknest/presentation/projects/model/project_models.dart';

abstract class ProjectState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProjectInitial extends ProjectState {}

class ProjectLoading extends ProjectState {}

class ProjectListLoaded extends ProjectState {
  final List<ProjectModel> projects;
  ProjectListLoaded(this.projects);
  @override
  List<Object?> get props => [projects];
}

class ProjectDetailLoaded extends ProjectState {
  final ProjectModel project;
  ProjectDetailLoaded(this.project);
  @override
  List<Object?> get props => [project];
}

class ProjectCommentsLoaded extends ProjectState {
  final int taskId;
  final List<ProjectCommentModel> comments;
  ProjectCommentsLoaded(this.taskId, this.comments);
  @override
  List<Object?> get props => [taskId, comments];
}

class ProjectActionInProgress extends ProjectState {}

class ProjectActionSuccess extends ProjectState {
  final String message;
  ProjectActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class ProjectActionError extends ProjectState {
  final String message;
  ProjectActionError(this.message);
  @override
  List<Object?> get props => [message];
}
