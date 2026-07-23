class TicketModel {
  final int id;
  final String ticketNumber;
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
  final int? myAssignedToId;
  final String? myAssignedToName;
  final String? assignedToReportsToName;
  final String? createdByReportsToName;
  final String? transferredFromCode;
  final DateTime createdAt;
  final DateTime? dueDate;
  final DateTime? closedAt;
  final int reopenCount;

  final String? lastAction;
  final DateTime? lastUpdatedAt;
  final String? lastActedByName;
  final String? lastActedByDeptName;
  final List<dynamic>? history;

  final bool isSubTicket;
  final int overallProgress;
  final int departmentCount;
  final int completedDepartmentCount;
  final List<SubTicketDepartmentModel> subDepartments;

  final int? parentTicketId;
  final String? ticketType;
  final String? parentTicketTitle;
  final String? parentTicketNumber;
  final List<Map<String, dynamic>> deptJourney;
  final List<ChildTicketModel> children;
  final int immediateChildCount;
  final bool hasActiveChildren;
  final List<CommentModel> comments;
  final bool canComment;

  const TicketModel({
    required this.id,
    this.ticketNumber = '',
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
    this.myAssignedToId,
    this.myAssignedToName,
    this.assignedToReportsToName,
    this.createdByReportsToName,
    this.transferredFromCode,
    required this.createdAt,
    this.dueDate,
    this.closedAt,
    required this.reopenCount,
    this.lastAction,
    this.lastUpdatedAt,
    this.lastActedByName,
    this.lastActedByDeptName,
    this.history,
    this.isSubTicket = false,
    this.overallProgress = 0,
    this.departmentCount = 0,
    this.completedDepartmentCount = 0,
    this.subDepartments = const [],
    this.parentTicketId,
    this.ticketType,
    this.parentTicketTitle,
    this.parentTicketNumber,
    this.deptJourney = const [],
    this.children = const [],
    this.immediateChildCount = 0,
    this.hasActiveChildren = false,
    this.comments = const [],
    this.canComment = false,
  });

  factory TicketModel.fromJson(Map<String, dynamic> j) => TicketModel(
    id: j['id'],
    ticketNumber: j['ticket_number'] ?? '',
    title: j['title'] ?? '',
    description: j['description'] ?? '',
    status: j['status'] ?? 'open',
    priority: j['priority'] ?? 'low',
    assignedDeptId: (j['assigned_dept_id'] is num)
        ? (j['assigned_dept_id'] as num).toInt()
        : int.tryParse(j['assigned_dept_id']?.toString() ?? ''),
    assignedDeptCode: j['assigned_dept_code'] ?? '',
    assignedDeptName: j['assigned_dept_name'] ?? '',
    createdByName: j['created_by_name'] ?? '',
    createdById: (j['created_by_id'] is num)
        ? (j['created_by_id'] as num).toInt()
        : (int.tryParse(j['created_by_id']?.toString() ?? '0') ?? 0),
    createdByDeptId: (j['created_by_dept'] is num)
        ? (j['created_by_dept'] as num).toInt()
        : (int.tryParse(j['created_by_dept']?.toString() ?? '0') ?? 0),
    createdByDeptCode: j['created_by_dept_code'] ?? '',
    assignedToId: (j['assigned_to_id'] is num)
        ? (j['assigned_to_id'] as num).toInt()
        : int.tryParse(j['assigned_to_id']?.toString() ?? ''),
    assignedToName: j['assigned_to_name'] ?? 'Unassigned',
    myAssignedToId: (j['my_assigned_to_id'] is num)
        ? (j['my_assigned_to_id'] as num).toInt()
        : int.tryParse(j['my_assigned_to_id']?.toString() ?? ''),
    myAssignedToName: j['my_assigned_to_name'],
    assignedToReportsToName: j['assigned_to_reports_to_name'],
    createdByReportsToName: j['created_by_reports_to_name'],
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
    lastActedByDeptName: j['last_acted_by_dept_name'],
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
    parentTicketNumber: j['parent_ticket_number'],
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
    comments:
        (j['comments'] as List<dynamic>?)
            ?.map((e) => CommentModel.fromJson(e))
            .toList() ??
        const [],
    canComment: j['can_comment'] == true,
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
  final String ticketNumber;
  final String title;
  final String description;
  final String status;
  final int? assignedDeptId;
  final String deptCode;
  final String deptName;
  final int? assignedToId;
  final String? assigneeName;
  final int createdById;
  final int createdByDept;
  final String createdByName;
  final String createdByDeptCode;
  final DateTime createdAt;
  final String priority;
  final int immediateChildCount;
  final bool hasActiveChildren;

  ChildTicketModel({
    required this.id,
    this.ticketNumber = '',
    required this.title,
    this.description = '',
    required this.status,
    this.assignedDeptId,
    required this.deptCode,
    this.deptName = '',
    this.assignedToId,
    this.assigneeName,
    required this.createdById,
    this.createdByDept = 0,
    this.createdByName = '',
    this.createdByDeptCode = '',
    required this.createdAt,
    this.priority = 'medium',
    this.immediateChildCount = 0,
    this.hasActiveChildren = false,
    this.closedAt,
    this.reopenCount = 0,
  });

  factory ChildTicketModel.fromJson(Map<String, dynamic> j) => ChildTicketModel(
    id: j['id'],
    ticketNumber: j['ticket_number'] ?? '',
    title: j['title'] ?? '',
    description: j['description'] ?? '',
    status: j['status'] ?? 'open',
    assignedDeptId: (j['assigned_dept_id'] is num)
        ? (j['assigned_dept_id'] as num).toInt()
        : int.tryParse(j['assigned_dept_id']?.toString() ?? ''),
    deptCode: j['dept_code'] ?? '',
    deptName: j['dept_name'] ?? '',
    assignedToId: (j['assigned_to_id'] is num)
        ? (j['assigned_to_id'] as num).toInt()
        : int.tryParse(j['assigned_to_id']?.toString() ?? ''),
    assigneeName: j['assignee_name'],
    createdById: (j['created_by_id'] is num)
        ? (j['created_by_id'] as num).toInt()
        : (int.tryParse(j['created_by_id']?.toString() ?? '0') ?? 0),
    createdByDept: (j['created_by_dept'] is num)
        ? (j['created_by_dept'] as num).toInt()
        : (int.tryParse(j['created_by_dept']?.toString() ?? '0') ?? 0),
    createdByName: j['created_by_name'] ?? '',
    createdByDeptCode: j['created_by_dept_code'] ?? '',
    createdAt: DateTime.parse(
      j['created_at'] ?? DateTime.now().toIso8601String(),
    ),
    priority: j['priority'] ?? 'medium',
    immediateChildCount:
        int.tryParse(j['immediate_child_count']?.toString() ?? '0') ?? 0,
    hasActiveChildren: j['has_active_children'] == true,
    closedAt: j['closed_at'] != null ? DateTime.parse(j['closed_at']) : null,
    reopenCount: j['reopen_count'] ?? 0,
  );

  final List<Map<String, dynamic>> deptJourney = const [];
  final DateTime? closedAt;
  final int reopenCount;

  // Helper getters to match TicketModel interface for TicketActions
  bool get isOpen => status == 'open';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isClosed => status == 'closed';
  bool get isManagementDisabled => isCompleted || isClosed;

  /// Only the creator can reopen. Max 1 reopen. Within 48h of closing.
  bool canReopenBy(int userId) {
    if (createdById != userId) return false;
    if (reopenCount >= 1) return false;
    if (!isClosed && !isCompleted) return false;
    if (closedAt == null) return false;
    return DateTime.now().difference(closedAt!).inHours <= 48;
  }
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
        assignedToId: (j['assigned_to_id'] is num)
            ? (j['assigned_to_id'] as num).toInt()
            : int.tryParse(j['assigned_to_id']?.toString() ?? ''),
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

class CommentModel {
  final int id;
  final int ticketId;
  final int userId;
  final String message;
  final String userName;
  final String deptCode;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.ticketId,
    required this.userId,
    required this.message,
    required this.userName,
    required this.deptCode,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> j) => CommentModel(
    id: j['id'],
    ticketId: j['ticket_id'],
    userId: j['user_id'],
    message: j['message'] ?? '',
    userName: j['user_name'] ?? '',
    deptCode: j['dept_code'] ?? '',
    createdAt: DateTime.parse(
      j['created_at'] ?? DateTime.now().toIso8601String(),
    ),
  );
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
  final int? reportsTo;
  final String? reportsToName;

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
    this.reportsTo,
    this.reportsToName,
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
    reportsTo: j['reports_to'],
    reportsToName: j['reports_to_name'],
  );
}
