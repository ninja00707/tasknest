import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class AdminEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAdminDashboard extends AdminEvent {}

class LoadUsers extends AdminEvent {}

class CreateUser extends AdminEvent {
  final Map<String, dynamic> body;
  final BuildContext context;
  CreateUser(this.body, this.context);

  @override
  List<Object?> get props => [body, context];
}

class UpdateUser extends AdminEvent {
  final int id;
  final Map<String, dynamic> body;
  final BuildContext context;
  UpdateUser(this.id, this.body, this.context);

  @override
  List<Object?> get props => [id, body, context];
}

class DeleteUser extends AdminEvent {
  final int id;
  final BuildContext context;
  DeleteUser(this.id, this.context);

  @override
  List<Object?> get props => [id, context];
}

class LoadPendingUsers extends AdminEvent {}

class LoadUserActivity extends AdminEvent {}

class ApproveUser extends AdminEvent {
  final int id;
  final BuildContext context;
  ApproveUser(this.id, this.context);

  @override
  List<Object?> get props => [id, context];
}

class LoadDepartments extends AdminEvent {}

class CreateDepartment extends AdminEvent {
  final Map<String, dynamic> body;
  final BuildContext context;
  CreateDepartment(this.body, this.context);

  @override
  List<Object?> get props => [body, context];
}

class UpdateDepartment extends AdminEvent {
  final int id;
  final Map<String, dynamic> body;
  final BuildContext context;
  UpdateDepartment(this.id, this.body, this.context);

  @override
  List<Object?> get props => [id, body, context];
}

class DeleteDepartment extends AdminEvent {
  final int id;
  final BuildContext context;
  DeleteDepartment(this.id, this.context);

  @override
  List<Object?> get props => [id, context];
}

class LoadTickets extends AdminEvent {
  final String? status;
  LoadTickets({this.status});

  @override
  List<Object?> get props => [status];
}

class DeleteTicket extends AdminEvent {
  final int id;
  final BuildContext context;
  DeleteTicket(this.id, this.context);

  @override
  List<Object?> get props => [id, context];
}

class UpdateDeptSearchQuery extends AdminEvent {
  final String query;
  UpdateDeptSearchQuery(this.query);

  @override
  List<Object?> get props => [query];
}

class UpdateDeptPage extends AdminEvent {
  final int page;
  UpdateDeptPage(this.page);

  @override
  List<Object?> get props => [page];
}

class UpdateTicketSearchQuery extends AdminEvent {
  final String query;
  UpdateTicketSearchQuery(this.query);

  @override
  List<Object?> get props => [query];
}

class UpdateTicketStatusFilter extends AdminEvent {
  final String? status;
  UpdateTicketStatusFilter(this.status);

  @override
  List<Object?> get props => [status];
}

class UpdateUsersTab extends AdminEvent {
  final int tab;
  UpdateUsersTab(this.tab);

  @override
  List<Object?> get props => [tab];
}

class UpdateUsersSearchQuery extends AdminEvent {
  final String query;
  UpdateUsersSearchQuery(this.query);

  @override
  List<Object?> get props => [query];
}

class UpdateUsersShowMissingCode extends AdminEvent {
  final bool show;
  UpdateUsersShowMissingCode(this.show);

  @override
  List<Object?> get props => [show];
}

class UpdateUsersPage extends AdminEvent {
  final int page;
  UpdateUsersPage(this.page);

  @override
  List<Object?> get props => [page];
}

class UpdateActivityFilter extends AdminEvent {
  final String filter;
  UpdateActivityFilter(this.filter);

  @override
  List<Object?> get props => [filter];
}

class UpdateActivitySearchQuery extends AdminEvent {
  final String query;
  UpdateActivitySearchQuery(this.query);

  @override
  List<Object?> get props => [query];
}

class UpdateActivityPage extends AdminEvent {
  final int page;
  UpdateActivityPage(this.page);

  @override
  List<Object?> get props => [page];
}
