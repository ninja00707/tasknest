import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/domain/repositories_impl/project_impl/project_impl.dart';
import 'package:tasknest/presentation/projects/bloc/project_event.dart';
import 'package:tasknest/presentation/projects/bloc/project_state.dart';
import 'package:tasknest/presentation/projects/model/project_models.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final ProjectRepositoryImpl _repository;
  ProjectModel? _lastProject;
  Map<int, List<ProjectCommentModel>> _commentsCache = {};

  ProjectBloc(this._repository) : super(ProjectInitial()) {
    on<LoadProjects>(_onLoadList);
    on<LoadProjectDetail>(_onLoadDetail);
    on<CreateProject>(_onCreate);
    on<UpdateProject>(_onUpdate);
    on<AddProjectTask>(_onAddTask);
    on<UpdateProjectTask>(_onUpdateTask);
    on<LoadProjectComments>(_onLoadComments);
    on<AddProjectComment>(_onAddComment);
    on<DeleteProjectEvent>(_onDelete);
    on<AddProjectMembers>(_onAddMembers);
    on<RemoveProjectMember>(_onRemoveMember);
    on<AddProjectObservers>(_onAddObservers);
    on<RemoveProjectObserver>(_onRemoveObserver);
    on<AddProjectDepartments>(_onAddDepartments);
    on<RemoveProjectDepartment>(_onRemoveDepartment);
    on<ClearProjectState>(_onClear);
  }

  String _friendly(dynamic error) {
    if (error is String) return error;
    if (error is Exception) return error.toString();
    return 'An unexpected error occurred.';
  }

  Future<void> _onLoadList(
    LoadProjects event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());
    try {
      final projects = await _repository.getProjects(
        scope: event.scope,
        status: event.status,
      );
      emit(ProjectListLoaded(projects));
    } catch (e) {
      emit(ProjectActionError(_friendly(e)));
    }
  }

  Future<void> _onLoadDetail(
    LoadProjectDetail event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());
    try {
      final project = await _repository.getProject(event.projectId);
      _lastProject = project;
      emit(ProjectDetailLoaded(project));
    } catch (e) {
      emit(ProjectActionError(_friendly(e)));
    }
  }

  Future<void> _onCreate(
    CreateProject event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectActionInProgress());
    try {
      final project = await _repository.createProject(
        name: event.name,
        description: event.description,
        priority: event.priority,
        departmentIds: event.departmentIds,
        memberIds: event.memberIds,
        observerIds: event.observerIds,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      _lastProject = project;
      emit(ProjectActionSuccess('Project created'));
      emit(ProjectDetailLoaded(project));
    } catch (e) {
      emit(ProjectActionError(_friendly(e)));
    }
  }

  Future<void> _onUpdate(
    UpdateProject event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectActionInProgress());
    try {
      final project = await _repository.updateProject(
        event.id,
        name: event.name,
        description: event.description,
        priority: event.priority,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      _lastProject = project;
      emit(ProjectActionSuccess('Project updated'));
      emit(ProjectDetailLoaded(project));
    } catch (e) {
      emit(ProjectActionError(_friendly(e)));
    }
  }

  Future<void> _onAddTask(
    AddProjectTask event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectActionInProgress());
    try {
      final task = await _repository.addTask(
        event.projectId,
        title: event.title,
        description: event.description,
        priority: event.priority,
        assignedToId: event.assignedToId,
        dueDate: event.dueDate,
      );
      _patchProject((p) {
        return _copyProject(
          p,
          tasks: [...p.tasks, task],
          taskCount: p.taskCount + 1,
        );
      });
      emit(ProjectActionSuccess('Task added'));
      final current = _lastProject;
      if (current != null) emit(ProjectDetailLoaded(current));
    } catch (e) {
      emit(ProjectActionError(_friendly(e)));
      final current = _lastProject;
      if (current != null) emit(ProjectDetailLoaded(current));
    }
  }

  Future<void> _onUpdateTask(
    UpdateProjectTask event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectActionInProgress());
    try {
      final task = await _repository.updateTask(
        event.projectId,
        event.taskId,
        status: event.status,
        progress: event.progress,
        title: event.title,
        description: event.description,
        priority: event.priority,
        assignedToId: event.assignedToId,
      );
      _patchProject((p) {
        return _copyProject(
          p,
          tasks: [
            for (final t in p.tasks)
              if (t.id == task.id) task else t,
          ],
        );
      });
      emit(ProjectActionSuccess('Task updated'));
      final current = _lastProject;
      if (current != null) {
        final refreshed = await _repository.getProject(current.id);
        _lastProject = refreshed;
        emit(ProjectDetailLoaded(refreshed));
      }
    } catch (e) {
      emit(ProjectActionError(_friendly(e)));
      final current = _lastProject;
      if (current != null) emit(ProjectDetailLoaded(current));
    }
  }

  Future<void> _onLoadComments(
    LoadProjectComments event,
    Emitter<ProjectState> emit,
  ) async {
    try {
      final comments = await _repository.getComments(
        event.projectId,
        event.taskId,
      );
      _commentsCache[event.taskId] = comments;
      emit(ProjectCommentsLoaded(event.taskId, comments));
    } catch (e) {
      emit(ProjectActionError(_friendly(e)));
    }
  }

  Future<void> _onAddComment(
    AddProjectComment event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectActionInProgress());
    try {
      final comment = await _repository.addComment(
        event.projectId,
        event.taskId,
        event.message,
      );
      final existing = _commentsCache[event.taskId] ?? [];
      _commentsCache[event.taskId] = [...existing, comment];
      emit(ProjectCommentsLoaded(event.taskId, _commentsCache[event.taskId]!));
      emit(ProjectActionSuccess('Comment added'));
    } catch (e) {
      emit(ProjectActionError(_friendly(e)));
    }
  }

  Future<void> _onDelete(
    DeleteProjectEvent event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectActionInProgress());
    try {
      await _repository.deleteProject(event.projectId);
      emit(ProjectActionSuccess('Project deleted'));
    } catch (e) {
      emit(ProjectActionError(_friendly(e)));
    }
  }

  Future<void> _onAddMembers(
    AddProjectMembers event,
    Emitter<ProjectState> emit,
  ) async {
    await _manageTeam(
      emit,
      event.projectId,
      () => _repository.addMembers(event.projectId, event.userIds),
      'Members added',
    );
  }

  Future<void> _onRemoveMember(
    RemoveProjectMember event,
    Emitter<ProjectState> emit,
  ) async {
    await _manageTeam(
      emit,
      event.projectId,
      () => _repository.removeMember(event.projectId, event.userId),
      'Member removed',
    );
  }

  Future<void> _onAddObservers(
    AddProjectObservers event,
    Emitter<ProjectState> emit,
  ) async {
    await _manageTeam(
      emit,
      event.projectId,
      () => _repository.addObservers(event.projectId, event.userIds),
      'Observers added',
    );
  }

  Future<void> _onRemoveObserver(
    RemoveProjectObserver event,
    Emitter<ProjectState> emit,
  ) async {
    await _manageTeam(
      emit,
      event.projectId,
      () => _repository.removeObserver(event.projectId, event.userId),
      'Observer removed',
    );
  }

  Future<void> _onAddDepartments(
    AddProjectDepartments event,
    Emitter<ProjectState> emit,
  ) async {
    await _manageTeam(
      emit,
      event.projectId,
      () => _repository.addDepartments(event.projectId, event.departmentIds),
      'Departments added',
    );
  }

  Future<void> _onRemoveDepartment(
    RemoveProjectDepartment event,
    Emitter<ProjectState> emit,
  ) async {
    await _manageTeam(
      emit,
      event.projectId,
      () => _repository.removeDepartment(event.projectId, event.departmentId),
      'Department removed',
    );
  }

  Future<void> _manageTeam(
    Emitter<ProjectState> emit,
    int projectId,
    Future<void> Function() action,
    String successMessage,
  ) async {
    try {
      await action();
      final refreshed = await _repository.getProject(projectId);
      _lastProject = refreshed;
      emit(ProjectDetailLoaded(refreshed));
      emit(ProjectActionSuccess(successMessage));
    } catch (e) {
      emit(ProjectActionError(_friendly(e)));
      final current = _lastProject;
      if (current != null) emit(ProjectDetailLoaded(current));
    }
  }

  void _patchProject(ProjectModel Function(ProjectModel) transform) {
    final current = _lastProject;
    if (current != null) _lastProject = transform(current);
  }

  ProjectModel _copyProject(
    ProjectModel p, {
    List<ProjectTaskModel>? tasks,
    int? taskCount,
  }) {
    return ProjectModel(
      id: p.id,
      name: p.name,
      description: p.description,
      status: p.status,
      priority: p.priority,
      projectCode: p.projectCode,
      createdById: p.createdById,
      createdByName: p.createdByName,
      createdByDeptName: p.createdByDeptName,
      createdByDeptCode: p.createdByDeptCode,
      companyId: p.companyId,
      startDate: p.startDate,
      endDate: p.endDate,
      progress: p.progress,
      createdAt: p.createdAt,
      memberCount: p.memberCount,
      observerCount: p.observerCount,
      taskCount: taskCount ?? p.taskCount,
      doneCount: p.doneCount,
      deptCount: p.deptCount,
      isObserver: p.isObserver,
      viewerRole: p.viewerRole,
      canManage: p.canManage,
      departments: p.departments,
      members: p.members,
      observers: p.observers,
      tasks: tasks ?? p.tasks,
    );
  }

  Future<void> _onClear(
    ClearProjectState event,
    Emitter<ProjectState> emit,
  ) async {
    _lastProject = null;
    _commentsCache = {};
    emit(ProjectInitial());
  }
}
