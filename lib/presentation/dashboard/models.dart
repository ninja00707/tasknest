// ── User Roles ────────────────────────────────────────────────────────────────
enum UserRole { ceo, upperManagement, lowerDepartment }

// ── Departments ───────────────────────────────────────────────────────────────
enum Department {
  // Upper management (ticket creators)
  hr,
  admin,
  it,
  procurement,

  // Lower departments (ticket receivers + can assign to each other)
  la,
  lara,
  lafm,
  lbfm,
  feed,
  fm,
  fmas,
  fmps,
  fmsg,
  drag,
  finance,
}

extension DepartmentExt on Department {
  String get displayName {
    switch (this) {
      case Department.hr:          return 'HR';
      case Department.admin:       return 'Admin';
      case Department.it:          return 'IT';
      case Department.procurement: return 'Procurement';
      case Department.la:          return 'LA';
      case Department.lara:        return 'LARA';
      case Department.lafm:        return 'LAFM';
      case Department.lbfm:        return 'LBFM';
      case Department.feed:        return 'Feed';
      case Department.fm:          return 'FM';
      case Department.fmas:        return 'FMAS';
      case Department.fmps:        return 'FMPS';
      case Department.fmsg:        return 'FMSG';
      case Department.drag:        return 'Drag';
      case Department.finance:     return 'Finance';
    }
  }

  bool get isUpperManagement => [
    Department.hr,
    Department.admin,
    Department.it,
    Department.procurement,
  ].contains(this);

  bool get isLowerDepartment => !isUpperManagement;

  // Sub-departments of LA
  bool get isLaSub => [Department.lara, Department.lafm, Department.lbfm].contains(this);

  // Sub-departments of FM
  bool get isFmSub => [Department.fmas, Department.fmps, Department.fmsg].contains(this);
}

// ── Ticket Status ─────────────────────────────────────────────────────────────
enum TicketStatus { open, inProgress, completed, closed }

extension TicketStatusExt on TicketStatus {
  String get displayName {
    switch (this) {
      case TicketStatus.open:       return 'Open';
      case TicketStatus.inProgress: return 'In Progress';
      case TicketStatus.completed:  return 'Completed';
      case TicketStatus.closed:     return 'Closed';
    }
  }
}

// ── Priority ──────────────────────────────────────────────────────────────────
enum TicketPriority { low, medium, high, urgent }

extension TicketPriorityExt on TicketPriority {
  String get displayName {
    switch (this) {
      case TicketPriority.low:    return 'Low';
      case TicketPriority.medium: return 'Medium';
      case TicketPriority.high:   return 'High';
      case TicketPriority.urgent: return 'Urgent';
    }
  }
}

// ── Ticket Model ──────────────────────────────────────────────────────────────
class Ticket {
  final String         id;
  final String         title;
  final String         description;
  final Department     createdByDept;
  final Department     assignedToDept;
  final TicketStatus   status;
  final TicketPriority priority;
  final DateTime       createdAt;
  final DateTime?      dueDate;
  final String         createdByName;

  const Ticket({
    required this.id,
    required this.title,
    required this.description,
    required this.createdByDept,
    required this.assignedToDept,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.dueDate,
    required this.createdByName,
  });
}

// ── User Model ────────────────────────────────────────────────────────────────
class AppUser {
  final String     id;
  final String     name;
  final String     email;
  final UserRole   role;
  final Department department;
  final String     company; // 'UM Enterprises' or 'Matrix Pharma'

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.company,
  });
}
