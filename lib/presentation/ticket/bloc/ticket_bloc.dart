import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/data/repositories/ticket/ticket_repository.dart';
import 'package:tasknest/presentation/ticket/bloc/ticket_event.dart';
import 'package:tasknest/presentation/ticket/bloc/ticket_state.dart';

class TicketBloc extends Bloc<TicketEvent, TicketState> {
  final TicketRepository _dataSource;

  TicketBloc(this._dataSource) : super(TicketInitial()) {
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

  Future<void> _onSelfAssign(
    SelfAssignTicket event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketActionInProgress());
    try {
      final updated = await _dataSource.selfAssign(event.ticketId);
      emit(TicketDetailLoaded(updated));
    } catch (e) {
      emit(TicketActionError(_getFriendlyErrorMessage(e)));
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
      emit(TicketDetailLoaded(updated));
    } catch (e) {
      emit(TicketActionError(_getFriendlyErrorMessage(e)));
    }
  }

  Future<void> _onAssignEmployee(
    AssignTicketToEmployee event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketActionInProgress());
    try {
      final updated = await _dataSource.assignToEmployee(event.ticketId, event.employeeId);
      emit(TicketDetailLoaded(updated));
    } catch (e) {
      emit(TicketActionError(_getFriendlyErrorMessage(e)));
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
      emit(TicketDetailLoaded(updated));
    } catch (e) {
      emit(TicketActionError(_getFriendlyErrorMessage(e)));
    }
  }

  Future<void> _onReopen(
    ReopenTicket event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketActionInProgress());
    try {
      final updated = await _dataSource.reopenTicket(event.ticketId);
      emit(TicketDetailLoaded(updated));
    } catch (e) {
      emit(TicketActionError(_getFriendlyErrorMessage(e)));
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
      emit(TicketActionSuccess('Sub-ticket created!'));
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
      emit(TicketActionSuccess('Department progress updated!'));
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
      emit(TicketActionSuccess('Department work assigned!'));
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
      emit(TicketActionSuccess('Task self-assigned!'));
    } catch (e) {
      emit(TicketActionError(_getFriendlyErrorMessage(e)));
    }
  }

  Future<void> _onReopenSubDept(
    ReopenSubDept event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketActionInProgress());
    try {
      await _dataSource.reopenSubDept(event.ticketId, event.departmentId);
      emit(TicketActionSuccess('Department task reopened!'));
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
      emit(TicketActionSuccess('Sub-ticket completed!'));
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
      emit(TicketActionSuccess('Comment added!'));
    } catch (e) {
      emit(TicketActionError(_getFriendlyErrorMessage(e)));
    }
  }

  Future<void> _onLoadTicketDetail(
    LoadTicketDetail event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketActionInProgress());
    try {
      final ticket = await _dataSource.getTicket(event.ticketId);
      emit(TicketDetailLoaded(ticket));
    } catch (e) {
      emit(TicketActionError(_getFriendlyErrorMessage(e)));
    }
  }

  Future<void> _onClearTicketDetail(
    ClearTicketDetail event,
    Emitter<TicketState> emit,
  ) async {
    emit(TicketInitial());
  }
}
