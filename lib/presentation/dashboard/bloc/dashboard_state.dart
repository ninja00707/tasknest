// ══════════════════════════════════════════════════════════════
//  STATES
// ══════════════════════════════════════════════════════════════
import 'package:equatable/equatable.dart';
import 'package:tasknest/core/constant/common_status.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

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
  final int selectedIndex;
  final int unreadNotificationCount;
  final int currentPage;
  final int totalPages;
  final bool isLoadingMore;
  final bool sidebarOpen;
  final bool shouldShowUpdateDialog;
  final String departmentName;
  final String roleName;
  final String companyName;
  final bool isWide;
  final String greeting;

  late final Map<String, List<TicketModel>> groupedTickets;

  DashboardLoaded({
    required this.stats,
    required this.tickets,
    required this.departments,
    required this.employees,
    required this.sentTickets,
    this.filterStatus,
    this.filterPriority,
    this.filterTeam = false,
    this.selectedIndex = 0,
    this.unreadNotificationCount = 0,
    this.currentPage = 1,
    this.totalPages = 1,
    this.isLoadingMore = false,
    this.sidebarOpen = true,
    this.shouldShowUpdateDialog = false,
    this.departmentName = '',
    this.roleName = '',
    this.companyName = '',
    this.isWide = false,
    this.greeting = '',
  }) {
    groupedTickets = {};
    for (final s in CommonStatus.statuses) {
      groupedTickets[s] = tickets.where((t) => t.status == s).toList()
        ..sort(
          (a, b) => CommonStatus.priorityWeight(
            a.priority,
          ).compareTo(CommonStatus.priorityWeight(b.priority)),
        );
    }
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
    int? selectedIndex,
    int? unreadNotificationCount,
    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,
    bool? sidebarOpen,
    bool? shouldShowUpdateDialog,
    String? departmentName,
    String? roleName,
    String? companyName,
    bool? isWide,
    String? greeting,
  }) {
    return DashboardLoaded(
      stats: stats ?? this.stats,
      tickets: tickets ?? this.tickets,
      departments: departments ?? this.departments,
      employees: employees ?? this.employees,
      sentTickets: sentTickets ?? this.sentTickets,
      filterStatus: identical(filterStatus, _sentinel)
          ? this.filterStatus
          : filterStatus as String?,
      filterPriority: identical(filterPriority, _sentinel)
          ? this.filterPriority
          : filterPriority as String?,
      filterTeam: filterTeam ?? this.filterTeam,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      unreadNotificationCount:
          unreadNotificationCount ?? this.unreadNotificationCount,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      sidebarOpen: sidebarOpen ?? this.sidebarOpen,
      shouldShowUpdateDialog:
          shouldShowUpdateDialog ?? this.shouldShowUpdateDialog,
      departmentName: departmentName ?? this.departmentName,
      roleName: roleName ?? this.roleName,
      companyName: companyName ?? this.companyName,
      isWide: isWide ?? this.isWide,
      greeting: greeting ?? this.greeting,
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
    selectedIndex,
    unreadNotificationCount,
    currentPage,
    totalPages,
    isLoadingMore,
    sidebarOpen,
    shouldShowUpdateDialog,
    departmentName,
    roleName,
    companyName,
    isWide,
    greeting,
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
  @override
  final String message;
  AnalyticsError(this.message);
  @override
  List<Object?> get props => [message];
}
