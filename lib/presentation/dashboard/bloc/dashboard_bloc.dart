import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/changelog.dart';
import 'package:tasknest/core/constant/const_dep.dart';
import 'package:tasknest/core/constant/name_by_id.dart';
import 'package:tasknest/data/datasource/localstorage/sharedpreferences.dart';
import 'package:tasknest/data/datasource/socket_service.dart';
import 'package:tasknest/domain/repositories_impl/ticket_impl/ticket_impl.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:injectable/injectable.dart';

@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final TicketRepositoryImpl _dataSource;
  StreamSubscription<SocketEvent>? _socketSub;
  bool _socketInitialized = false;
  bool _isLoadingMore = false;

  DashboardBloc(this._dataSource) : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoad);
    on<FilterTickets>(_onFilter);
    on<LoadMoreTickets>(_onLoadMore);
    on<UpdateNotificationCount>(_onUpdateNotificationCount);
    on<LoadTicketDetail>(_onLoadTicketDetail);
    on<ClearTicketDetail>(_onClearTicketDetail);
    on<LoadManagerAnalytics>(_onLoadManagerAnalytics);
    on<LoadCeoAnalytics>(_onLoadCeoAnalytics);
    on<ResetDashboardEvent>(_onReset);
    on<ToggleSidebar>(_onToggleSidebar);
    on<MarkVersionSeen>(_onMarkVersionSeen);
    on<UpdateScreenSize>(_onUpdateScreenSize);

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
    if (_socketInitialized && SocketService().isConnected) return;

    final token = await LocalStorageService().getToken();
    final user = await LocalStorageService().getUser();

    if (!_socketInitialized) {
      _socketSub?.cancel();
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
        final isTicketEvent = event.type == 'TICKET_CREATED' ||
            event.type == 'TICKET_ASSIGNED' ||
            event.type == 'TICKET_STATUS_UPDATED' ||
            event.type == 'TICKET_REOPENED' ||
            event.type == 'TICKET_UPDATED' ||
            event.type == 'SUB_TICKET_CREATED' ||
            event.type == 'SUB_TICKET_ASSIGNED' ||
            event.type == 'SUB_TICKET_PROGRESS' ||
            event.type == 'SUB_TICKET_COMPLETED' ||
            event.type == 'SUB_TICKET_REOPENED';
        if (isTicketEvent) {
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
        } else {
          _socketDebounce?.cancel();
          _socketDebounce = Timer(const Duration(milliseconds: 2000), () {
            if (!isClosed) {
              final s = state;
              if (s is TicketDetailLoaded) {
                add(LoadTicketDetail(s.ticket.id));
              }
            }
          });
        }
      });
      _socketInitialized = true;
    }

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
    debugPrint('DashboardBloc error (${error.runtimeType}): $error');
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

      // Fire all independent API calls in parallel
      final statsF = _dataSource.getStats();
      final ticketsF = _dataSource.getTickets(page: event.page);
      final notifF = _dataSource.getUnreadCount();

      final currentDepts = prev?.departments ?? <DepartmentModel>[];
      final deptF = currentDepts.isEmpty ? _dataSource.getDepartments() : null;

      final needsEmployees = user.roleId == 1 || user.roleId == 0 || user.roleId == 3;
      final currentEmployees = prev?.employees ?? <EmployeeModel>[];
      final empF = needsEmployees && currentEmployees.isEmpty ? _dataSource.getEmployees() : null;

      final currentSent = prev?.sentTickets ?? <TicketModel>[];
      final sentF = currentSent.isEmpty ? _dataSource.getSentTickets() : null;

      await Future.wait([
        statsF,
        ticketsF,
        notifF,
        ?deptF,
        ?empF,
        ?sentF,
      ]);

      final stats = await statsF;
      final ticketResult = await ticketsF;
      final tickets = ticketResult.tickets;
      final currentPage = ticketResult.page;
      final totalPages = ticketResult.totalPages;
      final notifCount = await notifF;
      final departments = deptF != null ? await deptF : currentDepts;
      final employees = empF != null ? await empF : currentEmployees;
      final sentTickets = sentF != null ? await sentF : currentSent;

      final lastSeenVersion = await LocalStorageService().getLastSeenVersion();
      final shouldShowUpdate = lastSeenVersion != currentVersion;

      final deptLookup = departments
          .map((d) => Departments(name: d.name, id: d.id))
          .toList();
      final departmentName = NameById.getNameById<Departments>(
        id: user.departmentId,
        items: deptLookup,
        idSelector: (e) => e.id,
        nameSelector: (e) => e.name,
      );
      final roleName = NameById.getNameById<Roles>(
        id: user.roleId,
        items: roles,
        idSelector: (e) => e.id,
        nameSelector: (e) => e.name,
      );
      final companyName = NameById.getNameById<Company>(
        id: user.companyId,
        items: CompanyNames,
        idSelector: (e) => e.id,
        nameSelector: (e) => e.name,
      );

      final hour = DateTime.now().hour;
      final greeting = hour < 12
          ? 'Good morning'
          : hour < 17
          ? 'Good afternoon'
          : 'Good evening';

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
          unreadNotificationCount: notifCount,
          shouldShowUpdateDialog: shouldShowUpdate,
          departmentName: departmentName,
          roleName: roleName,
          companyName: companyName,
          isWide: prev?.isWide ?? false,
          greeting: greeting,
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
      final result = await _dataSource.filterTickets(
        status: event.status,
        priority: event.priority,
        search: event.search,
        teamOnly: event.teamOnly,
        page: event.page,
      );
      emit(prev.copyWith(
        tickets: result.tickets,
        currentPage: result.page,
        totalPages: result.totalPages,
        filterStatus: event.status ?? prev.filterStatus,
        filterPriority: event.priority ?? prev.filterPriority,
        filterTeam: event.teamOnly ?? prev.filterTeam,
      ));
    } catch (e) {
      emit(DashboardError(_getFriendlyErrorMessage(e)));
    }
  }

  // ── Load More (infinite scroll) ──────────────────────────────
  Future<void> _onLoadMore(
    LoadMoreTickets event,
    Emitter<DashboardState> emit,
  ) async {
    if (_isLoadingMore) return;
    final prev = _getLoadedStateOrNull();
    if (prev == null || prev.currentPage >= prev.totalPages) return;
    _isLoadingMore = true;
    try {
      final result = await _dataSource.filterTickets(
        status: prev.filterStatus,
        priority: prev.filterPriority,
        teamOnly: prev.filterTeam,
        page: prev.currentPage + 1,
      );
      emit(prev.copyWith(
        tickets: [...prev.tickets, ...result.tickets],
        currentPage: result.page,
        totalPages: result.totalPages,
      ));
    } catch (e) {
      _isLoadingMore = false;
    }
    _isLoadingMore = false;
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
    _socketInitialized = false;
    _isLoadingMore = false;
    SocketService().disconnect();
    emit(DashboardInitial());
  }

  void _onToggleSidebar(
    ToggleSidebar event,
    Emitter<DashboardState> emit,
  ) {
    final loaded = _getLoadedStateOrNull();
    if (loaded != null) {
      emit(loaded.copyWith(sidebarOpen: !loaded.sidebarOpen));
    }
  }

  Future<void> _onMarkVersionSeen(
    MarkVersionSeen event,
    Emitter<DashboardState> emit,
  ) async {
    await LocalStorageService().setLastSeenVersion(currentVersion);
    final loaded = _getLoadedStateOrNull();
    if (loaded != null) {
      emit(loaded.copyWith(shouldShowUpdateDialog: false));
    }
  }

  void _onUpdateScreenSize(
    UpdateScreenSize event,
    Emitter<DashboardState> emit,
  ) {
    final loaded = _getLoadedStateOrNull();
    if (loaded != null && loaded.isWide != event.isWide) {
      emit(loaded.copyWith(isWide: event.isWide));
    }
  }
}
