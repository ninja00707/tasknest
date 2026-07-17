import 'package:equatable/equatable.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

class TicketListState extends Equatable {
  final String currentFilter;
  final int currentPage;
  final List<TicketModel> allTickets;
  final List<TicketModel> filteredTickets;
  final List<TicketModel> pagedTickets;
  final int totalPages;
  final int openCount;
  final int inProgressCount;
  final int completedCount;
  final int pendingCount;
  final int sentCompletedCount;
  final bool isWide;
  final double screenWidth;

  const TicketListState({
    required this.currentFilter,
    required this.currentPage,
    required this.allTickets,
    required this.filteredTickets,
    required this.pagedTickets,
    required this.totalPages,
    required this.openCount,
    required this.inProgressCount,
    required this.completedCount,
    required this.pendingCount,
    required this.sentCompletedCount,
    required this.isWide,
    required this.screenWidth,
  });

  static TicketListState initial({
    required List<TicketModel> tickets,
    int pageSize = 15,
    bool enablePagination = false,
    bool isWide = false,
    double screenWidth = 0,
  }) {
    final filtered = _applyFilter(tickets, 'All');
    final totalPages = enablePagination
        ? (filtered.isEmpty ? 1 : (filtered.length / pageSize).ceil().clamp(1, 9999))
        : 1;
    final paged = _paginate(filtered, 1, pageSize, enablePagination);

    return TicketListState(
      currentFilter: 'All',
      currentPage: 1,
      allTickets: tickets,
      filteredTickets: filtered,
      pagedTickets: paged,
      totalPages: totalPages,
      openCount: tickets.where((t) => t.status == 'open').length,
      inProgressCount: tickets.where((t) => t.status == 'in_progress').length,
      completedCount: tickets.where((t) => t.status == 'completed').length,
      pendingCount: tickets
          .where((t) => t.status == 'open' || t.status == 'in_progress')
          .length,
      sentCompletedCount: tickets
          .where((t) => t.status == 'completed' || t.status == 'closed')
          .length,
      isWide: isWide,
      screenWidth: screenWidth,
    );
  }

  static List<TicketModel> _applyFilter(List<TicketModel> tickets, String filter) {
    if (filter == 'All') return tickets;
    final status = filterToStatus(filter);
    if (status.isEmpty) return tickets;
    return tickets.where((t) => t.status == status).toList();
  }

  static List<TicketModel> _paginate(
    List<TicketModel> tickets,
    int page,
    int pageSize,
    bool enable,
  ) {
    if (!enable) return tickets;
    final start = (page - 1) * pageSize;
    final end = start + pageSize;
    return tickets.sublist(start, end > tickets.length ? tickets.length : end);
  }

  static String filterToStatus(String filter) {
    switch (filter) {
      case 'Open':
        return 'open';
      case 'In Progress':
        return 'in_progress';
      case 'Completed':
        return 'completed';
      case 'Closed':
        return 'closed';
      default:
        return filter.toLowerCase().replaceAll(' ', '_');
    }
  }

  TicketListState copyWithFiltered(String filter, int pageSize, bool enablePagination) {
    final filtered = _applyFilter(allTickets, filter);
    final totalPages = enablePagination
        ? (filtered.isEmpty ? 1 : (filtered.length / pageSize).ceil().clamp(1, 9999))
        : 1;
    final page = 1;
    final paged = _paginate(filtered, page, pageSize, enablePagination);
    return copyWith(
      currentFilter: filter,
      currentPage: page,
      filteredTickets: filtered,
      pagedTickets: paged,
      totalPages: totalPages,
    );
  }

  TicketListState copyWithPaged(int page, int pageSize, bool enablePagination) {
    final paged = _paginate(filteredTickets, page, pageSize, enablePagination);
    return copyWith(
      currentPage: page,
      pagedTickets: paged,
    );
  }

  TicketListState copyWith({
    String? currentFilter,
    int? currentPage,
    List<TicketModel>? allTickets,
    List<TicketModel>? filteredTickets,
    List<TicketModel>? pagedTickets,
    int? totalPages,
    int? openCount,
    int? inProgressCount,
    int? completedCount,
    int? pendingCount,
    int? sentCompletedCount,
    bool? isWide,
    double? screenWidth,
  }) {
    return TicketListState(
      currentFilter: currentFilter ?? this.currentFilter,
      currentPage: currentPage ?? this.currentPage,
      allTickets: allTickets ?? this.allTickets,
      filteredTickets: filteredTickets ?? this.filteredTickets,
      pagedTickets: pagedTickets ?? this.pagedTickets,
      totalPages: totalPages ?? this.totalPages,
      openCount: openCount ?? this.openCount,
      inProgressCount: inProgressCount ?? this.inProgressCount,
      completedCount: completedCount ?? this.completedCount,
      pendingCount: pendingCount ?? this.pendingCount,
      sentCompletedCount: sentCompletedCount ?? this.sentCompletedCount,
      isWide: isWide ?? this.isWide,
      screenWidth: screenWidth ?? this.screenWidth,
    );
  }

  @override
  List<Object?> get props => [
        currentFilter,
        currentPage,
        allTickets.length,
        filteredTickets.length,
        pagedTickets.length,
        totalPages,
        openCount,
        inProgressCount,
        completedCount,
        pendingCount,
        sentCompletedCount,
        isWide,
        screenWidth,
      ];
}
