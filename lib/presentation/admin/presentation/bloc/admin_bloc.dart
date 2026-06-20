import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/presentation/admin/domain/repositories/admin_repository.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_event.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository _repo;
  AdminBloc(this._repo) : super(AdminInitial()) {
    on<LoadAdminDashboard>(_onLoadDashboard);
    on<LoadUsers>(_onLoadUsers);
    on<CreateUser>(_onCreateUser);
    on<UpdateUser>(_onUpdateUser);
    on<DeleteUser>(_onDeleteUser);
    on<LoadPendingUsers>(_onLoadPendingUsers);
    on<LoadUserActivity>(_onLoadUserActivity);
    on<ApproveUser>(_onApproveUser);
    on<LoadDepartments>(_onLoadDepartments);
    on<CreateDepartment>(_onCreateDept);
    on<UpdateDepartment>(_onUpdateDept);
    on<DeleteDepartment>(_onDeleteDept);
    on<LoadTickets>(_onLoadTickets);
    on<DeleteTicket>(_onDeleteTicket);
  }

  void _emitError(Emitter<AdminState> e, dynamic err) {
    e(AdminError(err is Exception ? err.toString().replaceFirst('Exception: ', '') : 'An error occurred'));
  }

  Future<void> _onLoadDashboard(LoadAdminDashboard event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final stats = await _repo.getStats();
      emit(AdminDashboardLoaded(stats));
    } catch (err) { _emitError(emit, err); }
  }

  Future<void> _onLoadUsers(LoadUsers event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final users = await _repo.getUsers();
      emit(UsersLoaded(users));
    } catch (err) { _emitError(emit, err); }
  }

  Future<void> _onCreateUser(CreateUser event, Emitter<AdminState> emit) async {
    try {
      await _repo.createUser(event.body);
      if (event.context.mounted) {
        ScaffoldMessenger.of(event.context).showSnackBar(
          const SnackBar(content: Text('User created successfully')),
        );
      }
      add(LoadUsers());
    } catch (err) { _emitError(emit, err); }
  }

  Future<void> _onUpdateUser(UpdateUser event, Emitter<AdminState> emit) async {
    try {
      await _repo.updateUser(event.id, event.body);
      if (event.context.mounted) {
        ScaffoldMessenger.of(event.context).showSnackBar(
          const SnackBar(content: Text('User updated successfully')),
        );
      }
      add(LoadUsers());
    } catch (err) { _emitError(emit, err); }
  }

  Future<void> _onDeleteUser(DeleteUser event, Emitter<AdminState> emit) async {
    try {
      await _repo.deleteUser(event.id);
      if (event.context.mounted) {
        ScaffoldMessenger.of(event.context).showSnackBar(
          const SnackBar(content: Text('User deactivated successfully')),
        );
      }
      add(LoadUsers());
    } catch (err) { _emitError(emit, err); }
  }

  Future<void> _onLoadUserActivity(LoadUserActivity event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final users = await _repo.getUserActivity();
      emit(UserActivityLoaded(users));
    } catch (err) { _emitError(emit, err); }
  }

  Future<void> _onLoadPendingUsers(LoadPendingUsers event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final users = await _repo.getPendingUsers();
      emit(PendingUsersLoaded(users));
    } catch (err) { _emitError(emit, err); }
  }

  Future<void> _onApproveUser(ApproveUser event, Emitter<AdminState> emit) async {
    try {
      await _repo.approveUser(event.id);
      if (event.context.mounted) {
        ScaffoldMessenger.of(event.context).showSnackBar(
          const SnackBar(content: Text('User approved successfully')),
        );
      }
      add(LoadPendingUsers());
      add(LoadUsers());
    } catch (err) { _emitError(emit, err); }
  }

  Future<void> _onLoadDepartments(LoadDepartments event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final depts = await _repo.getDepartments();
      emit(DepartmentsLoaded(depts));
    } catch (err) { _emitError(emit, err); }
  }

  Future<void> _onCreateDept(CreateDepartment event, Emitter<AdminState> emit) async {
    try {
      await _repo.createDept(event.body);
      if (event.context.mounted) {
        ScaffoldMessenger.of(event.context).showSnackBar(
          const SnackBar(content: Text('Department created successfully')),
        );
      }
      add(LoadDepartments());
    } catch (err) { _emitError(emit, err); }
  }

  Future<void> _onUpdateDept(UpdateDepartment event, Emitter<AdminState> emit) async {
    try {
      await _repo.updateDept(event.id, event.body);
      if (event.context.mounted) {
        ScaffoldMessenger.of(event.context).showSnackBar(
          const SnackBar(content: Text('Department updated successfully')),
        );
      }
      add(LoadDepartments());
    } catch (err) { _emitError(emit, err); }
  }

  Future<void> _onDeleteDept(DeleteDepartment event, Emitter<AdminState> emit) async {
    try {
      await _repo.deleteDept(event.id);
      if (event.context.mounted) {
        ScaffoldMessenger.of(event.context).showSnackBar(
          const SnackBar(content: Text('Department deleted successfully')),
        );
      }
      add(LoadDepartments());
    } catch (err) { _emitError(emit, err); }
  }

  Future<void> _onLoadTickets(LoadTickets event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final tickets = await _repo.getTickets(status: event.status);
      emit(TicketsLoaded(tickets, filterStatus: event.status));
    } catch (err) { _emitError(emit, err); }
  }

  Future<void> _onDeleteTicket(DeleteTicket event, Emitter<AdminState> emit) async {
    try {
      await _repo.deleteTicket(event.id);
      if (event.context.mounted) {
        ScaffoldMessenger.of(event.context).showSnackBar(
          const SnackBar(content: Text('Ticket deleted successfully')),
        );
      }
      add(LoadTickets(status: state is TicketsLoaded ? (state as TicketsLoaded).filterStatus : null));
    } catch (err) { _emitError(emit, err); }
  }
}
