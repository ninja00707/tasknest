import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

int _parseInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

class ProjectModel {
  final int id;
  final String name;
  final String description;
  final String status;
  final String priority;
  final String projectCode;
  final int createdById;
  final String createdByName;
  final String createdByDeptName;
  final String createdByDeptCode;
  final int companyId;
  final DateTime? startDate;
  final DateTime? endDate;
  final int progress;
  final DateTime createdAt;
  final int memberCount;
  final int observerCount;
  final int taskCount;
  final int doneCount;
  final int deptCount;
  final bool isObserver;
  final String viewerRole;
  final bool canManage;
  final bool canEdit;
  final bool canManageObservers;
  final List<ProjectDepartmentModel> departments;
  final List<ProjectMemberModel> members;
  final List<ProjectMemberModel> observers;
  final List<ProjectTaskModel> tasks;
  final List<TicketModel> tickets;

  const ProjectModel({
    required this.id,
    this.name = '',
    this.description = '',
    this.status = 'planned',
    this.priority = 'medium',
    this.projectCode = '',
    this.createdById = 0,
    this.createdByName = '',
    this.createdByDeptName = '',
    this.createdByDeptCode = '',
    this.companyId = 0,
    this.startDate,
    this.endDate,
    this.progress = 0,
    required this.createdAt,
    this.memberCount = 0,
    this.observerCount = 0,
    this.taskCount = 0,
    this.doneCount = 0,
    this.deptCount = 0,
    this.isObserver = false,
    this.viewerRole = 'viewer',
    this.canManage = false,
    this.canEdit = false,
    this.canManageObservers = false,
    this.departments = const [],
    this.members = const [],
    this.observers = const [],
    this.tasks = const [],
    this.tickets = const [],
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    List<ProjectDepartmentModel> depts = const [];
    List<ProjectMemberModel> members = const [];
    List<ProjectMemberModel> observers = const [];
    List<ProjectTaskModel> tasks = const [];
    List<TicketModel> tickets = const [];
    if (json['departments'] is List) {
      depts = (json['departments'] as List)
          .map((e) => ProjectDepartmentModel.fromJson(e))
          .toList();
    }
    if (json['members'] is List) {
      members = (json['members'] as List)
          .map((e) => ProjectMemberModel.fromJson(e))
          .toList();
    }
    if (json['observers'] is List) {
      observers = (json['observers'] as List)
          .map((e) => ProjectMemberModel.fromJson(e))
          .toList();
    }
    if (json['tasks'] is List) {
      tasks = (json['tasks'] as List)
          .map((e) => ProjectTaskModel.fromJson(e))
          .toList();
    }
    if (json['tickets'] is List) {
      tickets = (json['tickets'] as List)
          .map((e) => TicketModel.fromJson(e))
          .toList();
    }
    return ProjectModel(
      id: _parseInt(json['id']),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'planned',
      priority: json['priority'] ?? 'medium',
      projectCode: json['project_code'] ?? '',
      createdById: _parseInt(json['created_by_id']),
      createdByName: json['created_by_name'] ?? '',
      createdByDeptName: json['created_by_dept_name'] ?? '',
      createdByDeptCode: json['created_by_dept_code'] ?? '',
      companyId: _parseInt(json['company_id']),
      startDate: _parseDate(json['start_date']),
      endDate: _parseDate(json['end_date']),
      progress: _parseInt(json['progress']),
      createdAt: _parseDate(json['created_at']) ?? DateTime.now(),
      memberCount: _parseInt(json['member_count']),
      observerCount: _parseInt(json['observer_count']),
      taskCount: _parseInt(json['task_count']),
      doneCount: _parseInt(json['done_count']),
      deptCount: _parseInt(json['dept_count']),
      isObserver: json['is_observer'] ?? json['isObserver'] ?? false,
      viewerRole: json['viewer_role'] ?? json['viewerRole'] ?? 'viewer',
      canManage: json['can_manage'] ?? json['canManage'] ?? false,
      canEdit: json['can_edit'] ?? json['canEdit'] ?? false,
      canManageObservers:
          json['can_manage_observers'] ?? json['canManageObservers'] ?? false,
      departments: depts,
      members: members,
      observers: observers,
      tasks: tasks,
      tickets: tickets,
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }
}

class ProjectDepartmentModel {
  final int id;
  final String name;
  final String code;
  const ProjectDepartmentModel({
    required this.id,
    this.name = '',
    this.code = '',
  });

  factory ProjectDepartmentModel.fromJson(Map<String, dynamic> json) {
    return ProjectDepartmentModel(
      id: _parseInt(json['id']),
      name: json['name'] ?? '',
      code: json['code'] ?? '',
    );
  }
}

class ProjectMemberModel {
  final int id;
  final String name;
  final String code;
  final String departmentName;
  final String role;
  const ProjectMemberModel({
    required this.id,
    this.name = '',
    this.code = '',
    this.departmentName = '',
    this.role = 'member',
  });

  factory ProjectMemberModel.fromJson(Map<String, dynamic> json) {
    return ProjectMemberModel(
      id: _parseInt(json['id']),
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      departmentName: json['department_name'] ?? '',
      role: json['role'] ?? 'member',
    );
  }
}

class ProjectTaskModel {
  final int id;
  final int projectId;
  final String title;
  final String description;
  final String status;
  final String priority;
  final int? assignedToId;
  final String? assignedToName;
  final int? assignedDeptId;
  final String? assignedDeptName;
  final String? assignedDeptCode;
  final int progress;
  final DateTime? dueDate;
  final int createdById;
  final String createdByName;
  final int commentCount;
  final DateTime createdAt;

  const ProjectTaskModel({
    required this.id,
    required this.projectId,
    required this.title,
    this.description = '',
    this.status = 'todo',
    this.priority = 'medium',
    this.assignedToId,
    this.assignedToName,
    this.assignedDeptId,
    this.assignedDeptName,
    this.assignedDeptCode,
    this.progress = 0,
    this.dueDate,
    this.createdById = 0,
    this.createdByName = '',
    this.commentCount = 0,
    required this.createdAt,
  });

  factory ProjectTaskModel.fromJson(Map<String, dynamic> json) {
    return ProjectTaskModel(
      id: json['id'] ?? 0,
      projectId: _parseInt(json['project_id']),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'todo',
      priority: json['priority'] ?? 'medium',
      assignedToId: json['assigned_to_id'] != null
          ? _parseInt(json['assigned_to_id'])
          : null,
      assignedToName: json['assigned_to_name'],
      assignedDeptId: json['assigned_dept_id'] != null
          ? _parseInt(json['assigned_dept_id'])
          : null,
      assignedDeptName: json['assigned_dept_name'],
      assignedDeptCode: json['assigned_dept_code'],
      progress: _parseInt(json['progress']),
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'].toString())
          : null,
      createdById: _parseInt(json['created_by_id']),
      createdByName: json['created_by_name'] ?? '',
      commentCount: _parseInt(json['comment_count']),
      createdAt:
          DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
    );
  }
}

class ProjectCommentModel {
  final int id;
  final int taskId;
  final int userId;
  final String userName;
  final String message;
  final DateTime createdAt;
  const ProjectCommentModel({
    required this.id,
    required this.taskId,
    required this.userId,
    this.userName = '',
    this.message = '',
    required this.createdAt,
  });

  factory ProjectCommentModel.fromJson(Map<String, dynamic> json) {
    return ProjectCommentModel(
      id: _parseInt(json['id']),
      taskId: _parseInt(json['task_id']),
      userId: _parseInt(json['user_id']),
      userName: json['user_name'] ?? '',
      message: json['message'] ?? '',
      createdAt:
          DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
    );
  }
}
