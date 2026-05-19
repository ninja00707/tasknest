// ══════════════════════════════════════════════════════════════
//  STATES
// ══════════════════════════════════════════════════════════════
import 'package:equatable/equatable.dart';
import 'package:tasknest/presentation/dashboard/model/ticketmodel.dart';

abstract class DashboardState extends Equatable {
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

  DashboardLoaded({
    required this.stats,
    required this.tickets,
    required this.departments,
    required this.employees,
    required this.sentTickets,
    this.filterStatus,
    this.filterPriority,
    this.selectedIndex = 0,
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
  ];
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
  @override
  List<Object?> get props => [message];
}

class TicketActionSuccess extends DashboardState {
  final String message;
  final DashboardLoaded previousState;
  TicketActionSuccess(this.message, this.previousState);
  @override
  List<Object?> get props => [message];
}

class TicketActionError extends DashboardState {
  final String message;
  final DashboardLoaded previousState;
  TicketActionError(this.message, this.previousState);
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
