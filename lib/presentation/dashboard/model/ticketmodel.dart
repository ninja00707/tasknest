import 'package:flutter/material.dart';

class TicketModel {
  final int id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final int? parentId;
  final int createdById;
  final String createdByName;
  final int createdByDept;
  final String createdByDeptCode;
  final int assignedDeptId;
  final String assignedDeptCode;
  final String assignedDeptName;
  final int? assignedToId;
  final String? assignedToName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? dueDate;
  final int? overallProgress;

  TicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.parentId,
    required this.createdById,
    required this.createdByName,
    required this.createdByDept,
    required this.createdByDeptCode,
    required this.assignedDeptId,
    required this.assignedDeptCode,
    required this.assignedDeptName,
    this.assignedToId,
    this.assignedToName,
    required this.createdAt,
    required this.updatedAt,
    this.dueDate,
    this.overallProgress,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      priority: json['priority'],
      parentId: json['parent_id'],
      createdById: json['created_by_id'],
      createdByName: json['created_by_name'],
      createdByDept: json['created_by_dept'],
      createdByDeptCode: json['created_by_dept_code'],
      assignedDeptId: json['assigned_dept_id'],
      assignedDeptCode: json['assigned_dept_code'],
      assignedDeptName: json['assigned_dept_name'],
      assignedToId: json['assigned_to_id'],
      assignedToName: json['assigned_to_name'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      overallProgress: json['overall_progress'],
    );
  }
}

class DashboardStats {
  final int totalTickets;
  final int openTickets;
  final int inProgressTickets;
  final int resolvedTickets;
  final int closedTickets;
  final int overdueTickets;

  DashboardStats({
    required this.totalTickets,
    required this.openTickets,
    required this.inProgressTickets,
    required this.resolvedTickets,
    required this.closedTickets,
    required this.overdueTickets,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalTickets: json['total_tickets'],
      openTickets: json['open_tickets'],
      inProgressTickets: json['in_progress_tickets'],
      resolvedTickets: json['resolved_tickets'],
      closedTickets: json['closed_tickets'],
      overdueTickets: json['overdue_tickets'],
    );
  }
}

class DepartmentModel {
  final int id;
  final String name;
  final String deptCode;

  DepartmentModel({
    required this.id,
    required this.name,
    required this.deptCode,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'],
      name: json['name'],
      deptCode: json['dept_code'],
    );
  }
}

class EmployeeModel {
  final int id;
  final String name;
  final String email;
  final int roleId;
  final int departmentId;

  EmployeeModel({
    required this.id,
    required this.name,
    required this.email,
    required this.roleId,
    required this.departmentId,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      roleId: json['role_id'],
      departmentId: json['department_id'],
    );
  }
}
