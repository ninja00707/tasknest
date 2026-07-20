import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/data/datasource/socket_manager.dart';
import 'package:tasknest/domain/repositories_impl/ticket_impl/ticket_impl.dart';
import 'package:tasknest/presentation/ticket/bloc/ticket_event.dart';
import 'package:tasknest/presentation/ticket/bloc/ticket_state.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:injectable/injectable.dart';

@injectable
class TicketBloc extends Bloc<TicketEvent, TicketState> {
  final TicketRepositoryImpl _dataSource;
  final SocketManager _socketManager;
  StreamSubscription? _ticketUpdateSub;
  TicketModel? _lastLoadedTicket;
  int? _currentTicketId;

  TicketBloc(this._dataSource, this._socketManager) : super(TicketInitial()) {
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
    on<LoadTicketDetail>(_onLoadTicketDetail);
    on<ClearTicketDetail>(_onClearTicketDetail);
    on<SocketTicketDetailUpdated>(_onSocketTicketDetailUpdated);
  }

  void initLiveUpdates(int ticketId) {
    _ticketUpdateSub?.cancel();
    _socketManager.joinTicketRoom(ticketId);
    _currentTicketId = ticketId;

    _ticketUpdateSub = _socketManager.ticketUpdated.listen((data) {
      if (isClosed) return;
      try {
        final ticketData = data['ticket'];
        if (ticketData == null) return;
        final ticketIdFromData = data['ticketId'];
        if (ticketIdFromData != null && ticketIdFromData != _currentTicketId) return;

        final ticket = TicketModel.fromJson(Map<String, dynamic>.from(ticketData));
        add(SocketTicketDetailUpdated(ticket));
      } catch (e) {
        debugPrint('[TicketBloc] socket ticket:updated error: $e');
      }
    });
  }

