import 'package:equatable/equatable.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

sealed class TicketCardEvent extends Equatable {
  const TicketCardEvent();
}

final class InitializeTicketTracking extends TicketCardEvent {
  final List<TicketModel> tickets;
  const InitializeTicketTracking(this.tickets);
  @override
  List<Object> get props => [tickets.length];
}

final class SocketTicketUpdated extends TicketCardEvent {
  final int ticketId;
  const SocketTicketUpdated(this.ticketId);
  @override
  List<Object> get props => [ticketId];
}

final class PulseTick extends TicketCardEvent {
  const PulseTick();
  @override
  List<Object> get props => [];
}

final class CleanupStaleTickets extends TicketCardEvent {
  const CleanupStaleTickets();
  @override
  List<Object> get props => [];
}
