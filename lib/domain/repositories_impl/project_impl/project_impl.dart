import 'package:injectable/injectable.dart';
import 'package:tasknest/data/datasource/project/project_remote_data_source.dart';
import 'package:tasknest/data/repositories/project/project_repository.dart';
import 'package:tasknest/presentation/projects/model/project_models.dart';

@lazySingleton
class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectRemoteDataSource _projectDs;

  ProjectRepositoryImpl(this._projectDs);

  @override
  Future<List<ProjectModel>> getProjects({String? scope, String? status}) =>
      _projectDs.getProjects(scope: scope, status: status);

  @override
  Future<ProjectModel> getProject(int id) => _projectDs.getProject(id);

  @override
  Future<ProjectModel> createProject({
    required String name,
    required String description,
    String priority = 'medium',
    List<int>? departmentIds,
    List<int>? memberIds,
    List<int>? observerIds,
    DateTime? startDate,
    DateTime? endDate,
  }) =>
      _projectDs.createProject(
        name: name,
        description: description,
        priority: priority,
        departmentIds: departmentIds,
        memberIds: memberIds,
        observerIds: observerIds,
        startDate: startDate,
        endDate: endDate,
      );

  @override
  Future<ProjectModel> updateProject(
    int id, {
    String? name,
    String? description,
    String? priority,
    DateTime? startDate,
    DateTime? endDate,
  }) =>
      _projectDs.updateProject(
        id,
        name: name,
        description: description,
        priority: priority,
        startDate: startDate,
        endDate: endDate,
      );

  @override
  Future<void> deleteProject(int id) => _projectDs.deleteProject(id);

  @override
  Future<void> addMembers(int id, List<int> userIds) =>
      _projectDs.addMembers(id, userIds);

  @override
  Future<void> removeMember(int id, int userId) =>
      _projectDs.removeMember(id, userId);

  @override
  Future<void> addObservers(int id, List<int> userIds) =>
      _projectDs.addObservers(id, userIds);

  @override
  Future<void> removeObserver(int id, int userId) =>
      _projectDs.removeObserver(id, userId);

  @override
  Future<void> addDepartments(int id, List<int> departmentIds) =>
      _projectDs.addDepartments(id, departmentIds);

  @override
  Future<void> removeDepartment(int id, int deptId) =>
      _projectDs.removeDepartment(id, deptId);

  @override
  Future<ProjectTaskModel> addTask(
    int projectId, {
    required String title,
    String description = '',
    String priority = 'medium',
    int? assignedToId,
    DateTime? dueDate,
  }) =>
      _projectDs.addTask(
        projectId,
        title: title,
        description: description,
        priority: priority,
        assignedToId: assignedToId,
        dueDate: dueDate,
      );

  @override
  Future<ProjectTaskModel> updateTask(
    int projectId,
    int taskId, {
    String? status,
    int? progress,
    String? title,
    String? description,
    String? priority,
    int? assignedToId,
  }) =>
      _projectDs.updateTask(
        projectId,
        taskId,
        status: status,
        progress: progress,
        title: title,
        description: description,
        priority: priority,
        assignedToId: assignedToId,
      );

  @override
  Future<void> deleteTask(int projectId, int taskId) =>
      _projectDs.deleteTask(projectId, taskId);

  @override
  Future<List<ProjectCommentModel>> getComments(int projectId, int taskId) =>
      _projectDs.getComments(projectId, taskId);

  @override
  Future<ProjectCommentModel> addComment(
    int projectId,
    int taskId,
    String message,
  ) =>
      _projectDs.addComment(projectId, taskId, message);
}
