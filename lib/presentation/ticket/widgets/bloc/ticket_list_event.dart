import 'package:equatable/equatable.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

sealed class TicketListEvent extends Equatable {
  const TicketListEvent();
}

final class FilterChanged extends TicketListEvent {
  final String filter;
  const FilterChanged(this.filter);
  @override
  List<Object?> get props => [filter];
}

final class PageChanged extends TicketListEvent {
  final int page;
  const PageChanged(this.page);
  @override
  List<Object?> get props => [page];
}

final class ScreenSizeChanged extends TicketListEvent {
  final bool isWide;
  final double screenWidth;
  const ScreenSizeChanged({required this.isWide, required this.screenWidth});
  @override
  List<Object?> get props => [isWide, screenWidth];
}

final class TicketsChanged extends TicketListEvent {
  final List<TicketModel> tickets;
  const TicketsChanged(this.tickets);
  @override
  List<Object?> get props => [tickets.length];
}
