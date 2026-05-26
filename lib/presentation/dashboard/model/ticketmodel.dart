class TicketModel {
  final int id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final int? assignedDeptId;
  final String assignedDeptCode;
  final String assignedDeptName;
  final String createdByName;
  final String createdByDeptCode;
  final int createdById;
  final int? assignedToId;
  final String? assignedToName;
  final String? transferredFromCode;
  final DateTime createdAt;
  final DateTime? dueDate;
  final DateTime? closedAt;
  final int reopenCount;

  final String? lastAction;
  final DateTime? lastUpdatedAt;
  final String? lastActedByName;
  final List<dynamic>? history;

  const TicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.assignedDeptId,
    required this.assignedDeptCode,
    required this.assignedDeptName,
    required this.createdByName,
    required this.createdByDeptCode,
    required this.createdById,
    this.assignedToId,
    this.assignedToName,
    this.transferredFromCode,
    required this.createdAt,
    this.dueDate,
    this.closedAt,
    required this.reopenCount,
    this.lastAction,
    this.lastUpdatedAt,
    this.lastActedByName,
    this.history,
  });

  factory TicketModel.fromJson(Map<String, dynamic> j) => TicketModel(
    id: j['id'],
    title: j['title'],
    description: j['description'],
    status: j['status'],
    priority: j['priority'],
    assignedDeptId: j['assigned_dept_id'],
    assignedDeptCode: j['assigned_dept_code'] ?? '',
    assignedDeptName: j['assigned_dept_name'] ?? '',
    createdByName: j['created_by_name'] ?? '',
    createdById: j['created_by_id'],
    createdByDeptCode: j['created_by_dept_code'] ?? '',
    assignedToId: j['assigned_to_id'],
    assignedToName: j['assigned_to_name'] ?? 'Unassigned',
    transferredFromCode: j['transferred_from_code'] ?? 'None',
    createdAt: DateTime.parse(j['created_at']),
    dueDate: j['due_date'] != null ? DateTime.parse(j['due_date']) : null,
    closedAt: j['closed_at'] != null ? DateTime.parse(j['closed_at']) : null,
    reopenCount: j['reopen_count'] ?? 0,
    lastAction: j['last_action'] ?? 'Created',
    lastUpdatedAt: j['last_updated_at'] != null
        ? DateTime.parse(j['last_updated_at'])
        : null,
    lastActedByName: j['last_acted_by_name'] ?? 'System',
    history: j['history'],
  );

  bool get isOpen => status == 'open';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isClosed => status == 'closed';

  /// Logic to disable management actions (Transfer/Assign)
  bool get isManagementDisabled => isCompleted || isClosed;

  bool get isUrgent => priority == 'urgent';
  bool get isOverdue =>
      dueDate != null &&
      dueDate!.isBefore(DateTime.now()) &&
      !isClosed &&
      !isCompleted;

  bool canReopenBy(int userId) {
    if (createdById != userId) return false;
    if (reopenCount >= 1) return false;
    if (!isClosed && !isCompleted) return false;
    if (closedAt == null) return false;
    return DateTime.now().difference(closedAt!).inHours <= 48;
  }
}

class DashboardStats {
  final int total;
  final int open;
  final int inProgress;
  final int completed;
  final int closed;
  final int urgent;
  final int highPriority;
  final int overdue;

  const DashboardStats({
    required this.total,
    required this.open,
    required this.inProgress,
    required this.completed,
    required this.closed,
    required this.urgent,
    required this.highPriority,
    required this.overdue,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> j) => DashboardStats(
    total: int.parse(j['total'].toString()),
    open: int.parse(j['open'].toString()),
    inProgress: int.parse(j['in_progress'].toString()),
    completed: int.parse(j['completed'].toString()),
    closed: int.parse(j['closed'].toString()),
    urgent: int.parse(j['urgent'].toString()),
    highPriority: int.parse(j['high_priority'].toString()),
    overdue: int.parse(j['overdue'].toString()),
  );

  factory DashboardStats.empty() => const DashboardStats(
    total: 0,
    open: 0,
    inProgress: 0,
    completed: 0,
    closed: 0,
    urgent: 0,
    highPriority: 0,
    overdue: 0,
  );
}

class DepartmentModel {
  final int id;
  final String name;
  final String code;
  final String tier;
  final int? parentId;

  const DepartmentModel({
    required this.id,
    required this.name,
    required this.code,
    required this.tier,
    this.parentId,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> j) => DepartmentModel(
    id: j['id'],
    name: j['name'],
    code: j['code'],
    tier: j['tier'],
    parentId: j['parent_id'],
  );
}

class EmployeeModel {
  final int id;
  final String name;
  final String email;
  final int departmentId;
  final int companyId;
  final bool isActive;
  final String role;
  final String deptCode;
  final String deptName;

  const EmployeeModel({
    required this.id,
    required this.name,
    required this.email,
    required this.departmentId,
    required this.companyId,
    required this.isActive,
    required this.role,
    required this.deptCode,
    required this.deptName,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> j) => EmployeeModel(
    id: j['id'],
    name: j['name'],
    email: j['email'],
    departmentId: j['department_id'],
    companyId: j['company_id'],
    isActive: j['is_active'] ?? true,
    role: j['role'] ?? '',
    deptCode: j['dept_code'] ?? '',
    deptName: j['dept_name'] ?? '',
  );
}

class NotificationModel {
  final int id;
  final int? ticketId;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    this.ticketId,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> j) =>
      NotificationModel(
        id: j['id'],
        ticketId: j['ticket_id'],
        message: j['message'] ?? '',
        isRead: j['is_read'] ?? false,
        createdAt: DateTime.parse(j['created_at']),
      );
}
