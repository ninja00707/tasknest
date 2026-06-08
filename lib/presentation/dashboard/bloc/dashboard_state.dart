// ══════════════════════════════════════════════════════════════
//  STATES
// ══════════════════════════════════════════════════════════════
import 'package:equatable/equatable.dart';
import 'package:tasknest/presentation/dashboard/model/ticketmodel.dart';

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
    this.selectedIndex = 0,
    this.unreadNotificationCount = 0,
    this.currentPage = 1,
    this.totalPages = 1,
  });

  DashboardLoaded copyWith({
    DashboardStats? stats,
    List<TicketModel>? tickets,
    List<DepartmentModel>? departments,
    List<EmployeeModel>? employees,
    List<TicketModel>? sentTickets,
    String? filterStatus,
    String? filterPriority,
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
      filterStatus: filterStatus ?? this.filterStatus,
      filterPriority: filterPriority ?? this.filterPriority,
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

