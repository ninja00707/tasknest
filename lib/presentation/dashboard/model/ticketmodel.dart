import 'package:flutter/material.dart';

class Ticket {
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

  Ticket({
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

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
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
