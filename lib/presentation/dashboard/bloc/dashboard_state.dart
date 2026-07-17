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
  final double screenWidth;
  final String greeting;
  final int sentCurrentPage;

  late final Map<String, List<TicketModel>> groupedTickets;
  late final List<TicketModel> sortedAllTickets;
  late final Map<String, List<TicketModel>> groupedByStatusFromSorted;
  late final bool hasActiveFilters;
  late final int openCount;
  late final int inProgressCount;
  late final int completedCount;
  late final int sentPendingCount;
  late final int sentCompletedCount;
  late final List<TicketModel> recentTickets;
  late final List<TicketModel> standardTickets;
  late final List<TicketModel> subTickets;
  late final List<TicketModel> multiTaskTickets;
  late final int standardTicketCount;
  late final int subTicketCount;
  late final int multiTaskTicketCount;
  late final int sentTotalPages;
  late final List<TicketModel> sentPagedTickets;

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
    this.screenWidth = 0,
    this.greeting = '',
    this.sentCurrentPage = 1,
  }) {
    groupedTickets = {};
    for (final s in CommonStatus.statuses) {
      groupedTickets[s] = tickets.where((t) => t.status == s).toList()
        ..sort((a, b) {
          final aTime = a.lastUpdatedAt ?? a.createdAt;
          final bTime = b.lastUpdatedAt ?? b.createdAt;
          return bTime.compareTo(aTime);
        });
    }

    sortedAllTickets = List<TicketModel>.from(tickets)
      ..sort((a, b) {
        final p = CommonStatus.priorityWeight(b.priority)
            .compareTo(CommonStatus.priorityWeight(a.priority));
        if (p != 0) return p;
        return CommonStatus.statusWeight(a.status)
            .compareTo(CommonStatus.statusWeight(b.status));
      });

    groupedByStatusFromSorted = {};
    for (final s in CommonStatus.statuses) {
      groupedByStatusFromSorted[s] = sortedAllTickets
          .where((t) => t.status == s)
          .toList();
    }

    hasActiveFilters = filterStatus != null || filterPriority != null;

    openCount = tickets.where((t) => t.status == 'open').length;
    inProgressCount = tickets.where((t) => t.status == 'in_progress').length;
    completedCount = tickets.where((t) => t.status == 'completed').length;
    sentPendingCount = sentTickets.where((t) => t.status != 'completed').length;
    sentCompletedCount = sentTickets.where((t) => t.status == 'completed').length;

    recentTickets = List<TicketModel>.from(tickets)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    standardTickets = tickets.where((t) => t.isStandardTicket).toList();
    subTickets = tickets.where((t) => t.isSubTicket).toList();
    multiTaskTickets = tickets.where((t) => t.isMultiTaskTicket).toList();
    standardTicketCount = standardTickets.length;
    subTicketCount = subTickets.length;
    multiTaskTicketCount = multiTaskTickets.length;

    sentTotalPages = sentTickets.isEmpty
        ? 1
        : (sentTickets.length / 15).ceil().clamp(1, 9999);

    final effectiveSentPage = sentCurrentPage > sentTotalPages ? sentTotalPages : sentCurrentPage;
    final sentStart = (effectiveSentPage - 1) * 15;
    final sentEnd = sentStart + 15;
    sentPagedTickets = sentTickets.sublist(sentStart, sentEnd > sentTickets.length ? sentTickets.length : sentEnd);
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
    double? screenWidth,
    String? greeting,
    int? sentCurrentPage,
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
      screenWidth: screenWidth ?? this.screenWidth,
      greeting: greeting ?? this.greeting,
      sentCurrentPage: sentCurrentPage ?? this.sentCurrentPage,
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
    screenWidth,
    greeting,
    sentCurrentPage,
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
