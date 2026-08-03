import 'package:equatable/equatable.dart';

abstract class DisputeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadDisputeByTicket extends DisputeEvent {
  final int ticketId;
  LoadDisputeByTicket(this.ticketId);
  @override
  List<Object?> get props => [ticketId];
}

class LoadDisputes extends DisputeEvent {}

class RaiseDisputeEvent extends DisputeEvent {
  final int ticketId;
  final String reason;
  final String description;
  RaiseDisputeEvent({
    required this.ticketId,
    required this.reason,
    required this.description,
  });
  @override
  List<Object?> get props => [ticketId, reason, description];
}

class AddDisputeCommentEvent extends DisputeEvent {
  final int disputeId;
  final String note;
  AddDisputeCommentEvent({required this.disputeId, required this.note});
  @override
  List<Object?> get props => [disputeId, note];
}

class UpdateDisputeStatusEvent extends DisputeEvent {
  final int disputeId;
  final String status;
  final String? note;
  final int? reviewerId;
  UpdateDisputeStatusEvent({
    required this.disputeId,
    required this.status,
    this.note,
    this.reviewerId,
  });
  @override
  List<Object?> get props => [disputeId, status, note, reviewerId];
}

class WithdrawDisputeEvent extends DisputeEvent {
  final int disputeId;
  WithdrawDisputeEvent(this.disputeId);
  @override
  List<Object?> get props => [disputeId];
}

class ClearDispute extends DisputeEvent {}
