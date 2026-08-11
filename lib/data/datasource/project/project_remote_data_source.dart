import 'package:injectable/injectable.dart';
import 'package:tasknest/core/constant/api_client.dart';
import 'package:tasknest/presentation/projects/model/project_models.dart';

@lazySingleton
class ProjectRemoteDataSource {
  final ApiClient _api;
  ProjectRemoteDataSource(this._api);

  Future<List<ProjectModel>> getProjects({
    String? scope,
    String? status,
  }) async {
    final query = <String, dynamic>{
      'scope': ?scope,
      'status': ?status,
    };
    final res = await _api.get('projects', queryParams: query);
    final data = res['data'] ?? [];
    return (data as List)
        .map((e) => ProjectModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ProjectModel> getProject(int id) async {
    final res = await _api.get('projects/$id');
    return ProjectModel.fromJson(res['data']);
  }

  Future<ProjectModel> createProject({
    required String name,
    required String description,
    String priority = 'medium',
    List<int>? departmentIds,
    List<int>? memberIds,
    List<int>? observerIds,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'description': description,
      'priority': priority,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'departmentIds': departmentIds,
      'memberIds': memberIds,
      'observerIds': observerIds,
    };
    final res = await _api.post('projects', body: body);
    return ProjectModel.fromJson(res['data']);
  }

  Future<ProjectModel> updateProject(
    int id, {
    String? name,
    String? description,
    String? priority,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'description': description,
      'priority': priority,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
    final res = await _api.patch('projects/$id', body: body);
    return ProjectModel.fromJson(res['data']);
  }

  Future<void> deleteProject(int id) async {
    await _api.delete('projects/$id');
  }

  Future<void> addMembers(int id, List<int> userIds) async {
    await _api.post('projects/$id/members', body: {'userIds': userIds});
  }

  Future<void> removeMember(int id, int userId) async {
    await _api.delete('projects/$id/members/$userId');
  }

  Future<void> addObservers(int id, List<int> userIds) async {
    await _api.post('projects/$id/observers', body: {'userIds': userIds});
  }

  Future<void> removeObserver(int id, int userId) async {
    await _api.delete('projects/$id/observers/$userId');
  }

  Future<void> addDepartments(int id, List<int> departmentIds) async {
    await _api.post('projects/$id/departments', body: {
      'departmentIds': departmentIds,
    });
  }

  Future<void> removeDepartment(int id, int deptId) async {
    await _api.delete('projects/$id/departments/$deptId');
  }

  Future<ProjectTaskModel> addTask(
    int projectId, {
    required String title,
    String description = '',
    String priority = 'medium',
    int? assignedToId,
    DateTime? dueDate,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'description': description,
      'priority': priority,
      'assignedToId': assignedToId,
      'dueDate': dueDate?.toIso8601String(),
    };
    final res = await _api.post('projects/$projectId/tasks', body: body);
    return ProjectTaskModel.fromJson(res['data']);
  }

  Future<ProjectTaskModel> updateTask(
    int projectId,
    int taskId, {
    String? status,
    int? progress,
    String? title,
    String? description,
    String? priority,
    int? assignedToId,
  }) async {
    final body = <String, dynamic>{};
    if (status != null) body['status'] = status;
    if (progress != null) body['progress'] = progress;
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (priority != null) body['priority'] = priority;
    if (assignedToId != null) body['assignedToId'] = assignedToId;
    final res = await _api.patch(
      'projects/$projectId/tasks/$taskId',
      body: body,
    );
    return ProjectTaskModel.fromJson(res['data']);
  }

  Future<void> deleteTask(int projectId, int taskId) async {
    await _api.delete('projects/$projectId/tasks/$taskId');
  }

  Future<List<ProjectCommentModel>> getComments(
    int projectId,
    int taskId,
  ) async {
    final res = await _api.get('projects/$projectId/tasks/$taskId/comments');
    final data = res['data'] ?? [];
    return (data as List)
        .map((e) => ProjectCommentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ProjectCommentModel> addComment(
    int projectId,
    int taskId,
    String message,
  ) async {
    final res = await _api.post(
      'projects/$projectId/tasks/$taskId/comments',
      body: {'message': message},
    );
    return ProjectCommentModel.fromJson(res['data']);
  }
}
