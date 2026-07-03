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

class UsersLoaded extends AdminState {
  final List<AdminUserModel> users;
  UsersLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class DepartmentsLoaded extends AdminState {
  final List<AdminDeptModel> departments;
  DepartmentsLoaded(this.departments);

  @override
  List<Object?> get props => [departments];
}

class TicketsLoaded extends AdminState {
  final List<AdminTicketModel> tickets;
  final String? filterStatus;
  TicketsLoaded(this.tickets, {this.filterStatus});

  @override
  List<Object?> get props => [tickets, filterStatus];
}

class PendingUsersLoaded extends AdminState {
  final List<AdminUserModel> users;
  PendingUsersLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class UserActivityLoaded extends AdminState {
  final List<AdminUserModel> users;
  UserActivityLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class AdminError extends AdminState {
  final String message;
  AdminError(this.message);

  @override
  List<Object?> get props => [message];
}
