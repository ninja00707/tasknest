import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/data/datasource/localstorage/sharedpreferences.dart';
import 'package:tasknest/data/datasource/socket_service.dart';
import 'package:tasknest/data/datasource/ticketdatasource/ticket_remote_data_source.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/model/ticketmodel.dart';

// ══════════════════════════════════════════════════════════════
//  BLOC
// ══════════════════════════════════════════════════════════════
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final TicketRemoteDataSource _dataSource;
  StreamSubscription<SocketEvent>? _socketSub;

  DashboardBloc(this._dataSource) : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoad);
    on<LoadEmployeesForDept>(_onLoadEmployeesForDept);
    on<FilterTickets>(_onFilter);
    on<SelfAssignTicket>(_onSelfAssign);
    on<UpdateTicketStatus>(_onUpdateStatus);
    on<AssignTicketToEmployee>(_onAssignEmployee);
    on<TransferTicket>(_onTransfer);
    on<ReopenTicket>(_onReopen);
    on<CreateTicketEvent>(_onCreate);
    on<CreateSubTicketEvent>(_onCreateSubTicket);
    on<UpdateSubDeptProgressEvent>(_onUpdateSubDeptProgress);
    on<AssignSubDeptEmployeeEvent>(_onAssignSubDeptEmployee);
    on<SelfAssignSubDept>(_onSelfAssignSubDept);
    on<CompleteSubTicket>(_onCompleteSubTicket);
    on<ReopenSubDept>(_onReopenSubDept);
    on<AddTicketComment>(_onAddComment);
    on<SidebarSelectedIndexEvent>(_onSelectedIndex);
    on<UpdateNotificationCount>(_onUpdateNotificationCount);
    on<LoadManagerAnalytics>(_onLoadManagerAnalytics);
    on<LoadCeoAnalytics>(_onLoadCeoAnalytics);

    _initSocket();
  }

  Future<void> _onUpdateNotificationCount(
    UpdateNotificationCount event,
    Emitter<DashboardState> emit,
  ) async {
    final loaded = _getLoadedStateOrNull();
    if (loaded != null) {
      emit(loaded.copyWith(unreadNotificationCount: event.count));
    }
  }

  // Extract DashboardLoaded from current state (handles error states)
  DashboardLoaded _getLoadedState() {
    final s = state;
    if (s is DashboardLoaded) return s;
    if (s is DashboardActionError) return s.previousState;
    if (s is DashboardActionSuccess) return s.previousState;
    throw StateError('Expected DashboardLoaded but got ${s.runtimeType}');
  }

  DashboardLoaded? _getLoadedStateOrNull() {
    final s = state;
    if (s is DashboardLoaded) return s;
    if (s is DashboardActionError) return s.previousState;
    if (s is DashboardActionSuccess) return s.previousState;
    return null;
  }

  // ── Socket ────────────────────────────────────────────────────────
  Timer? _socketDebounce;

  Future<void> _initSocket() async {
    final token = await LocalStorageService().getToken();
    final user = await LocalStorageService().getUser();

    // Subscribe to events regardless of connection state
    _socketSub = SocketService().events.listen((event) {
      if (isClosed) return;
      if (event.type == 'NOTIFICATION_COUNT') {
        final count = event.data['count'] as int?;
        if (count != null) add(UpdateNotificationCount(count));
        return;
      }
      _socketDebounce?.cancel();
      _socketDebounce = Timer(const Duration(milliseconds: 500), () {
        if (!isClosed) {
          final loaded = _getLoadedStateOrNull();
          add(LoadDashboard(page: loaded?.currentPage ?? 1));
        }
      });
    });

    // Connect socket if credentials are available
    if (token != null && user != null) {
      SocketService().connect(
        token,
        userId: user.id,
        departmentId: user.departmentId,
      );
    }
  }

  @override
  Future<void> close() {
    _socketSub?.cancel();
    _socketDebounce?.cancel();
    return super.close();
  }

  // Helper to extract a user-friendly message from backend errors
  String _getFriendlyErrorMessage(dynamic error) {
    String errorMessage = 'An unexpected error occurred.';
    if (error is String) {
      // Attempt to parse a string that looks like "{ statusCode: 403, message: '...' }"
      final regex = RegExp(r"message: '([^']+)'");
      final match = regex.firstMatch(error);
      if (match != null && match.groupCount > 0) {
        errorMessage = match.group(1)!;
      } else {
        errorMessage = error; // Fallback to raw string if parsing fails
      }
    } else if (error is Exception) {
      errorMessage = error.toString();
    }
    return errorMessage;
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

  // Returns a LoadDashboard event preserving the current page
  LoadDashboard _reloadEvent() {
    final loaded = _getLoadedStateOrNull();
    return LoadDashboard(page: loaded?.currentPage ?? 1);
  }

  // ── Load ──────────────────────────────────────────────────────
  Future<void> _onLoad(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    final isInitialLoad = state is DashboardInitial;
    if (isInitialLoad) emit(DashboardLoading());

    try {
      final user = await LocalStorageService().getUser();
      if (user == null) throw Exception('User not found');

      // ✅ Sequential — a 401 on one won't nuke the token for others
      final stats = await _dataSource.getStats();
      final ticketResult = await _dataSource.getTickets(page: event.page);
      final tickets = ticketResult.tickets;
      final currentPage = ticketResult.page;
      final totalPages = ticketResult.totalPages;
      final departments = await _dataSource.getDepartments();
      // Only fetch employees on initial load (rarely changes)
      final needsEmployees = user.roleId == 1;
      final currentEmployees = _getLoadedStateOrNull()?.employees ?? <EmployeeModel>[];
      final employees = needsEmployees && currentEmployees.isEmpty
          ? await _dataSource.getEmployees(departmentId: user.departmentId)
          : currentEmployees;
      final sentTickets = await _dataSource.getSentTickets();

      emit(
        DashboardLoaded(
          stats: stats,
          tickets: tickets,
          departments: departments,
          employees: employees,
          sentTickets: sentTickets,
          selectedIndex: 0,
          currentPage: currentPage,
          totalPages: totalPages,
        ),
      );

    } catch (e) {
      emit(DashboardError(_getFriendlyErrorMessage(e)));
    }
  }

  // ── Filter ────────────────────────────────────────────────────
  Future<void> _onFilter(
    FilterTickets event,
    Emitter<DashboardState> emit,
  ) async {
    final prev = _getLoadedState();
    try {
      final ticketResult = await _dataSource.getTickets(
        status: event.status,
        priority: event.priority,
        page: 1,
      );
      emit(
        prev.copyWith(
          tickets: ticketResult.tickets,
          filterStatus: event.status,
          filterPriority: event.priority,
          currentPage: ticketResult.page,
          totalPages: ticketResult.totalPages,
        ),
      );
    } catch (e) {
      emit(DashboardError(_getFriendlyErrorMessage(e)));
    }
  }

  // ── Self Assign ───────────────────────────────────────────────
  Future<void> _onSelfAssign(
    SelfAssignTicket event,
    Emitter<DashboardState> emit,
  ) async {
    final prev = _getLoadedState();
    try {
      await _dataSource.selfAssign(event.ticketId);
      emit(DashboardActionSuccess('Ticket self-assigned!', prev));
      add(_reloadEvent());
    } catch (e) {
      emit(DashboardActionError(_getFriendlyErrorMessage(e), prev));
    }
  }

  // ── Update Status ─────────────────────────────────────────────
  Future<void> _onUpdateStatus(
    UpdateTicketStatus event,
    Emitter<DashboardState> emit,
  ) async {
    final prev = _getLoadedState();
    try {
      await _dataSource.updateStatus(
        event.ticketId,
        event.status,
        remark: event.remark,
      );
      emit(DashboardActionSuccess('Status updated to ${event.status}', prev));
      add(_reloadEvent());
    } catch (e) {
      // This is the specific catch for the 403 error
      emit(DashboardActionError(_getFriendlyErrorMessage(e), prev));
    }
  }

  // ── Assign to employee ────────────────────────────────────────
  Future<void> _onAssignEmployee(
    AssignTicketToEmployee event,
    Emitter<DashboardState> emit,
  ) async {
    final prev = _getLoadedState();
    try {
      await _dataSource.assignToEmployee(event.ticketId, event.employeeId);
      emit(DashboardActionSuccess('Ticket assigned successfully', prev));
      add(_reloadEvent());
    } catch (e) {
      // Apply error handling here too for consistency
      emit(DashboardActionError(_getFriendlyErrorMessage(e), prev));
    }
  }

  // ── Transfer ──────────────────────────────────────────────────
  Future<void> _onTransfer(
    TransferTicket event,
    Emitter<DashboardState> emit,
  ) async {
    final prev = _getLoadedState();
    try {
      await _dataSource.transferTicket(
        event.ticketId,
        event.targetDeptId,
        title: event.title,
        description: event.description,
      );
      emit(DashboardActionSuccess('Ticket transferred!', prev));
      add(_reloadEvent());
    } catch (e) {
      // Apply error handling here too for consistency
      emit(DashboardActionError(_getFriendlyErrorMessage(e), prev));
    }
  }

  // ── Reopen ────────────────────────────────────────────────────
  Future<void> _onReopen(
    ReopenTicket event,
    Emitter<DashboardState> emit,
  ) async {
    final prev = _getLoadedState();
    try {
      await _dataSource.reopenTicket(event.ticketId);
      emit(DashboardActionSuccess('Ticket reopened!', prev));
      add(_reloadEvent());
    } catch (e) {
      // Apply error handling here too for consistency
      emit(DashboardActionError(_getFriendlyErrorMessage(e), prev));
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
        // Silent fail or log error, but use the helper for consistency
      }
    }
  }

  // ── Create ────────────────────────────────────────────────────
  Future<void> _onCreate(
    CreateTicketEvent event,
    Emitter<DashboardState> emit,
  ) async {
    final prev = _getLoadedState();

    try {
      await _dataSource.createTicket(
        title: event.title,
        description: event.description,
        priority: event.priority,
        departmentIds: event.departmentIds,
        createdById: event.createdById,
        createdByDept: event.createdByDept,
        assignedToId: event.assignedToId,
        dueDate: event.dueDate,
        parentTicketId: event.parentTicketId,
        selfAssign: event.selfAssign,
        subTitle: event.subTitle,
        subDescription: event.subDescription,
        deptTickets: event.deptTickets?.map((d) => d.toJson()).toList(),
      );

      emit(DashboardActionSuccess('Ticket created!', prev));

      add(_reloadEvent());
    } catch (e) {
      // Apply error handling here too for consistency
      emit(DashboardActionError(_getFriendlyErrorMessage(e), prev));
    }
  }

  Future<void> _onCreateSubTicket(
    CreateSubTicketEvent event,
    Emitter<DashboardState> emit,
  ) async {
    final prev = _getLoadedState();
    try {
      await _dataSource.createSubTicket(
        title: event.title,
        description: event.description,
        priority: event.priority,
        departments: event.departments,
        dueDate: event.dueDate,
        parentTicketId: event.parentTicketId,
      );
      emit(DashboardActionSuccess('Sub-ticket created!', prev));
      add(_reloadEvent());
    } catch (e) {
      emit(DashboardActionError(_getFriendlyErrorMessage(e), prev));
    }
  }

  Future<void> _onUpdateSubDeptProgress(
    UpdateSubDeptProgressEvent event,
    Emitter<DashboardState> emit,
  ) async {
    final prev = _getLoadedState();
    try {
      await _dataSource.updateSubDeptProgress(
        ticketId: event.ticketId,
        departmentId: event.departmentId,
        status: event.status,
        note: event.note,
      );
      emit(DashboardActionSuccess('Department progress updated!', prev));
      add(_reloadEvent());
    } catch (e) {
      emit(DashboardActionError(_getFriendlyErrorMessage(e), prev));
    }
  }

  Future<void> _onAssignSubDeptEmployee(
    AssignSubDeptEmployeeEvent event,
    Emitter<DashboardState> emit,
  ) async {
    final prev = _getLoadedState();
    try {
      await _dataSource.assignSubDeptToEmployee(
        ticketId: event.ticketId,
        departmentId: event.departmentId,
        employeeId: event.employeeId,
      );
      emit(DashboardActionSuccess('Department work assigned!', prev));
      add(_reloadEvent());
    } catch (e) {
      emit(DashboardActionError(_getFriendlyErrorMessage(e), prev));
    }
  }

  // ── Self-Assign Sub-Dept ──────────────────────────────────────
  Future<void> _onSelfAssignSubDept(
    SelfAssignSubDept event,
    Emitter<DashboardState> emit,
  ) async {
    final prev = _getLoadedState();
    try {
      await _dataSource.selfAssignSubDept(event.ticketId, event.departmentId);
      emit(DashboardActionSuccess('Task self-assigned!', prev));
      add(_reloadEvent());
    } catch (e) {
      // Apply error handling here too for consistency
      emit(DashboardActionError(_getFriendlyErrorMessage(e), prev));
    }
  }

  // ── Reopen Sub-Dept (creator only, 48h window) ────────────────
  Future<void> _onReopenSubDept(
    ReopenSubDept event,
    Emitter<DashboardState> emit,
  ) async {
    final prev = _getLoadedState();
    try {
      await _dataSource.reopenSubDept(event.ticketId, event.departmentId);
      emit(DashboardActionSuccess('Department task reopened!', prev));
      add(_reloadEvent());
    } catch (e) {
      // Apply error handling here too for consistency
      emit(DashboardActionError(_getFriendlyErrorMessage(e), prev));
    }
  }

  // ── Complete Sub-Ticket (creator finalizes) ───────────────────
  Future<void> _onCompleteSubTicket(
    CompleteSubTicket event,
    Emitter<DashboardState> emit,
  ) async {
    final prev = _getLoadedState();
    try {
      await _dataSource.completeSubTicket(event.ticketId);
      emit(DashboardActionSuccess('Sub-ticket completed!', prev));
      add(_reloadEvent());
    } catch (e) {
      // Apply error handling here too for consistency
      emit(DashboardActionError(_getFriendlyErrorMessage(e), prev));
    }
  }

  // ── Add Comment ───────────────────────────────────────────────
  Future<void> _onAddComment(
    AddTicketComment event,
    Emitter<DashboardState> emit,
  ) async {
    final prev = _getLoadedState();
    try {
      await _dataSource.addComment(event.ticketId, event.message);
      emit(DashboardActionSuccess('Comment added!', prev));
      add(_reloadEvent());
    } catch (e) {
      // Apply error handling here too for consistency
      emit(DashboardActionError(_getFriendlyErrorMessage(e), prev));
    }
  }

  // ── Manager Analytics ─────────────────────────────────────────
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
      emit(AnalyticsError(_getFriendlyErrorMessage(e)));
    }
  }

  // ── CEO Analytics ─────────────────────────────────────────────
  Future<void> _onLoadCeoAnalytics(
    LoadCeoAnalytics event,
    Emitter<DashboardState> emit,
  ) async {
    emit(AnalyticsLoading());
    try {
      final analytics = await _dataSource.getOrganizationAnalytics();
      emit(CeoAnalyticsLoaded(analytics));
    } catch (e) {
      // Apply error handling here too for consistency
      emit(AnalyticsError(_getFriendlyErrorMessage(e)));
    }
  }
}
