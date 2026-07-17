import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/changelog.dart';
import 'package:tasknest/core/constant/const_dep.dart';
import 'package:tasknest/core/constant/name_by_id.dart';
import 'package:tasknest/data/datasource/localstorage/sharedpreferences.dart';
import 'package:tasknest/data/datasource/socket_helper.dart';
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
    on<SocketTicketEventReceived>(_onSocketTicketEvent);

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
    if (_socketInitialized && SocketHelper().isConnected) return;

    final token = await LocalStorageService().getToken();
    final user = await LocalStorageService().getUser();

    if (!_socketInitialized) {
      _socketSub?.cancel();
      _socketSub = SocketHelper().events.listen((event) {
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
        final isTicketEvent =
            event.type == 'TICKET_CREATED' ||
            event.type == 'TICKET_ASSIGNED' ||
            event.type == 'TICKET_STATUS_UPDATED' ||
            event.type == 'TICKET_REOPENED' ||
            event.type == 'TICKET_UPDATED' ||
            event.type == 'TICKET_CLOSED' ||
            event.type == 'COMMENT_ADDED' ||
            event.type == 'SUB_TICKET_CREATED' ||
            event.type == 'SUB_TICKET_ASSIGNED' ||
            event.type == 'SUB_TICKET_PROGRESS' ||
            event.type == 'SUB_TICKET_COMPLETED' ||
            event.type == 'SUB_TICKET_REOPENED';
        if (isTicketEvent) {
          final data = event.data is Map ? Map<String, dynamic>.from(event.data as Map) : <String, dynamic>{};
          add(SocketTicketEventReceived(event.type, data));
        }
      });
      _socketInitialized = true;
    }

    if (token != null && user != null) {
      SocketHelper().connect(
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

      final needsEmployees =
          user.roleId == 1 || user.roleId == 0 || user.roleId == 3;
      final currentEmployees = prev?.employees ?? <EmployeeModel>[];
      final empF = needsEmployees && currentEmployees.isEmpty
          ? _dataSource.getEmployees()
          : null;

      final currentSent = prev?.sentTickets ?? <TicketModel>[];
      final sentF = currentSent.isEmpty ? _dataSource.getSentTickets() : null;

      await Future.wait([statsF, ticketsF, notifF, ?deptF, ?empF, ?sentF]);

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
      emit(
        prev.copyWith(
          tickets: result.tickets,
          currentPage: result.page,
          totalPages: result.totalPages,
          filterStatus: event.status ?? prev.filterStatus,
          filterPriority: event.priority ?? prev.filterPriority,
          filterTeam: event.teamOnly ?? prev.filterTeam,
        ),
      );
    } catch (e) {
      emit(DashboardError(_getFriendlyErrorMessage(e)));
    }
  }

  // ── Load More (infinite scroll) ──────────────────────────────
  Future<void> _onLoadMore(
    LoadMoreTickets event,
    Emitter<DashboardState> emit,
  ) async {
    final prev = _getLoadedStateOrNull();
    if (prev == null ||
        prev.isLoadingMore ||
        prev.currentPage >= prev.totalPages)
      return;
    emit(prev.copyWith(isLoadingMore: true));
    try {
      final result = await _dataSource.filterTickets(
        status: prev.filterStatus,
        priority: prev.filterPriority,
        teamOnly: prev.filterTeam,
        page: prev.currentPage + 1,
      );
      emit(
        prev.copyWith(
          tickets: [...prev.tickets, ...result.tickets],
          currentPage: result.page,
          totalPages: result.totalPages,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(prev.copyWith(isLoadingMore: false));
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
    SocketHelper().disconnect();
    emit(DashboardInitial());
  }

  void _onToggleSidebar(ToggleSidebar event, Emitter<DashboardState> emit) {
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
    if (loaded != null) {
      emit(loaded.copyWith(isWide: event.isWide, screenWidth: event.screenWidth));
    }
  }

  Future<void> _onSocketTicketEvent(
    SocketTicketEventReceived event,
    Emitter<DashboardState> emit,
  ) async {
    final loaded = _getLoadedStateOrNull();
    if (loaded == null) return;

    final ticketId = event.data['ticketId'] as int?;
    if (ticketId == null) return;

    // For new ticket creation, we immediately trigger soft background reloads.
    if (event.type == 'TICKET_CREATED' || event.type == 'SUB_TICKET_CREATED') {
      add(LoadDashboard(page: loaded.currentPage));
      final s = state;
      if (s is TicketDetailLoaded && s.ticket.id == ticketId) {
        add(LoadTicketDetail(ticketId));
      }
      return;
    }

    // For update events, we update the status and assignee in-memory instantly to keep the UI responsive!
    final updatedTickets = loaded.tickets.map((t) {
      if (t.id == ticketId) {
        String newStatus = t.status;
        String? newAssignee = t.assignedToName;
        int? newAssigneeId = t.assignedToId;

        if (event.data['newStatus'] != null) {
          newStatus = event.data['newStatus'] as String;
        }
        if (event.data['assignedTo'] != null) {
          newAssignee = event.data['assignedTo'] as String;
        }
        if (event.data['assignedToId'] != null) {
          newAssigneeId = event.data['assignedToId'] as int;
        }

        return t.copyWith(
          status: newStatus,
          assignedToName: newAssignee,
          assignedToId: newAssigneeId,
          lastAction: event.type,
          lastActedByName: event.data['actedByName'] as String?,
          lastUpdatedAt: DateTime.now(),
        );
      }
      return t;
    }).toList();

    final updatedSentTickets = loaded.sentTickets.map((t) {
      if (t.id == ticketId) {
        String newStatus = t.status;
        String? newAssignee = t.assignedToName;
        int? newAssigneeId = t.assignedToId;

        if (event.data['newStatus'] != null) {
          newStatus = event.data['newStatus'] as String;
        }
        if (event.data['assignedTo'] != null) {
          newAssignee = event.data['assignedTo'] as String;
        }
        if (event.data['assignedToId'] != null) {
          newAssigneeId = event.data['assignedToId'] as int;
        }

        return t.copyWith(
          status: newStatus,
          assignedToName: newAssignee,
          assignedToId: newAssigneeId,
          lastAction: event.type,
          lastActedByName: event.data['actedByName'] as String?,
          lastUpdatedAt: DateTime.now(),
        );
      }
      return t;
    }).toList();

    emit(loaded.copyWith(
      tickets: updatedTickets,
      sentTickets: updatedSentTickets,
    ));

    // If the user is currently viewing the details page of this specific ticket, update the detail state as well!
    final s = state;
    if (s is TicketDetailLoaded && s.ticket.id == ticketId) {
      final updatedDetailTicket = s.ticket.copyWith(
        status: event.data['newStatus'] as String? ?? s.ticket.status,
        assignedToName: event.data['assignedTo'] as String? ?? s.ticket.assignedToName,
        assignedToId: event.data['assignedToId'] as int? ?? s.ticket.assignedToId,
        lastAction: event.type,
        lastActedByName: event.data['actedByName'] as String?,
        lastUpdatedAt: DateTime.now(),
      );
      emit(TicketDetailLoaded(updatedDetailTicket, loaded.copyWith(
        tickets: updatedTickets,
        sentTickets: updatedSentTickets,
      )));
    }

    // Trigger soft background reloads to fetch full sync details (history, comments, child progress, stats)
    add(LoadDashboard(page: loaded.currentPage));
    if (state is TicketDetailLoaded) {
      final detailState = state as TicketDetailLoaded;
      if (detailState.ticket.id == ticketId) {
        add(LoadTicketDetail(ticketId));
      }
    }
  }
}
