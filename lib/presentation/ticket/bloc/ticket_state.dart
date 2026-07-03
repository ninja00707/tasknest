import 'package:equatable/equatable.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

abstract class TicketState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TicketInitial extends TicketState {}

class TicketActionInProgress extends TicketState {}

class TicketActionSuccess extends TicketState {
  final String message;
  TicketActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

class TicketActionError extends TicketState {
  final String message;
  TicketActionError(this.message);
  @override
  List<Object?> get props => [message];
}

class TicketDetailLoaded extends TicketState {
  final TicketModel ticket;
  TicketDetailLoaded(this.ticket);
  @override
  List<Object?> get props => [ticket];
}
