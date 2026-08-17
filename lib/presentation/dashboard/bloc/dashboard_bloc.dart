import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/changelog.dart';
import 'package:tasknest/core/constant/const_dep.dart';
import 'package:tasknest/core/constant/name_by_id.dart';
import 'package:tasknest/data/datasource/localstorage/sharedpreferences.dart';
import 'package:tasknest/data/datasource/socket_helper.dart';
import 'package:tasknest/data/repositories/ticket/ticket_realtime_repository.dart';
import 'package:tasknest/domain/repositories_impl/ticket_impl/ticket_impl.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:injectable/injectable.dart';

@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final TicketRepositoryImpl _dataSource;
  final TicketRealtimeRepository _realtime = TicketRealtimeRepository();
  StreamSubscription<SocketEvent>? _ticketSub;
  StreamSubscription<SocketEvent>? _connSub;
  StreamSubscription<Map<String, dynamic>>? _notifSub;
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
    on<PatchTicketOnDashboard>(_onPatchTicket);
    on<TicketCreatedOnDashboard>(_onTicketCreated);
    on<PatchChildTicketOnDashboard>(_onPatchChildTicket);

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
  final Set<int> _pendingPatchIds = {};
  Timer? _socketDebounce;

  Future<void> _initSocket() async {
    if (_socketInitialized && SocketHelper().isConnected) return;

    final token = await LocalStorageService().getToken();
    final user = await LocalStorageService().getUser();

    if (!_socketInitialized) {
      _realtime.initialize();
      _ticketSub?.cancel();
      _connSub?.cancel();
      _notifSub?.cancel();
      _connSub = _realtime.connectionEvents.listen((event) {
        if (isClosed) return;
        final loaded = _getLoadedStateOrNull();
        add(LoadDashboard(page: loaded?.currentPage ?? 1));
      });
      _notifSub = _realtime.notificationEvents.listen((event) {
        if (isClosed) return;
        if (event['type'] == 'NOTIFICATION_COUNT') {
          final data = event['data'];
          final count = data is Map ? data['count'] as int? : null;
          if (count != null) add(UpdateNotificationCount(count));
        }
      });
      _ticketSub = _realtime.ticketEvents.listen((event) {
        if (isClosed) return;
        final ticketId = event.data is Map ? event.data['ticketId'] : null;
        if (ticketId == null) return;

        final enrichedEventType = event.data is Map ? event.data['event'] : null;
        if (enrichedEventType == 'TICKET_CREATED') {
          final parentTicketId = event.data is Map ? event.data['parentTicketId'] : null;
          final parentChainRaw = event.data is Map ? event.data['parentChain'] : null;
          final parentChain = parentChainRaw is List
              ? parentChainRaw.whereType<int>().toList()
              : null;
          add(TicketCreatedOnDashboard(
            ticketId as int,
            parentTicketId: parentTicketId as int?,
            parentChain: parentChain,
          ));
        } else if (enrichedEventType == 'TICKET_CHILD_UPDATED') {
          final ticketJson = event.data is Map ? event.data['ticket'] : null;
          if (ticketJson is Map<String, dynamic>) {
            add(PatchChildTicketOnDashboard(ticketId as int, ticketJson));
          } else {
            _pendingPatchIds.add(ticketId as int);
            _socketDebounce?.cancel();
            _socketDebounce = Timer(const Duration(milliseconds: 200), () {
              if (isClosed) return;
              final ids = Set<int>.from(_pendingPatchIds);
              _pendingPatchIds.clear();
              for (final id in ids) {
                add(PatchTicketOnDashboard(id));
              }
            });
          }
        } else {
          _pendingPatchIds.add(ticketId as int);
          _socketDebounce?.cancel();
          _socketDebounce = Timer(const Duration(milliseconds: 200), () {
            if (isClosed) return;
            final ids = Set<int>.from(_pendingPatchIds);
            _pendingPatchIds.clear();
            for (final id in ids) {
              add(PatchTicketOnDashboard(id));
            }
          });
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

  // ── Incremental patch (replaces full LoadDashboard on socket events) ──
  Future<void> _onPatchTicket(
    PatchTicketOnDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    final loaded = _getLoadedStateOrNull();
    if (loaded == null) return;

    try {
      final updated = await _dataSource.getTicket(event.ticketId);

      // Sub-tickets should never appear as standalone cards in the dashboard.
      // Walk up the parent chain to find the root ancestor that IS in the list.
      if (updated.parentTicketId != null) {
        int? ancestorId = updated.parentTicketId;
        while (ancestorId != null) {
          final refreshed = _getLoadedStateOrNull();
          if (refreshed == null) return;
          final idx = refreshed.tickets.indexWhere((t) => t.id == ancestorId);
          if (idx >= 0) {
            try {
              final ancestor = await _dataSource.getTicket(ancestorId);
              final latest = _getLoadedStateOrNull();
              if (latest == null) return;
              final list = List<TicketModel>.from(latest.tickets);
              final pi = list.indexWhere((t) => t.id == ancestor.id);
              if (pi >= 0) {
                list[pi] = ancestor;
              } else {
                list.insert(0, ancestor);
              }
              emit(latest.copyWith(tickets: list));
            } catch (_) {}
            break;
          }
          // Ancestor not in list — walk up one more level
          try {
            final ancestorTicket = await _dataSource.getTicket(ancestorId);
            if (ancestorTicket.parentTicketId == null) {
              // Reached the root and it isn't on this user's dashboard yet.
              // Insert it so a freshly assigned sub-ticket appears live without
              // requiring a manual refresh.
              final latest = _getLoadedStateOrNull();
              if (latest == null) return;
              final list = List<TicketModel>.from(latest.tickets);
              final pi = list.indexWhere((t) => t.id == ancestorTicket.id);
              if (pi >= 0) {
                list[pi] = ancestorTicket;
              } else {
                list.insert(0, ancestorTicket);
              }
              emit(latest.copyWith(tickets: list));
              break;
            }
            ancestorId = ancestorTicket.parentTicketId;
          } catch (_) {
            break;
          }
        }
        return;
      }

      // Normal ticket (parent or standalone) — patch in place or insert
      final oldTickets = loaded.tickets;
      final idx = oldTickets.indexWhere((t) => t.id == updated.id);

      final newTickets = List<TicketModel>.from(oldTickets);
      if (idx >= 0) {
        newTickets[idx] = updated;
      } else {
        newTickets.insert(0, updated);
      }

      emit(loaded.copyWith(tickets: newTickets));
    } catch (_) {}
  }

  // ── New ticket arrival (from socket TICKET_CREATED) ────────────────
  Future<void> _onTicketCreated(
    TicketCreatedOnDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final latest = _getLoadedStateOrNull();
      if (latest == null) return;

      final ticket = await _dataSource.getTicket(event.ticketId);
      final list = List<TicketModel>.from(latest.tickets);

      if (ticket.parentTicketId != null) {
        int? ancestorId = event.parentTicketId ?? ticket.parentTicketId;
        while (ancestorId != null) {
          final idx = list.indexWhere((t) => t.id == ancestorId);
          if (idx >= 0) {
            try {
              final refreshed = await _dataSource.getTicket(ancestorId);
              list[idx] = refreshed;
            } catch (_) {}
            break;
          }
          try {
            final ancestor = await _dataSource.getTicket(ancestorId);
            if (ancestor.parentTicketId == null) {
              list.insert(0, ancestor);
              break;
            }
            ancestorId = ancestor.parentTicketId;
          } catch (_) {
            break;
          }
        }
      } else {
        final idx = list.indexWhere((t) => t.id == ticket.id);
        if (idx >= 0) {
          list[idx] = ticket;
        } else {
          list.insert(0, ticket);
        }
      }

      emit(latest.copyWith(tickets: list));
    } catch (e) {
      debugPrint('[DashboardBloc] _onTicketCreated failed: $e');
      add(LoadDashboard(page: _getLoadedStateOrNull()?.currentPage ?? 1));
    }
  }

  // ── Root ticket patch from TICKET_CHILD_UPDATED (no REST call) ────
  Future<void> _onPatchChildTicket(
    PatchChildTicketOnDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    final loaded = _getLoadedStateOrNull();
    if (loaded == null) return;

    try {
      final ticket = TicketModel.fromJson(event.ticketJson);
      final list = List<TicketModel>.from(loaded.tickets);
      final idx = list.indexWhere((t) => t.id == ticket.id);
      if (idx >= 0) {
        list[idx] = ticket;
      } else {
        list.insert(0, ticket);
      }
      emit(loaded.copyWith(tickets: list));
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _ticketSub?.cancel();
    _connSub?.cancel();
    _notifSub?.cancel();
    _socketDebounce?.cancel();
    _pendingPatchIds.clear();
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
    _ticketSub?.cancel();
    _connSub?.cancel();
    _notifSub?.cancel();
    _socketDebounce?.cancel();
    _pendingPatchIds.clear();
    _ticketSub = null;
    _connSub = null;
    _notifSub = null;
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
}
