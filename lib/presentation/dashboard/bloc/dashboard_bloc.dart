import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/data/datasource/socket_service.dart';
import 'package:tasknest/data/datasource/localstorage/sharedpreferences.dart';
import 'package:tasknest/data/datasource/ticketdatasource/ticket_remote_data_source.dart';
import 'package:tasknest/presentation/dashboard/model/ticketmodel.dart';
import 'package:tasknest/presentation/login/Models/auth_responce_model.dart';

import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final TicketRemoteDataSource _remoteDataSource;
  final SocketService _socketService;

  DashboardBloc(
    this._remoteDataSource,
    this._socketService, {
    required String? token,
  }) : super(DashboardLoading()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<SocketUpdateReceived>(_onSocketUpdateReceived);
    on<SelfAssignTicket>(_onSelfAssignTicket);
    on<UpdateTicketStatus>(_onUpdateTicketStatus);
    on<ReopenTicket>(_onReopenTicket);
    on<AssignTicketToEmployee>(_onAssignTicketToEmployee);
    on<TransferTicket>(_onTransferTicket);
    on<FilterTickets>(_onFilterTickets);
    on<SidebarSelectedIndexEvent>(_onSidebarSelectedIndex);
    on<LoadEmployeesForDept>(_onLoadEmployeesForDept);
    on<CreateTicketEvent>(_onCreateTicket);

    // Trigger initial load so the Stateless DashboardScreen gets data immediately
    add(LoadDashboard());

    // Initialize Socket Connection
    _socketService.initSocket(token, {
      // Pass the token to the socket service
      'ticket_data_changed': (data) {
        if (!isClosed) {
          add(SocketUpdateReceived());
        }
      },
    });
  }

  /// Helper to extract the data-bearing state regardless of current UI status
  DashboardLoaded? _getLastValidState() {
    final currentState = state;
    if (currentState is DashboardLoaded) return currentState;
    if (currentState is TicketActionError) return currentState.previousState;
    if (currentState is TicketActionSuccess) return currentState.previousState;
    return null;
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      int selectedIndex = 0;
      String? filterStatus;
      String? filterPriority;

      // Preserve existing filters and tab selection during a background refresh
      final lastValidState = _getLastValidState();

      if (lastValidState != null) {
        selectedIndex = lastValidState.selectedIndex;
        filterStatus = lastValidState.filterStatus;
        filterPriority = lastValidState.filterPriority;
      }

      // Execute all API calls in parallel for better performance
      final results = await Future.wait([
        LocalStorageService().getUser(),
        _remoteDataSource.getStats(),
        _remoteDataSource.getTickets(),
        _remoteDataSource.getSentTickets(),
        _remoteDataSource.getEmployees(),
        _remoteDataSource.getDepartments(),
      ]);

      final user = results[0] as UserModel?;
      if (user == null) {
        throw Exception("User session not found");
      }

      emit(
        DashboardLoaded(
          user: user,
          stats: results[1] as DashboardStats,
          tickets: results[2] as List<TicketModel>,
          sentTickets: results[3] as List<TicketModel>,
          employees: results[4] as List<EmployeeModel>,
          departments: results[5] as List<DepartmentModel>,
          selectedIndex: selectedIndex,
          filterStatus: filterStatus,
          filterPriority: filterPriority,
        ),
      );
    } catch (e) {
      final validState = _getLastValidState();
      if (validState != null) {
        emit(TicketActionError("Refresh failed: ${e.toString()}", validState));
      } else {
        emit(DashboardError(e.toString()));
      }
    }
  }

  void _onSocketUpdateReceived(
    SocketUpdateReceived event,
    Emitter<DashboardState> emit,
  ) {
    // Automatically re-fetch data without user interaction
    add(LoadDashboard());
  }

  Future<void> _onSelfAssignTicket(
    SelfAssignTicket event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    try {
      await _remoteDataSource.assignToEmployee(event.ticketId, event.userId);
      if (currentState is DashboardLoaded) {
        emit(TicketActionSuccess("Ticket assigned successfully", currentState));
        add(LoadDashboard());
      }
    } catch (e) {
      if (currentState is DashboardLoaded) {
        emit(TicketActionError(e.toString(), currentState));
      } else {
        emit(DashboardError(e.toString()));
      }
    }
  }

  Future<void> _onUpdateTicketStatus(
    UpdateTicketStatus event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    try {
      await _remoteDataSource.updateStatus(event.ticketId, event.status);
      if (currentState is DashboardLoaded) {
        emit(TicketActionSuccess("Status updated", currentState));
        add(LoadDashboard());
      }
    } catch (e) {
      if (currentState is DashboardLoaded) {
        emit(TicketActionError(e.toString(), currentState));
      } else {
        emit(DashboardError(e.toString()));
      }
    }
  }

  Future<void> _onReopenTicket(
    ReopenTicket event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    try {
      await _remoteDataSource.reopenTicket(event.ticketId);
      if (currentState is DashboardLoaded) {
        emit(TicketActionSuccess("Ticket reopened", currentState));
        add(LoadDashboard());
      }
    } catch (e) {
      if (currentState is DashboardLoaded) {
        emit(TicketActionError(e.toString(), currentState));
      } else {
        emit(DashboardError(e.toString()));
      }
    }
  }

  Future<void> _onAssignTicketToEmployee(
    AssignTicketToEmployee event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    try {
      await _remoteDataSource.assignToEmployee(
        event.ticketId,
        event.employeeId,
      );
      if (currentState is DashboardLoaded) {
        emit(TicketActionSuccess("Ticket assigned to employee", currentState));
        add(LoadDashboard());
      }
    } catch (e) {
      if (currentState is DashboardLoaded) {
        emit(TicketActionError(e.toString(), currentState));
      } else {
        emit(DashboardError(e.toString()));
      }
    }
  }

  Future<void> _onTransferTicket(
    TransferTicket event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    try {
      await _remoteDataSource.transferTicket(event.ticketId, event.deptId);
      if (currentState is DashboardLoaded) {
        emit(TicketActionSuccess("Ticket transferred", currentState));
        add(LoadDashboard());
      }
    } catch (e) {
      if (currentState is DashboardLoaded) {
        emit(TicketActionError(e.toString(), currentState));
      } else {
        emit(DashboardError(e.toString()));
      }
    }
  }

  void _onFilterTickets(FilterTickets event, Emitter<DashboardState> emit) {
    final currentState = _getLastValidState();
    if (currentState != null) {
      emit(
        currentState.copyWith(
          filterStatus: event.status,
          filterPriority: event.priority,
        ),
      );
    }
  }

  void _onSidebarSelectedIndex(
    SidebarSelectedIndexEvent event,
    Emitter<DashboardState> emit,
  ) {
    final currentState = _getLastValidState();
    if (currentState != null) {
      emit(
        currentState.copyWith(selectedIndex: event.sidebarSelectedIndexEvent),
      );
    }
  }

  Future<void> _onLoadEmployeesForDept(
    LoadEmployeesForDept event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = _getLastValidState();
    if (currentState != null) {
      try {
        final employees = await _remoteDataSource.getEmployees(
          departmentId: event.deptId,
        );
        emit(currentState.copyWith(employees: employees));
      } catch (e) {
        // Handle error
      }
    }
  }

  Future<void> _onCreateTicket(
    CreateTicketEvent event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = _getLastValidState();
    try {
      await _remoteDataSource.createTicket(
        title: event.title,
        description: event.description,
        priority: event.priority,
        assignedDeptId: event.assignedDeptId,
        assignedDeptIds: event.assignedDeptIds,
        assignedToId: event.assignedToId,
        createdById: event.createdById,
        createdByDept: event.createdByDept,
        dueDate: event.dueDate,
      );
      if (currentState != null) {
        // Switch to Dashboard (Index 0) automatically after creation
        emit(
          TicketActionSuccess(
            "Ticket created successfully",
            currentState.copyWith(selectedIndex: 0),
          ),
        );
        add(LoadDashboard());
      }
    } catch (e) {
      if (currentState != null) {
        emit(TicketActionError(e.toString(), currentState));
      }
    }
  }

  @override
  Future<void> close() {
    _socketService.dispose();
    return super.close();
  }
}
