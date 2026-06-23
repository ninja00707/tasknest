// ══════════════════════════════════════════════════════════════
//  STATES
// ══════════════════════════════════════════════════════════════
import 'package:equatable/equatable.dart';
import 'package:tasknest/presentation/dashboard/model/ticketmodel.dart';

// Sentinel for copyWith to distinguish "set to null" from "keep existing"
class _Sentinel {
  const _Sentinel();
}

abstract class DashboardState extends Equatable {
  String? get message => null;
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
  final List<TicketModel> tickets;
  final List<DepartmentModel> departments;
  final List<EmployeeModel> employees;
  final List<TicketModel> sentTickets;
  final String? filterStatus;
  final String? filterPriority;
  final bool filterTeam;
  final String searchQuery;
  final int selectedIndex;
  final int unreadNotificationCount;
  final int currentPage;
  final int totalPages;

  DashboardLoaded({
    required this.stats,
    required this.tickets,
    required this.departments,
    required this.employees,
    required this.sentTickets,
    this.filterStatus,
    this.filterPriority,
    this.filterTeam = false,
    this.searchQuery = '',
    this.selectedIndex = 0,
    this.unreadNotificationCount = 0,
    this.currentPage = 1,
    this.totalPages = 1,
  });

  List<TicketModel> get filteredTickets {
    if (searchQuery.isEmpty) return tickets;
    final q = searchQuery.toLowerCase();
    return tickets.where((t) {
      // Normalize ticket number: "UMP-TKQ-001" or just "001"
      final ticketNum = t.ticketNumber.toLowerCase();
      final ticketNumShort = ticketNum.replaceAll('ump-tkq-', '');
      // Sub-ticket / child ticket numbers
      final childNums = t.children.map((c) => c.ticketNumber.toLowerCase());

      return ticketNum.contains(q) ||
          ticketNumShort.contains(q) ||
          t.title.toLowerCase().contains(q) ||
          t.createdByName.toLowerCase().contains(q) ||
          (t.assignedToName?.toLowerCase().contains(q) ?? false) ||
          t.assignedDeptName.toLowerCase().contains(q) ||
          t.assignedDeptCode.toLowerCase().contains(q) ||
          t.createdByDeptCode.toLowerCase().contains(q) ||
          (t.parentTicketNumber?.toLowerCase().contains(q) ?? false) ||
          childNums.any((n) => n.contains(q)) ||
          // Search by date: "2026-06-11" or "11 Jun"
          _formatDate(t.createdAt).contains(q);
    }).toList();
  }

  String _formatDate(DateTime dt) {
    final months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  static const _sentinel = _Sentinel();

  DashboardLoaded copyWith({
    DashboardStats? stats,
    List<TicketModel>? tickets,
    List<DepartmentModel>? departments,
    List<EmployeeModel>? employees,
    List<TicketModel>? sentTickets,
    Object? filterStatus = _sentinel,
    Object? filterPriority = _sentinel,
    bool? filterTeam,
    String? searchQuery,
    int? selectedIndex,
    int? unreadNotificationCount,
    int? currentPage,
    int? totalPages,
  }) {
    return DashboardLoaded(
      stats: stats ?? this.stats,
      tickets: tickets ?? this.tickets,
      departments: departments ?? this.departments,
      employees: employees ?? this.employees,
      sentTickets: sentTickets ?? this.sentTickets,
      filterStatus: identical(filterStatus, _sentinel) ? this.filterStatus : filterStatus as String?,
      filterPriority: identical(filterPriority, _sentinel) ? this.filterPriority : filterPriority as String?,
      filterTeam: filterTeam ?? this.filterTeam,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      unreadNotificationCount: unreadNotificationCount ?? this.unreadNotificationCount,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  @override
  List<Object?> get props => [
    stats,
    tickets,
    departments,
    employees,
    sentTickets,
    filterStatus,
    filterPriority,
    filterTeam,
    searchQuery,
    selectedIndex,
    unreadNotificationCount,
    currentPage,
    totalPages,
  ];
}

class DashboardError extends DashboardState {
  @override
  final String message;
  DashboardError(this.message);
  @override
  List<Object?> get props => [message];
}

class DashboardActionSuccess extends DashboardState {
  @override
  final String message;
  final DashboardLoaded previousState;
  DashboardActionSuccess(this.message, this.previousState);
  @override
  List<Object?> get props => [message];
}

class DashboardActionError extends DashboardState {
  @override
  final String message;
  final DashboardLoaded previousState;
  DashboardActionError(this.message, this.previousState);
  @override
  List<Object?> get props => [message];
}

class SidebarSelectedIndexState extends DashboardState {
  final int sidebarSelectedIndexState;

  SidebarSelectedIndexState({required this.sidebarSelectedIndexState});

  SidebarSelectedIndexState copyWith({int? sidebarSelectedIndexState}) =>
      SidebarSelectedIndexState(
        sidebarSelectedIndexState:
            sidebarSelectedIndexState ?? this.sidebarSelectedIndexState,
      );
  @override
  List<Object?> get props => [sidebarSelectedIndexState];
}

class TicketDetailLoaded extends DashboardState {
  final TicketModel ticket;
  final DashboardLoaded previousState;
  TicketDetailLoaded(this.ticket, this.previousState);
  @override
  List<Object?> get props => [ticket, previousState];
}

class AnalyticsLoading extends DashboardState {}

class ManagerAnalyticsLoaded extends DashboardState {
  final DashboardStats stats;
  ManagerAnalyticsLoaded(this.stats);
  @override
  List<Object?> get props => [stats];
}

class CeoAnalyticsLoaded extends DashboardState {
  final List<dynamic> departmentAnalytics;
  CeoAnalyticsLoaded(this.departmentAnalytics);
  @override
  List<Object?> get props => [departmentAnalytics];
}

class AnalyticsError extends DashboardState {
  final String message;
  AnalyticsError(this.message);
  @override
  List<Object?> get props => [message];
}

