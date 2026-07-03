import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/data/datasource/localstorage/sharedpreferences.dart';
import 'package:tasknest/data/datasource/socket_service.dart';
import 'package:tasknest/data/repositories/ticket/ticket_repository.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final TicketRepository _dataSource;
  StreamSubscription<SocketEvent>? _socketSub;

  DashboardBloc(this._dataSource) : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoad);
    on<LoadEmployeesForDept>(_onLoadEmployeesForDept);
    on<FilterTickets>(_onFilter);
    on<SidebarSelectedIndexEvent>(_onSelectedIndex);
    on<UpdateNotificationCount>(_onUpdateNotificationCount);
    on<LoadTicketDetail>(_onLoadTicketDetail);
    on<ClearTicketDetail>(_onClearTicketDetail);
    on<SearchTickets>(_onSearch);
    on<ToggleTeamFilter>(_onToggleTeamFilter);
    on<LoadManagerAnalytics>(_onLoadManagerAnalytics);
    on<LoadCeoAnalytics>(_onLoadCeoAnalytics);
    on<ResetDashboardEvent>(_onReset);

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

  DashboardLoaded _getLoadedState() {
    final s = state;
    if (s is DashboardLoaded) return s;
    if (s is DashboardActionError) return s.previousState;
    if (s is DashboardActionSuccess) return s.previousState;
    if (s is TicketDetailLoaded) return s.previousState;
    throw StateError('Expected DashboardLoaded but got ${s.runtimeType}');
  }

  DashboardLoaded? _getLoadedStateOrNull() {
    final s = state;
    if (s is DashboardLoaded) return s;
    if (s is DashboardActionError) return s.previousState;
    if (s is DashboardActionSuccess) return s.previousState;
    if (s is TicketDetailLoaded) return s.previousState;
    return null;
  }

  // ── Socket ────────────────────────────────────────────────────────
  Timer? _socketDebounce;

  Future<void> _initSocket() async {
    _socketSub?.cancel();

    final token = await LocalStorageService().getToken();
    final user = await LocalStorageService().getUser();

    _socketSub = SocketService().events.listen((event) {
      if (isClosed) return;
      if (event.type == 'SOCKET_CONNECTED') {
        final loaded = _getLoadedStateOrNull();
        add(LoadDashboard(page: loaded?.currentPage ?? 1));
        return;
      }
      if (event.type == 'NOTIFICATION_COUNT') {
        final count = event.data['count'] as int?;
        if (count != null) add(UpdateNotificationCount(count));
        return;
      }
      _socketDebounce?.cancel();
      _socketDebounce = Timer(const Duration(milliseconds: 2000), () {
        if (!isClosed) {
          final loaded = _getLoadedStateOrNull();
          add(LoadDashboard(page: loaded?.currentPage ?? 1));
          final s = state;
          if (s is TicketDetailLoaded) {
            add(LoadTicketDetail(s.ticket.id));
          }
        }
      });
    });

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

  String _getFriendlyErrorMessage(dynamic error) {
    String errorMessage = 'An unexpected error occurred.';
    if (error is String) {
      final regex = RegExp(r"message: '([^']+)'");
      final match = regex.firstMatch(error);
      if (match != null && match.groupCount > 0) {
        errorMessage = match.group(1)!;
      } else {
        errorMessage = error;
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

      _initSocket();

      final prev = _getLoadedStateOrNull();
      final prevFilterTeam = prev?.filterTeam ?? false;
      final prevFilterStatus = prev?.filterStatus;
      final prevFilterPriority = prev?.filterPriority;

      final stats = await _dataSource.getStats();
      final effectivePage = (prev?.searchQuery?.isNotEmpty ?? false) ? 1 : event.page;
      final ticketResult = await _dataSource.getTickets(
        status: prevFilterStatus,
        priority: prevFilterPriority,
        page: effectivePage,
        scope: prevFilterTeam ? 'team' : null,
        search: prev?.searchQuery,
      );
      final tickets = ticketResult.tickets;
      final currentPage = ticketResult.page;
      final totalPages = ticketResult.totalPages;
      final currentDepts = prev?.departments ?? <DepartmentModel>[];
      final departments = currentDepts.isEmpty
          ? await _dataSource.getDepartments()
          : currentDepts;
      final needsEmployees = user.roleId == 1 || user.roleId == 0 || user.roleId == 3;
      final currentEmployees = prev?.employees ?? <EmployeeModel>[];
      final employees = needsEmployees && currentEmployees.isEmpty
          ? await _dataSource.getEmployees(departmentId: user.departmentId)
          : currentEmployees;
      final currentSent = prev?.sentTickets ?? <TicketModel>[];
      final sentTickets = currentSent.isEmpty
          ? await _dataSource.getSentTickets()
          : currentSent;

      final notifCount = await _dataSource.getUnreadCount();

      emit(
        DashboardLoaded(
          stats: stats,
          tickets: tickets,
          departments: departments,
          employees: employees,
          sentTickets: sentTickets,
          filterStatus: prevFilterStatus,
          filterPriority: prevFilterPriority,
          filterTeam: prevFilterTeam,
          selectedIndex: 0,
          currentPage: currentPage,
          totalPages: totalPages,
          unreadNotificationCount: notifCount,
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
    emit(prev.copyWith(
      filterStatus: event.status,
      filterPriority: event.priority,
    ));
    try {
      final ticketResult = await _dataSource.getTickets(
        status: event.status,
        priority: event.priority,
        page: 1,
        scope: prev.filterTeam ? 'team' : null,
        search: prev.searchQuery.isNotEmpty ? prev.searchQuery : null,
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

  // ── Toggle Team Filter ───────────────────────────────────────
  Future<void> _onToggleTeamFilter(
    ToggleTeamFilter event,
    Emitter<DashboardState> emit,
  ) async {
    final prev = _getLoadedState();
    try {
      final ticketResult = await _dataSource.getTickets(
        status: prev.filterStatus,
        priority: prev.filterPriority,
        page: 1,
        scope: event.active ? 'team' : null,
        search: prev.searchQuery.isNotEmpty ? prev.searchQuery : null,
      );
      emit(
        prev.copyWith(
          tickets: ticketResult.tickets,
          filterTeam: event.active,
          currentPage: ticketResult.page,
          totalPages: ticketResult.totalPages,
        ),
      );
    } catch (e) {
      emit(DashboardError(_getFriendlyErrorMessage(e)));
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
        // Silent fail
      }
    }
  }

  // ── Ticket Detail ────────────────────────────────────────────
  Future<void> _onLoadTicketDetail(
    LoadTicketDetail event,
    Emitter<DashboardState> emit,
  ) async {
    final prev = _getLoadedState();
    try {
      final ticket = await _dataSource.getTicket(event.ticketId);
      emit(TicketDetailLoaded(ticket, prev));
    } catch (e) {
      emit(DashboardActionError(_getFriendlyErrorMessage(e), prev));
    }
  }

  Future<void> _onClearTicketDetail(
    ClearTicketDetail event,
    Emitter<DashboardState> emit,
  ) async {
    final s = state;
    if (s is TicketDetailLoaded) {
      emit(s.previousState);
    }
  }

  // ── Search ────────────────────────────────────────────────────
  Future<void> _onSearch(
    SearchTickets event,
    Emitter<DashboardState> emit,
  ) async {
    final loaded = _getLoadedStateOrNull();
    if (loaded == null) return;
    emit(loaded.copyWith(searchQuery: event.query));
    if (event.query.isEmpty) {
      add(LoadDashboard(page: 1));
    }
  }

  // ── Manager Analytics ─────────────────────────────────────────
  Future<void> _onLoadManagerAnalytics(
    LoadManagerAnalytics event,
    Emitter<DashboardState> emit,
  ) async {
    emit(AnalyticsLoading());
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
      emit(AnalyticsError(_getFriendlyErrorMessage(e)));
    }
  }

  // ── Reset (used on logout) ────────────────────────────────────
  Future<void> _onReset(
    ResetDashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    _socketSub?.cancel();
    _socketDebounce?.cancel();
    _socketSub = null;
    _socketDebounce = null;
    SocketService().disconnect();
    emit(DashboardInitial());
  }
}
