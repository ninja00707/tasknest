import 'package:equatable/equatable.dart';
import 'package:tasknest/presentation/admin/data/models/admin_models.dart';

abstract class AdminState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminDashboardLoaded extends AdminState {
  final AdminStats stats;
  AdminDashboardLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class UsersScreenState extends AdminState {
  final List<AdminUserModel> allUsers;
  final List<AdminUserModel> pendingUsers;
  final int selectedTab;
  final String searchQuery;
  final bool showMissingCodeOnly;
  final int page;

  static const int pageSize = 30;

  UsersScreenState({
    this.allUsers = const [],
    this.pendingUsers = const [],
    this.selectedTab = 0,
    this.searchQuery = '',
    this.showMissingCodeOnly = false,
    this.page = 0,
  });

  List<AdminUserModel> get currentUsers =>
      selectedTab == 0 ? allUsers : pendingUsers;

  List<AdminUserModel> get filteredUsers {
    var result = currentUsers;
    if (showMissingCodeOnly) {
      result = result.where((u) => u.code == null || u.code!.isEmpty).toList();
    }
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result
          .where((u) =>
              u.name.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q) ||
              (u.code?.toLowerCase().contains(q) ?? false) ||
              (u.designation?.toLowerCase().contains(q) ?? false) ||
              (u.departmentName?.toLowerCase().contains(q) ?? false) ||
              (u.roleName?.toLowerCase().contains(q) ?? false))
          .toList();
    }
    return result;
  }

  int get totalPages =>
      filteredUsers.isEmpty ? 1 : (filteredUsers.length / pageSize).ceil();

  int get clampedPage {
    final pages = totalPages;
    if (page >= pages) return (pages - 1).clamp(0, pages);
    return page;
  }

  List<AdminUserModel> get pageItems {
    final start = clampedPage * pageSize;
    if (start >= filteredUsers.length) return [];
    return filteredUsers
        .sublist(start, (start + pageSize).clamp(0, filteredUsers.length));
  }

  @override
  List<Object?> get props => [
        allUsers,
        pendingUsers,
        selectedTab,
        searchQuery,
        showMissingCodeOnly,
        page,
      ];
}

class DepartmentsLoaded extends AdminState {
  final List<AdminDeptModel> departments;
  final String searchQuery;
  final int page;

  static const int pageSize = 15;

  DepartmentsLoaded(this.departments, {this.searchQuery = '', this.page = 1});

  List<AdminDeptModel> get filtered {
    if (searchQuery.isEmpty) return departments;
    final q = searchQuery.toLowerCase();
    return departments
        .where((d) =>
            d.name.toLowerCase().contains(q) ||
            d.code.toLowerCase().contains(q))
        .toList();
  }

  int get totalPages =>
      filtered.isEmpty ? 1 : (filtered.length / pageSize).ceil();

  int get clampedPage => page.clamp(1, totalPages);

  List<AdminDeptModel> get displayed =>
      filtered.skip((clampedPage - 1) * pageSize).take(pageSize).toList();

  @override
  List<Object?> get props => [departments, searchQuery, page];
}

class TicketsLoaded extends AdminState {
  final List<AdminTicketModel> tickets;
  final String? filterStatus;
  final String searchQuery;
  final int page;
  final int totalTickets;

  static const int pageSize = 20;

  TicketsLoaded(this.tickets,
      {this.filterStatus, this.searchQuery = '', this.page = 1, this.totalTickets = 0});

  int get totalPages => totalTickets == 0 ? 1 : (totalTickets / pageSize).ceil();

  int get clampedPage => page.clamp(1, totalPages);

  @override
  List<Object?> get props => [tickets, filterStatus, searchQuery, page, totalTickets];
}

class TicketDetailLoaded extends AdminState {
  final AdminTicketModel ticket;
  final List<AdminSubTicketModel> subTickets;
  final List<AdminDeptModel> departments;

  TicketDetailLoaded(this.ticket, {this.subTickets = const [], this.departments = const []});

  @override
  List<Object?> get props => [ticket, subTickets, departments];
}

class UserActivityLoaded extends AdminState {
  final List<AdminUserModel> users;
  final String filter;
  final String searchQuery;
  final int page;

  static const int pageSize = 30;

  UserActivityLoaded(this.users,
      {this.filter = 'all', this.searchQuery = '', this.page = 0});

  List<AdminUserModel> get filteredUsers {
    var result = users;
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      result = result
          .where((u) =>
              u.name.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q) ||
              (u.code?.toLowerCase().contains(q) ?? false) ||
              (u.designation?.toLowerCase().contains(q) ?? false) ||
              (u.departmentName?.toLowerCase().contains(q) ?? false) ||
              (u.companyName?.toLowerCase().contains(q) ?? false))
          .toList();
    }
    switch (filter) {
      case 'online':
        return result.where((u) => u.isOnline).toList();
      case 'loggedin':
        return result.where((u) => u.lastActive != null && !u.isOnline).toList();
      case 'never':
        return result.where((u) => u.lastActive == null).toList();
      default:
        return result;
    }
  }

  int get totalPages =>
      filteredUsers.isEmpty ? 1 : (filteredUsers.length / pageSize).ceil();

  int get clampedPage {
    final pages = totalPages;
    if (page >= pages) return (pages - 1).clamp(0, pages);
    return page;
  }

  List<AdminUserModel> get pageItems {
    final start = clampedPage * pageSize;
    if (start >= filteredUsers.length) return [];
    return filteredUsers
        .sublist(start, (start + pageSize).clamp(0, filteredUsers.length));
  }

  @override
  List<Object?> get props => [users, filter, searchQuery, page];
}

class AdminError extends AdminState {
  final String message;
  AdminError(this.message);

  @override
  List<Object?> get props => [message];
}