  @override
  Future<void> close() {
    _ticketUpdateSub?.cancel();
    if (_currentTicketId != null) {
      _socketManager.leaveTicketRoom(_currentTicketId!);
    }
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
    } else if (error is Error) {
      errorMessage = error.toString();
    }
    return errorMessage;
  }

  Future<void> _onSelfAssign(
    SelfAssignTicket event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketActionInProgress());
    try {
      final updated = await _dataSource.selfAssign(event.ticketId);
      _lastLoadedTicket = updated;
      if (updated.parentTicketId != null) {
        await _promoteParentIfOpen(updated.parentTicketId!);
        // Re-fetch after parent promotion to get latest state
        final refreshed = await _dataSource.getTicket(event.ticketId);
        _lastLoadedTicket = refreshed;
        emit(TicketDetailLoaded(refreshed));
      } else {
        emit(TicketDetailLoaded(updated));
      }
    } catch (e) {
      emit(TicketActionError(_getFriendlyErrorMessage(e)));
      if (_lastLoadedTicket != null) emit(TicketDetailLoaded(_lastLoadedTicket!));
    }
  }

  Future<void> _onUpdateStatus(
    UpdateTicketStatus event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketActionInProgress());
    try {
      final updated = await _dataSource.updateStatus(
        event.ticketId,
        event.status,
        remark: event.remark,
      );
      _lastLoadedTicket = updated;
      emit(TicketDetailLoaded(updated));
    } catch (e) {
      emit(TicketActionError(_getFriendlyErrorMessage(e)));
      if (_lastLoadedTicket != null) emit(TicketDetailLoaded(_lastLoadedTicket!));
    }
  }

  Future<void> _onAssignEmployee(
    AssignTicketToEmployee event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketActionInProgress());
    try {
      final updated = await _dataSource.assignToEmployee(event.ticketId, event.employeeId);
      _lastLoadedTicket = updated;
      if (updated.parentTicketId != null) {
        await _promoteParentIfOpen(updated.parentTicketId!);
        // Re-fetch after parent promotion to get latest state
        final refreshed = await _dataSource.getTicket(event.ticketId);
        _lastLoadedTicket = refreshed;
        emit(TicketDetailLoaded(refreshed));
      } else {
        emit(TicketDetailLoaded(updated));
      }
    } catch (e) {
      emit(TicketActionError(_getFriendlyErrorMessage(e)));
      if (_lastLoadedTicket != null) emit(TicketDetailLoaded(_lastLoadedTicket!));
    }
  }

  Future<void> _onTransfer(
    TransferTicket event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketActionInProgress());
    try {
      final updated = await _dataSource.transferTicket(
        event.ticketId,
        event.targetDeptId,
        title: event.title,
        description: event.description,
      );
      _lastLoadedTicket = updated;
      emit(TicketDetailLoaded(updated));
    } catch (e) {
      emit(TicketActionError(_getFriendlyErrorMessage(e)));
      if (_lastLoadedTicket != null) emit(TicketDetailLoaded(_lastLoadedTicket!));
    }
  }

  Future<void> _onReopen(
    ReopenTicket event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketActionInProgress());
    try {
      final updated = await _dataSource.reopenTicket(event.ticketId);
      _lastLoadedTicket = updated;
      emit(TicketDetailLoaded(updated));
    } catch (e) {
      emit(TicketActionError(_getFriendlyErrorMessage(e)));
      if (_lastLoadedTicket != null) emit(TicketDetailLoaded(_lastLoadedTicket!));
    }
  }

  Future<void> _onCreate(
    CreateTicketEvent event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketActionInProgress());
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
      emit(TicketActionSuccess('Ticket created!'));
    } catch (e) {
      emit(TicketActionError(_getFriendlyErrorMessage(e)));
    }
  }

  Future<void> _onCreateSubTicket(
    CreateSubTicketEvent event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketActionInProgress());
    try {
      await _dataSource.createSubTicket(
        title: event.title,
        description: event.description,
        priority: event.priority,
        departments: event.departments,
        dueDate: event.dueDate,
        parentTicketId: event.parentTicketId,
      );
      // Re-fetch parent ticket to show new sub-ticket
      if (event.parentTicketId != null && _currentTicketId == event.parentTicketId) {
        final refreshed = await _dataSource.getTicket(event.parentTicketId!);
        _lastLoadedTicket = refreshed;
        emit(TicketDetailLoaded(refreshed));
      } else {
        emit(TicketActionSuccess('Sub-ticket created!'));
      }
    } catch (e) {
      emit(TicketActionError(_getFriendlyErrorMessage(e)));
    }
  }

  Future<void> _onUpdateSubDeptProgress(
    UpdateSubDeptProgressEvent event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketActionInProgress());
    try {
      await _dataSource.updateSubDeptProgress(
        ticketId: event.ticketId,
        departmentId: event.departmentId,
        status: event.status,
        note: event.note,
      );
      // Re-fetch to get updated sub-department progress
      final refreshed = await _dataSource.getTicket(event.ticketId);
      _lastLoadedTicket = refreshed;
      emit(TicketDetailLoaded(refreshed));
    } catch (e) {
      emit(TicketActionError(_getFriendlyErrorMessage(e)));
    }
  }

  Future<void> _onAssignSubDeptEmployee(
    AssignSubDeptEmployeeEvent event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketActionInProgress());
    try {
      await _dataSource.assignSubDeptToEmployee(
        ticketId: event.ticketId,
        departmentId: event.departmentId,
        employeeId: event.employeeId,
      );
      await _promoteParentIfOpen(event.ticketId);
      // Re-fetch to get updated assignment
      final refreshed = await _dataSource.getTicket(event.ticketId);
      _lastLoadedTicket = refreshed;
      emit(TicketDetailLoaded(refreshed));
    } catch (e) {
      emit(TicketActionError(_getFriendlyErrorMessage(e)));
    }
  }

  Future<void> _onSelfAssignSubDept(
    SelfAssignSubDept event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketActionInProgress());
    try {
      await _dataSource.selfAssignSubDept(event.ticketId, event.departmentId);
      await _promoteParentIfOpen(event.ticketId);
      // Re-fetch to get updated assignment
      final refreshed = await _dataSource.getTicket(event.ticketId);
      _lastLoadedTicket = refreshed;
      emit(TicketDetailLoaded(refreshed));
    } catch (e) {
      emit(TicketActionError(_getFriendlyErrorMessage(e)));
    }
  }

  Future<void> _promoteParentIfOpen(int ticketId) async {
    try {
      final ticket = await _dataSource.getTicket(ticketId);
      if (ticket.status == 'open') {
        await _dataSource.updateStatus(ticketId, 'in_progress');
      }
    } catch (_) {}
  }

  Future<void> _onReopenSubDept(
    ReopenSubDept event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketActionInProgress());
    try {
      await _dataSource.reopenSubDept(event.ticketId, event.departmentId);
      // Re-fetch to get updated state
      final refreshed = await _dataSource.getTicket(event.ticketId);
      _lastLoadedTicket = refreshed;
      emit(TicketDetailLoaded(refreshed));
    } catch (e) {
      emit(TicketActionError(_getFriendlyErrorMessage(e)));
    }
  }

  Future<void> _onCompleteSubTicket(
    CompleteSubTicket event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketActionInProgress());
    try {
      await _dataSource.completeSubTicket(event.ticketId);
      // Re-fetch to get updated state
      final refreshed = await _dataSource.getTicket(event.ticketId);
      _lastLoadedTicket = refreshed;
      emit(TicketDetailLoaded(refreshed));
    } catch (e) {
      emit(TicketActionError(_getFriendlyErrorMessage(e)));
    }
  }

  Future<void> _onAddComment(
    AddTicketComment event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketActionInProgress());
    try {
      await _dataSource.addComment(event.ticketId, event.message);
      final updated = await _dataSource.getTicket(event.ticketId);
      _lastLoadedTicket = updated;
      emit(TicketDetailLoaded(updated));
    } catch (e) {
      emit(TicketActionError(_getFriendlyErrorMessage(e)));
      if (_lastLoadedTicket != null) emit(TicketDetailLoaded(_lastLoadedTicket!));
    }
  }

  Future<void> _onLoadTicketDetail(
    LoadTicketDetail event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketActionInProgress());
    try {
      final ticket = await _dataSource.getTicket(event.ticketId);
      _lastLoadedTicket = ticket;
      _currentTicketId = event.ticketId;
      initLiveUpdates(event.ticketId);
      emit(TicketDetailLoaded(ticket));
    } catch (e) {
      emit(TicketActionError(_getFriendlyErrorMessage(e)));
      if (_lastLoadedTicket != null) {
        emit(TicketDetailLoaded(_lastLoadedTicket!));
      }
    }
  }

  Future<void> _onClearTicketDetail(
    ClearTicketDetail event,
    Emitter<TicketState> emit,
  ) async {
    _ticketUpdateSub?.cancel();
    if (_currentTicketId != null) {
      _socketManager.leaveTicketRoom(_currentTicketId!);
    }
    _lastLoadedTicket = null;
    _currentTicketId = null;
    emit(TicketInitial());
  }

  void _onSocketTicketDetailUpdated(SocketTicketDetailUpdated event, Emitter<TicketState> emit) {
    final currentState = state;
    if (currentState is TicketDetailLoaded && currentState.ticket.id == event.ticket.id) {
      _lastLoadedTicket = event.ticket;
      emit(TicketDetailLoaded(event.ticket));
    }
  }
}
