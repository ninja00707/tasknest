class AdminStats {
  final int totalUsers;
  final int totalDepartments;
  final int totalTickets;
  final int openTickets;
  final int inProgressTickets;
  final int closedTickets;
  final int totalCompanies;
  final int overdueTickets;
  final int urgentTickets;
  final int subTicketCount;
  final int totalSubTicketDepartments;

  AdminStats({
    required this.totalUsers,
    required this.totalDepartments,
    required this.totalTickets,
    required this.openTickets,
    required this.inProgressTickets,
    required this.closedTickets,
    required this.totalCompanies,
    this.overdueTickets = 0,
    this.urgentTickets = 0,
    this.subTicketCount = 0,
    this.totalSubTicketDepartments = 0,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) => AdminStats(
    totalUsers: json['totalUsers'] ?? 0,
    totalDepartments: json['totalDepartments'] ?? 0,
    totalTickets: json['totalTickets'] ?? 0,
    openTickets: json['openTickets'] ?? 0,
    inProgressTickets: json['inProgressTickets'] ?? 0,
    closedTickets: json['closedTickets'] ?? 0,
    totalCompanies: json['totalCompanies'] ?? 0,
    overdueTickets: json['overdueTickets'] ?? 0,
    urgentTickets: json['urgentTickets'] ?? 0,
    subTicketCount: json['subTicketCount'] ?? 0,
    totalSubTicketDepartments: json['totalSubTicketDepartments'] ?? 0,
  );
}

class AdminUserModel {
  final int id;
  final String name;
  final String email;
  final String? code;
  final String? designation;
  final int roleId;
  final int? departmentId;
  final int companyId;
  final bool isActive;
  final String? createdAt;
  final String? lastActive;
  final bool mustResetPassword;
  final String? roleName;
  final String? departmentName;
  final String? departmentCode;
  final String? companyName;
  final int? reportsTo;
  final String? reportsToName;
  final bool seeAllCompanies;

  bool get isOnline {
    if (lastActive == null) return false;
    final dt = DateTime.tryParse(lastActive!);
    if (dt == null) return false;
    return DateTime.now().difference(dt).inMinutes < 15;
  }

  AdminUserModel({
    required this.id,
    required this.name,
    required this.email,
    this.code,
    this.designation,
    required this.roleId,
    this.departmentId,
    required this.companyId,
    required this.isActive,
    this.createdAt,
    this.lastActive,
    this.mustResetPassword = false,
    this.roleName,
    this.departmentName,
    this.departmentCode,
    this.companyName,
    this.reportsTo,
    this.reportsToName,
    this.seeAllCompanies = false,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) => AdminUserModel(
    id: json['id'],
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    code: json['code'],
    designation: json['designation'],
    roleId: json['role_id'] ?? 2,
    departmentId: json['department_id'],
    companyId: json['company_id'] ?? 0,
    isActive: json['is_active'] ?? true,
    createdAt: json['created_at'],
    lastActive: json['last_active'],
    mustResetPassword: json['must_reset_password'] ?? false,
    roleName: json['role_name'],
    departmentName: json['department_name'],
    departmentCode: json['department_code'],
    companyName: json['company_name'],
    reportsTo: json['reports_to'],
    reportsToName: json['reports_to_name'],
    seeAllCompanies: json['see_all_companies'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'code': code,
    'designation': designation,
    'roleId': roleId,
    'departmentId': departmentId,
    'companyId': companyId,
    'isActive': isActive,
    if (reportsTo != null) 'reportsTo': reportsTo,
    'seeAllCompanies': seeAllCompanies,
  };
}

class AdminDeptModel {
  final int id;
  final String name;
  final String code;
  final int companyId;
  final String? tier;
  final int? parentId;
  final String? parentName;
  final String? companyName;
  final bool isShared;

  AdminDeptModel({
    required this.id,
    required this.name,
    required this.code,
    required this.companyId,
    this.tier,
    this.parentId,
    this.parentName,
    this.companyName,
    this.isShared = false,
  });

  factory AdminDeptModel.fromJson(Map<String, dynamic> json) => AdminDeptModel(
    id: json['id'],
    name: json['name'] ?? '',
    code: json['code'] ?? '',
    companyId: json['company_id'] ?? 0,
    tier: json['tier'],
    parentId: json['parent_id'],
    parentName: json['parent_name'],
    companyName: json['company_name'],
    isShared: json['is_shared'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'code': code,
    'companyId': companyId,
    'tier': tier,
    'parentId': parentId,
    'isShared': isShared,
  };
}

class AdminTicketModel {
  final int id;
  final String? ticketNumber;
  final String title;
  final String? description;
  final String status;
  final String priority;
  final int? createdById;
  final int? assignedDeptId;
  final int? assignedToId;
  final String? createdAt;
  final String? createdByName;
  final String? createdByEmail;
  final String? assignedDeptName;
  final String? assignedDeptCode;
  final String? assignedToName;
  final bool isSubTicket;
  final String? ticketType;
  final int? version;
  final String? lastAction;
  final String? lastActedByName;
  final String? lastActedByDeptName;
  final String? lastActionAt;
  final String? dueDate;
  final String? closedAt;
  final int? parentTicketId;
  final int immediateChildCount;

  AdminTicketModel({
    required this.id,
    this.ticketNumber,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.createdById,
    this.assignedDeptId,
    this.assignedToId,
    this.createdAt,
    this.createdByName,
    this.createdByEmail,
    this.assignedDeptName,
    this.assignedDeptCode,
    this.assignedToName,
    required this.isSubTicket,
    this.ticketType,
    this.version,
    this.lastAction,
    this.lastActedByName,
    this.lastActedByDeptName,
    this.lastActionAt,
    this.dueDate,
    this.closedAt,
    this.parentTicketId,
    this.immediateChildCount = 0,
  });

  bool get isOverdue =>
      dueDate != null &&
      DateTime.tryParse(dueDate!) != null &&
      DateTime.parse(dueDate!).isBefore(DateTime.now()) &&
      status != 'closed';

  factory AdminTicketModel.fromJson(Map<String, dynamic> json) => AdminTicketModel(
    id: json['id'],
    ticketNumber: json['ticket_number'],
    title: json['title'] ?? '',
    description: json['description'],
    status: json['status'] ?? 'open',
    priority: json['priority'] ?? 'low',
    createdById: json['created_by_id'],
    assignedDeptId: json['assigned_dept_id'],
    assignedToId: json['assigned_to_id'],
    createdAt: json['created_at'],
    createdByName: json['created_by_name'],
    createdByEmail: json['created_by_email'],
    assignedDeptName: json['assigned_dept_name'],
    assignedDeptCode: json['assigned_dept_code'],
    assignedToName: json['assigned_to_name'],
    isSubTicket: json['is_sub_ticket'] ?? false,
    ticketType: json['ticket_type'],
    version: json['version'] is String ? int.tryParse(json['version']) : json['version'],
    lastAction: json['last_action'],
    lastActedByName: json['last_acted_by_name'],
    lastActedByDeptName: json['last_acted_by_dept_name'],
    lastActionAt: json['last_action_at'],
    dueDate: json['due_date'],
    closedAt: json['closed_at'],
    parentTicketId: json['parent_ticket_id'],
    immediateChildCount: json['immediate_child_count'] ?? 0,
  );
}

class AdminSubTicketModel {
  final int id;
  final int ticketId;
  final int departmentId;
  final String? departmentName;
  final String? departmentCode;
  final String taskDescription;
  final String status;
  final int progressPercent;
  final String? assignedToName;
  AdminSubTicketModel({
    required this.id,
    required this.ticketId,
    required this.departmentId,
    this.departmentName,
    this.departmentCode,
    required this.taskDescription,
    required this.status,
    required this.progressPercent,
    this.assignedToName,
  });

  factory AdminSubTicketModel.fromJson(Map<String, dynamic> json) => AdminSubTicketModel(
    id: json['id'],
    ticketId: json['ticket_id'],
    departmentId: json['department_id'],
    departmentName: json['department_name'],
    departmentCode: json['department_code'],
    taskDescription: json['task_description'] ?? '',
    status: json['status'] ?? 'open',
    progressPercent: json['progress_percent'] ?? 0,
    assignedToName: json['assigned_to_name'],
  );
}
