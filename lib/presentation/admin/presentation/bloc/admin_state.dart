import 'package:tasknest/presentation/admin/data/models/admin_models.dart';

abstract class AdminState {}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminDashboardLoaded extends AdminState {
  final AdminStats stats;
  AdminDashboardLoaded(this.stats);
}

class UsersLoaded extends AdminState {
  final List<AdminUserModel> users;
  UsersLoaded(this.users);
}

class DepartmentsLoaded extends AdminState {
  final List<AdminDeptModel> departments;
  DepartmentsLoaded(this.departments);
}

class TicketsLoaded extends AdminState {
  final List<AdminTicketModel> tickets;
  final String? filterStatus;
  TicketsLoaded(this.tickets, {this.filterStatus});
}

class PendingUsersLoaded extends AdminState {
  final List<AdminUserModel> users;
  PendingUsersLoaded(this.users);
}

class UserActivityLoaded extends AdminState {
  final List<AdminUserModel> users;
  UserActivityLoaded(this.users);
}

class AdminError extends AdminState {
  final String message;
  AdminError(this.message);
}
