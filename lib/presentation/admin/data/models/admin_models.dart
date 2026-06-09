class AdminStats {
  final int totalUsers;
  final int totalDepartments;
  final int totalTickets;
  final int openTickets;
  final int inProgressTickets;
  final int completedTickets;
  final int closedTickets;
  final int totalCompanies;

  AdminStats({
    required this.totalUsers,
    required this.totalDepartments,
    required this.totalTickets,
    required this.openTickets,
    required this.inProgressTickets,
    required this.completedTickets,
    required this.closedTickets,
    required this.totalCompanies,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) => AdminStats(
    totalUsers: json['totalUsers'] ?? 0,
    totalDepartments: json['totalDepartments'] ?? 0,
    totalTickets: json['totalTickets'] ?? 0,
    openTickets: json['openTickets'] ?? 0,
    inProgressTickets: json['inProgressTickets'] ?? 0,
    completedTickets: json['completedTickets'] ?? 0,
    closedTickets: json['closedTickets'] ?? 0,
    totalCompanies: json['totalCompanies'] ?? 0,
  );
}

class AdminUserModel {
  final int id;
  final String name;
  final String email;
  final int roleId;
  final int? departmentId;
  final int companyId;
  final bool isActive;
  final String? createdAt;
  final String? roleName;
  final String? departmentName;
  final String? departmentCode;
  final String? companyName;

  AdminUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.roleId,
    this.departmentId,
    required this.companyId,
    required this.isActive,
    this.createdAt,
    this.roleName,
    this.departmentName,
    this.departmentCode,
    this.companyName,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) => AdminUserModel(
    id: json['id'],
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    roleId: json['role_id'] ?? 2,
    departmentId: json['department_id'],
    companyId: json['company_id'] ?? 0,
    isActive: json['is_active'] ?? true,
    createdAt: json['created_at'],
    roleName: json['role_name'],
    departmentName: json['department_name'],
    departmentCode: json['department_code'],
    companyName: json['company_name'],
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'roleId': roleId,
    'departmentId': departmentId,
    'companyId': companyId,
    'isActive': isActive,
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

  AdminDeptModel({
    required this.id,
    required this.name,
    required this.code,
    required this.companyId,
    this.tier,
    this.parentId,
    this.parentName,
    this.companyName,
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
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'code': code,
    'companyId': companyId,
    'tier': tier,
    'parentId': parentId,
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
  });

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
  );
}
