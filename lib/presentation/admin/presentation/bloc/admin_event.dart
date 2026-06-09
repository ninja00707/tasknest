import 'package:flutter/material.dart';

abstract class AdminEvent {}

class LoadAdminDashboard extends AdminEvent {}

class LoadUsers extends AdminEvent {}

class CreateUser extends AdminEvent {
  final Map<String, dynamic> body;
  final BuildContext context;
  CreateUser(this.body, this.context);
}

class UpdateUser extends AdminEvent {
  final int id;
  final Map<String, dynamic> body;
  final BuildContext context;
  UpdateUser(this.id, this.body, this.context);
}

class DeleteUser extends AdminEvent {
  final int id;
  final BuildContext context;
  DeleteUser(this.id, this.context);
}

class LoadPendingUsers extends AdminEvent {}

class ApproveUser extends AdminEvent {
  final int id;
  final BuildContext context;
  ApproveUser(this.id, this.context);
}

class LoadDepartments extends AdminEvent {}

class CreateDepartment extends AdminEvent {
  final Map<String, dynamic> body;
  final BuildContext context;
  CreateDepartment(this.body, this.context);
}

class UpdateDepartment extends AdminEvent {
  final int id;
  final Map<String, dynamic> body;
  final BuildContext context;
  UpdateDepartment(this.id, this.body, this.context);
}

class DeleteDepartment extends AdminEvent {
  final int id;
  final BuildContext context;
  DeleteDepartment(this.id, this.context);
}

class LoadTickets extends AdminEvent {
  final String? status;
  LoadTickets({this.status});
}

class DeleteTicket extends AdminEvent {
  final int id;
  final BuildContext context;
  DeleteTicket(this.id, this.context);
}
