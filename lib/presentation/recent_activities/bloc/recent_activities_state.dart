import 'package:equatable/equatable.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

abstract class RecentActivitiesState extends Equatable {
  @override
  List<Object?> get props => [];
}

class RecentActivitiesInitial extends RecentActivitiesState {}

class RecentActivitiesLoaded extends RecentActivitiesState {
  final List<TicketModel> allTickets;
  final int currentPage;
  final int totalPages;
  final List<TicketModel> pagedTickets;
  final bool isWide;
  final double screenWidth;

  RecentActivitiesLoaded({
    required this.allTickets,
    required this.currentPage,
    required this.totalPages,
    required this.pagedTickets,
    required this.isWide,
    required this.screenWidth,
  });

  RecentActivitiesLoaded copyWith({
    List<TicketModel>? allTickets,
    int? currentPage,
    bool? isWide,
    double? screenWidth,
  }) {
    final newAll = allTickets ?? this.allTickets;
    final newPage = currentPage ?? this.currentPage;
    final newIsWide = isWide ?? this.isWide;
    final newWidth = screenWidth ?? this.screenWidth;
    final newTotalPages = newAll.isEmpty ? 1 : (newAll.length / 15).ceil().clamp(1, 9999);
    final ep = newPage > newTotalPages ? newTotalPages : newPage;
    final start = (ep - 1) * 15;
    final end = start + 15;
    final paged = newAll.sublist(start, end > newAll.length ? newAll.length : end);

    return RecentActivitiesLoaded(
      allTickets: newAll,
      currentPage: ep,
      totalPages: newTotalPages,
      pagedTickets: paged,
      isWide: newIsWide,
      screenWidth: newWidth,
    );
  }

  @override
  List<Object?> get props => [allTickets, currentPage, totalPages, pagedTickets, isWide, screenWidth];
}
