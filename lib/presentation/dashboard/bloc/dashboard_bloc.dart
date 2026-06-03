import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/data/datasource/localstorage/sharedpreferences.dart';
import 'package:tasknest/data/datasource/ticketdatasource/ticket_remote_data_source.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/model/ticketmodel.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final TicketRemoteDataSource _dataSource;

  DashboardBloc(this._dataSource) : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoad);
    on<LoadEmployeesForDept>(_onLoadEmployeesForDept);
    on<FilterTickets>(_onFilter);
    on<SelfAssignTicket>(_onSelfAssign);
    on<UpdateTicketStatus>(_onUpdateStatus);
    on<AssignTicketToEmployee>(_onAssignEmployee);
    on<TransferTicket>(_onTransfer);
    on<ReopenTicket>(_onReopen);
    on<CreateTicket>(_onCreate);
    on<AddTicketComment>(_onAddComment);
    on<SidebarSelectedIndexEvent>(_onSelectedIndex);
    on<LoadManagerAnalytics>(_onLoadManagerAnalytics);
    on<LoadCeoAnalytics>(_onLoadCeoAnalytics);
  }

  Future<void> _onSelectedIndex(
    SidebarSelectedIndexEvent event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      emit(
        currentState.copyWith(selectedIndex: event.sidebarSelectedIndexEvent),
      );
    }
  }

  Future<void> _onLoad(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    try {
      final user = await LocalStorageService().getUser();
      if (user == null) throw Exception('User not found');

      final stats = await _dataSource.getStats();
      final tickets = await _dataSource.getTickets();
      final departments = await _dataSource.getDepartments();
      final employees = user.roleId == 1
          ? await _dataSource.getEmployees(departmentId: user.departmentId)
          : <EmployeeModel>[];
      final sentTickets = await _dataSource.getSentTickets();

      emit(
        DashboardLoaded(
          stats: stats,
          tickets: tickets,
          departments: departments,
          employees: employees,
          sentTickets: sentTickets,
        ),
      );
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _onFilter(
    FilterTickets event,
    Emitter<DashboardState> emit,
  ) async {
    final prev = state as DashboardLoaded;
    try {
      final tickets = await _dataSource.getTickets(
        status: event.status,
        priority: event.priority,
      );
      emit(
        prev.copyWith(
          tickets: tickets,
          filterStatus: event.status,
          filterPriority: event.priority,
        ),
      );
    } catch (e) {
      emit(TicketActionError(e.toString(), prev));
    }
  }

  Future<void> _onSelfAssign(
    SelfAssignTicket event,
    Emitter<DashboardState> emit,
  ) async {
    final prev = state as DashboardLoaded;
    try {
      await _dataSource.selfAssign(event.ticketId);
      emit(TicketActionSuccess('Ticket self-assigned!', prev));
      add(LoadDashboard());
    } catch (e) {
      emit(TicketActionError(e.toString(), prev));
    }
  }

  Future<void> _onUpdateStatus(
    UpdateTicketStatus event,
    Emitter<DashboardState> emit,
  ) async {
    final prev = state as DashboardLoaded;
    try {
      await _dataSource.updateStatus(
        event.ticketId,
        event.status,
        remark: event.remark,
      );
      emit(TicketActionSuccess('Status updated to ${event.status}', prev));
      add(LoadDashboard());
    } catch (e) {
      emit(TicketActionError(e.toString(), prev));
    }
  }

  Future<void> _onAssignEmployee(
    AssignTicketToEmployee event,
    Emitter<DashboardState> emit,
  ) async {
    final prev = state as DashboardLoaded;
    try {
      await _dataSource.assignToEmployee(event.ticketId, event.employeeId);
      emit(TicketActionSuccess('Ticket assigned successfully', prev));
      add(LoadDashboard());
    } catch (e) {
      emit(TicketActionError(e.toString(), prev));
    }
  }

  Future<void> _onTransfer(
    TransferTicket event,
    Emitter<DashboardState> emit,
  ) async {
    final prev = state as DashboardLoaded;
    try {
      await _dataSource.transferTicket(event.ticketId, event.targetDeptId);
      emit(TicketActionSuccess('Ticket transferred!', prev));
      add(LoadDashboard());
    } catch (e) {
      emit(TicketActionError(e.toString(), prev));
    }
  }

  Future<void> _onReopen(
    ReopenTicket event,
    Emitter<DashboardState> emit,
  ) async {
    final prev = state as DashboardLoaded;
    try {
      await _dataSource.reopenTicket(event.ticketId);
      emit(TicketActionSuccess('Ticket reopened!', prev));
      add(LoadDashboard());
    } catch (e) {
      emit(TicketActionError(e.toString(), prev));
    }
  }

  Future<void> _onLoadEmployeesForDept(
    LoadEmployeesForDept event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      try {
        final employees = await _dataSource.getEmployees(
          departmentId: event.deptId,
        );
        emit(currentState.copyWith(employees: employees));
      } catch (e) {
        // Silent fail or log error
      }
    }
  }

  Future<void> _onCreate(
    CreateTicket event,
    Emitter<DashboardState> emit,
  ) async {
    final prev = state as DashboardLoaded;

    try {
      await _dataSource.createTicket(
        title: event.title,
        description: event.description,
        priority: event.priority,
        assignedDeptId: event.assignedDeptId,
        dueDate: event.dueDate,
        parentId: event.parentId,
      );

      emit(TicketActionSuccess('Ticket created!', prev));

      add(LoadDashboard());
    } catch (e) {
      emit(TicketActionError(e.toString(), prev));
    }
  }

  Future<void> _onAddComment(
    AddTicketComment event,
    Emitter<DashboardState> emit,
  ) async {
    final prev = state as DashboardLoaded;
    try {
      await _dataSource.addComment(event.ticketId, event.message);
      emit(TicketActionSuccess('Comment added!', prev));
      add(LoadDashboard());
    } catch (e) {
      emit(TicketActionError(e.toString(), prev));
    }
  }

  Future<void> _onLoadManagerAnalytics(
    LoadManagerAnalytics event,
    Emitter<DashboardState> emit,
  ) async {
    emit(AnalyticsLoading()); // Indicate loading state for analytics
    try {
      final stats = await _dataSource.getDepartmentAnalytics(
        event.departmentId,
      );
      emit(ManagerAnalyticsLoaded(stats));
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }

  Future<void> _onLoadCeoAnalytics(
    LoadCeoAnalytics event,
    Emitter<DashboardState> emit,
  ) async {
    emit(AnalyticsLoading());
    try {
      final analytics = await _dataSource.getOrganizationAnalytics();
      emit(CeoAnalyticsLoaded(analytics));
    } catch (e) {
      emit(AnalyticsError(e.toString()));
    }
  }
}
