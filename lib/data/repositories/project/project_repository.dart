import 'package:tasknest/presentation/projects/model/project_models.dart';

abstract class ProjectRepository {
  Future<List<ProjectModel>> getProjects({String? scope, String? status});

  Future<ProjectModel> getProject(int id);

  Future<ProjectModel> createProject({
    required String name,
    required String description,
    String priority = 'medium',
    List<int>? departmentIds,
    List<int>? memberIds,
    List<int>? observerIds,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<ProjectModel> updateProject(
    int id, {
    String? name,
    String? description,
    String? priority,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<void> deleteProject(int id);

  Future<void> addMembers(int id, List<int> userIds);

  Future<void> removeMember(int id, int userId);

  Future<void> addObservers(int id, List<int> userIds);

  Future<void> removeObserver(int id, int userId);

  Future<void> addDepartments(int id, List<int> departmentIds);

  Future<void> removeDepartment(int id, int deptId);

  Future<ProjectTaskModel> addTask(
    int projectId, {
    required String title,
    String description = '',
    String priority = 'medium',
    int? assignedToId,
    DateTime? dueDate,
  });

  Future<ProjectTaskModel> updateTask(
    int projectId,
    int taskId, {
    String? status,
    int? progress,
    String? title,
    String? description,
    String? priority,
    int? assignedToId,
  });

  Future<void> deleteTask(int projectId, int taskId);

  Future<List<ProjectCommentModel>> getComments(int projectId, int taskId);

  Future<ProjectCommentModel> addComment(
    int projectId,
    int taskId,
    String message,
  );
}
