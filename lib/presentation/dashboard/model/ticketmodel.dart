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
  final int createdByDeptId;
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

  final bool isSubTicket;
  final int overallProgress;
  final int departmentCount;
  final int completedDepartmentCount;
  final List<SubTicketDepartmentModel> subDepartments;

  final int? parentTicketId;
  final String? ticketType;
  final String? parentTicketTitle;
  final List<Map<String, dynamic>> deptJourney;
  final List<ChildTicketModel> children;
  final int immediateChildCount;
  final bool hasActiveChildren;

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
    required this.createdByDeptId,
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
    this.isSubTicket = false,
    this.overallProgress = 0,
    this.departmentCount = 0,
    this.completedDepartmentCount = 0,
    this.subDepartments = const [],
    this.parentTicketId,
    this.ticketType,
    this.parentTicketTitle,
    this.deptJourney = const [],
    this.children = const [],
    this.immediateChildCount = 0,
    this.hasActiveChildren = false,
  });

  factory TicketModel.fromJson(Map<String, dynamic> j) => TicketModel(
    id: j['id'],
    title: j['title'] ?? '',
    description: j['description'] ?? '',
    status: j['status'] ?? 'open',
    priority: j['priority'] ?? 'low',
    assignedDeptId: j['assigned_dept_id'],
    assignedDeptCode: j['assigned_dept_code'] ?? '',
    assignedDeptName: j['assigned_dept_name'] ?? '',
    createdByName: j['created_by_name'] ?? '',
    createdById: int.tryParse(j['created_by_id']?.toString() ?? '0') ?? 0,
    createdByDeptId: int.tryParse(j['created_by_dept']?.toString() ?? '0') ?? 0,
    createdByDeptCode: j['created_by_dept_code'] ?? '',
    assignedToId: j['assigned_to_id'],
    assignedToName: j['assigned_to_name'] ?? 'Unassigned',
    transferredFromCode: j['transferred_from_code'] ?? 'None',
    createdAt: DateTime.parse(
      j['created_at'] ?? DateTime.now().toIso8601String(),
    ),
    dueDate: j['due_date'] != null ? DateTime.parse(j['due_date']) : null,
    closedAt: j['closed_at'] != null ? DateTime.parse(j['closed_at']) : null,
    reopenCount: j['reopen_count'] ?? 0,
    lastAction: j['last_action'] ?? 'Created',
    lastUpdatedAt: j['last_updated_at'] != null
        ? DateTime.parse(j['last_updated_at'])
        : null,
    lastActedByName: j['last_acted_by_name'] ?? 'System',
    history: j['history'],
    isSubTicket: j['is_sub_ticket'] == true,
    overallProgress: j['overall_progress'] ?? 0,
    departmentCount: j['department_count'] ?? 0,
    completedDepartmentCount: j['completed_department_count'] ?? 0,
    subDepartments:
        (j['sub_departments'] as List<dynamic>?)
            ?.map((e) => SubTicketDepartmentModel.fromJson(e))
            .toList() ??
        const [],
    parentTicketId: j['parent_ticket_id'],
    ticketType: j['ticket_type'],
    parentTicketTitle: j['parent_ticket_title'],
    deptJourney:
        (j['dept_journey'] as List<dynamic>?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList() ??
        const [],
    children:
        (j['children'] as List<dynamic>?)
            ?.map((e) => ChildTicketModel.fromJson(e))
            .toList() ??
        const [],
    immediateChildCount:
        int.tryParse(j['immediate_child_count']?.toString() ?? '0') ?? 0,
    hasActiveChildren: j['has_active_children'] == true,
  );

  bool get isStandardTicket => ticketType == 'standard';
  bool get isMultiTaskTicket => ticketType == 'multi_task';
  bool get hasParent => parentTicketId != null;

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

  SubTicketDepartmentModel? subDeptFor(int departmentId) {
    for (final d in subDepartments) {
      if (d.departmentId == departmentId) return d;
    }
    return null;
  }
}

class ChildTicketModel {
  final int id;
  final String title;
  final String status;
  final int? assignedDeptId;
  final String deptCode;
  final int? assignedToId;
  final String? assigneeName;
  final int createdById;
  final int immediateChildCount;
  final bool hasActiveChildren;

  ChildTicketModel({
    required this.id,
    required this.title,
    required this.status,
    this.assignedDeptId,
    required this.deptCode,
    this.assignedToId,
    this.assigneeName,
    required this.createdById,
    this.immediateChildCount = 0,
    this.hasActiveChildren = false,
  });

  factory ChildTicketModel.fromJson(Map<String, dynamic> j) => ChildTicketModel(
    id: j['id'],
    title: j['title'] ?? '',
    status: j['status'] ?? 'open',
    assignedDeptId: int.tryParse(j['assigned_dept_id']?.toString() ?? ''),
    deptCode: j['dept_code'] ?? '',
    assignedToId: int.tryParse(j['assigned_to_id']?.toString() ?? ''),
    assigneeName: j['assignee_name'],
    createdById: int.tryParse(j['created_by_id']?.toString() ?? '0') ?? 0,
    immediateChildCount:
        int.tryParse(j['immediate_child_count']?.toString() ?? '0') ?? 0,
    hasActiveChildren: j['has_active_children'] == true,
  );

  // Helper getters to match TicketModel interface for TicketActions
  bool get isOpen => status == 'open';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isClosed => status == 'closed';
  bool get isManagementDisabled => isCompleted || isClosed;

  // Mock canReopenBy for now or implement if needed
  bool canReopenBy(int userId) => false;
}

class SubTicketDepartmentModel {
  final int id;
  final int ticketId;
  final int departmentId;
  final String departmentName;
  final String departmentCode;
  final String taskDescription;
  final String status;
  final int progressPercent;
  final int? assignedToId;
  final String? assignedToName;
  final DateTime? completedAt;

  const SubTicketDepartmentModel({
    required this.id,
    required this.ticketId,
    required this.departmentId,
    required this.departmentName,
    required this.departmentCode,
    required this.taskDescription,
    required this.status,
    required this.progressPercent,
    this.assignedToId,
    this.assignedToName,
    this.completedAt,
  });

  factory SubTicketDepartmentModel.fromJson(Map<String, dynamic> j) =>
      SubTicketDepartmentModel(
        id: j['id'],
        ticketId: j['ticket_id'],
        departmentId: j['department_id'],
        departmentName: j['department_name'] ?? '',
        departmentCode: j['department_code'] ?? '',
        taskDescription: j['task_description'] ?? '',
        status: j['status'] ?? 'open',
        progressPercent: j['progress_percent'] ?? 0,
        assignedToId: j['assigned_to_id'],
        assignedToName: j['assigned_to_name'],
        completedAt: j['completed_at'] != null
            ? DateTime.parse(j['completed_at'])
            : null,
      );

  Map<String, dynamic> toJson() => {
    'departmentId': departmentId,
    'taskDescription': taskDescription,
  };

  bool get isCompleted => status == 'completed';
  bool get isInProgress => status == 'in_progress';
  bool get isOpen => status == 'open';
  bool get isPendingApproval => status == 'pending_approval';
  bool get isApproved => status == 'approved';

  bool get isAssigned => assignedToId != null;
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
