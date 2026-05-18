import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/data/datasource/ticketdatasource/ticket_remote_data_source.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_event.dart';
import 'package:tasknest/presentation/dashboard/bloc/dashboard_state.dart';
import 'package:tasknest/presentation/dashboard/model/ticketmodel.dart';

// ══════════════════════════════════════════════════════════════
//  BLOC
// ══════════════════════════════════════════════════════════════
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final TicketRemoteDataSource _dataSource;

  DashboardBloc(this._dataSource) : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoad);
    on<FilterTickets>(_onFilter);
    on<SelfAssignTicket>(_onSelfAssign);
    on<UpdateTicketStatus>(_onUpdateStatus);
    on<AssignTicketToEmployee>(_onAssignEmployee);
    on<TransferTicket>(_onTransfer);
    on<ReopenTicket>(_onReopen);
    on<CreateTicketEvent>(_onCreate);
  }

  // ── Load ──────────────────────────────────────────────────────
  Future<void> _onLoad(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final results = await Future.wait([
        _dataSource.getStats(),
        _dataSource.getTickets(),
        _dataSource.getDepartments(),
      ]);
      emit(
        DashboardLoaded(
          stats: results[0] as DashboardStats,
          tickets: results[1] as List<TicketModel>,
          departments: results[2] as List<DepartmentModel>,
        ),
      );
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  // ── Filter ────────────────────────────────────────────────────
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

  // ── Self Assign ───────────────────────────────────────────────
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

  // ── Update Status ─────────────────────────────────────────────
  Future<void> _onUpdateStatus(
    UpdateTicketStatus event,
    Emitter<DashboardState> emit,
  ) async {
    final prev = state as DashboardLoaded;
    try {
      await _dataSource.updateStatus(event.ticketId, event.status);
      emit(TicketActionSuccess('Status updated to ${event.status}', prev));
      add(LoadDashboard());
    } catch (e) {
      emit(TicketActionError(e.toString(), prev));
    }
  }

  // ── Assign to employee ────────────────────────────────────────
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

  // ── Transfer ──────────────────────────────────────────────────
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

  // ── Reopen ────────────────────────────────────────────────────
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

  // ── Create ────────────────────────────────────────────────────
  Future<void> _onCreate(
    CreateTicketEvent event,
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
      );
      emit(TicketActionSuccess('Ticket created!', prev));
      add(LoadDashboard());
    } catch (e) {
      emit(TicketActionError(e.toString(), prev));
    }
  }
}
