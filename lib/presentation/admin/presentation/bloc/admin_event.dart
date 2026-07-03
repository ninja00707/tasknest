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
