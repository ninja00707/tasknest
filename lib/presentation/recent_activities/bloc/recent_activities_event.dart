import 'package:equatable/equatable.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

abstract class RecentActivitiesEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadRecentActivities extends RecentActivitiesEvent {
  final List<TicketModel> tickets;
  final bool isWide;
  final double screenWidth;
  LoadRecentActivities({
    required this.tickets,
    required this.isWide,
    required this.screenWidth,
  });
  @override
  List<Object?> get props => [tickets, isWide, screenWidth];
}

class RecentPageChanged extends RecentActivitiesEvent {
  final int page;
  RecentPageChanged(this.page);
  @override
  List<Object?> get props => [page];
}

class UpdateRecentScreenSize extends RecentActivitiesEvent {
  final bool isWide;
  final double screenWidth;
  UpdateRecentScreenSize(this.isWide, this.screenWidth);
  @override
  List<Object?> get props => [isWide, screenWidth];
}
