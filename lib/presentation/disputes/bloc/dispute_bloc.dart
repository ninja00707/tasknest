import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/domain/repositories_impl/ticket_impl/ticket_impl.dart';
import 'package:tasknest/presentation/disputes/bloc/dispute_event.dart';
import 'package:tasknest/presentation/disputes/bloc/dispute_state.dart';
import 'package:tasknest/presentation/disputes/models/dispute_model.dart';

class DisputeBloc extends Bloc<DisputeEvent, DisputeState> {
  final TicketRepositoryImpl _dataSource;
  DisputeModel? _lastDispute;

  DisputeBloc(this._dataSource) : super(DisputeInitial()) {
    on<LoadDisputeByTicket>(_onLoadByTicket);
    on<LoadDisputes>(_onLoadList);
    on<RaiseDisputeEvent>(_onRaise);
    on<AddDisputeCommentEvent>(_onComment);
    on<UpdateDisputeStatusEvent>(_onUpdateStatus);
    on<WithdrawDisputeEvent>(_onWithdraw);
    on<ClearDispute>(_onClear);
  }

  String _friendly(dynamic error) {
    if (error is String) return error;
    if (error is Exception) return error.toString();
    return 'An unexpected error occurred.';
  }

  Future<void> _onLoadByTicket(
    LoadDisputeByTicket event,
    Emitter<DisputeState> emit,
  ) async {
    emit(DisputeLoading());
    try {
      final dispute = await _dataSource.getDisputeByTicket(event.ticketId);
      _lastDispute = dispute;
      emit(DisputeLoaded(dispute));
    } catch (e) {
      emit(DisputeActionError(_friendly(e)));
    }
  }

  Future<void> _onLoadList(
    LoadDisputes event,
    Emitter<DisputeState> emit,
  ) async {
    emit(DisputeLoading());
    try {
      final disputes = await _dataSource.listDisputes();
      emit(DisputeListLoaded(disputes));
    } catch (e) {
      emit(DisputeActionError(_friendly(e)));
    }
  }

  Future<void> _onRaise(
    RaiseDisputeEvent event,
    Emitter<DisputeState> emit,
  ) async {
    emit(DisputeActionInProgress());
    try {
      final dispute = await _dataSource.raiseDispute(
        event.ticketId,
        reason: event.reason,
        description: event.description,
      );
      _lastDispute = dispute;
      emit(DisputeActionSuccess('Dispute raised'));
      emit(DisputeLoaded(dispute));
    } catch (e) {
      emit(DisputeActionError(_friendly(e)));
      if (_lastDispute != null) emit(DisputeLoaded(_lastDispute));
    }
  }

  Future<void> _onComment(
    AddDisputeCommentEvent event,
    Emitter<DisputeState> emit,
  ) async {
    emit(DisputeActionInProgress());
    try {
      final dispute = await _dataSource.addDisputeComment(
        event.disputeId,
        event.note,
      );
      _lastDispute = dispute;
      emit(DisputeActionSuccess('Comment added'));
      emit(DisputeLoaded(dispute));
    } catch (e) {
      emit(DisputeActionError(_friendly(e)));
      if (_lastDispute != null) emit(DisputeLoaded(_lastDispute));
    }
  }

  Future<void> _onUpdateStatus(
    UpdateDisputeStatusEvent event,
    Emitter<DisputeState> emit,
  ) async {
    emit(DisputeActionInProgress());
    try {
      final dispute = await _dataSource.updateDisputeStatus(
        event.disputeId,
        status: event.status,
        note: event.note,
        reviewerId: event.reviewerId,
      );
      _lastDispute = dispute;
      emit(DisputeActionSuccess(_statusSuccess(event.status)));
      emit(DisputeLoaded(dispute));
    } catch (e) {
      emit(DisputeActionError(_friendly(e)));
      if (_lastDispute != null) emit(DisputeLoaded(_lastDispute));
    }
  }

  String _statusSuccess(String status) {
    switch (status) {
      case 'under_review':
        return 'Dispute moved to under review';
      case 'resolved':
        return 'Dispute resolved';
      case 'rejected':
        return 'Dispute rejected';
      case 'escalated':
        return 'Dispute escalated';
      default:
        return 'Dispute updated';
    }
  }

  Future<void> _onWithdraw(
    WithdrawDisputeEvent event,
    Emitter<DisputeState> emit,
  ) async {
    emit(DisputeActionInProgress());
    try {
      final dispute = await _dataSource.withdrawDispute(event.disputeId);
      _lastDispute = dispute;
      emit(DisputeActionSuccess('Dispute withdrawn'));
      emit(DisputeLoaded(dispute));
    } catch (e) {
      emit(DisputeActionError(_friendly(e)));
      if (_lastDispute != null) emit(DisputeLoaded(_lastDispute));
    }
  }

  Future<void> _onClear(
    ClearDispute event,
    Emitter<DisputeState> emit,
  ) async {
    _lastDispute = null;
    emit(DisputeInitial());
  }
}
