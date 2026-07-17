import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasknest/core/constant/const_strings.dart';
import 'package:tasknest/presentation/admin/data/models/admin_models.dart';
import 'package:tasknest/presentation/admin/domain/repositories_impl/admin_repository_impl.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_event.dart';
import 'package:tasknest/presentation/admin/presentation/bloc/admin_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepositoryImpl _repo;

  String _deptSearchQuery = '';
  int _deptPage = 1;

  String _ticketSearchQuery = '';
  String? _ticketStatusFilter;

  int _usersSelectedTab = 0;
  String _usersSearchQuery = '';
  bool _usersShowMissingCodeOnly = false;
  int _usersPage = 0;

  String _activityFilter = 'all';
  String _activitySearchQuery = '';
  int _activityPage = 0;

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
    on<UpdateDeptSearchQuery>(_onUpdateDeptSearch);
    on<UpdateDeptPage>(_onUpdateDeptPage);
    on<UpdateTicketSearchQuery>(_onUpdateTicketSearch);
    on<UpdateTicketStatusFilter>(_onUpdateTicketStatusFilter);
    on<UpdateUsersTab>(_onUpdateUsersTab);
    on<UpdateUsersSearchQuery>(_onUpdateUsersSearch);
    on<UpdateUsersShowMissingCode>(_onUpdateUsersMissingCode);
    on<UpdateUsersPage>(_onUpdateUsersPage);
    on<UpdateActivityFilter>(_onUpdateActivityFilter);
    on<UpdateActivitySearchQuery>(_onUpdateActivitySearch);
    on<UpdateActivityPage>(_onUpdateActivityPage);
  }

  void _emitError(Emitter<AdminState> e, dynamic err) {
    e(AdminError(err is Exception
        ? err.toString().replaceFirst('Exception: ', '')
        : 'An error occurred'));
  }

  Future<void> _onLoadDashboard(
      LoadAdminDashboard event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final stats = await _repo.getStats();
      emit(AdminDashboardLoaded(stats));
    } catch (err) {
      _emitError(emit, err);
    }
  }

  Future<void> _onLoadUsers(
      LoadUsers event, Emitter<AdminState> emit) async {
    final prevPending = (state is UsersScreenState)
        ? (state as UsersScreenState).pendingUsers
        : <AdminUserModel>[];
    emit(AdminLoading());
    try {
      final users = await _repo.getUsers();
      emit(UsersScreenState(
        allUsers: users,
        pendingUsers: prevPending,
        selectedTab: _usersSelectedTab,
        searchQuery: _usersSearchQuery,
        showMissingCodeOnly: _usersShowMissingCodeOnly,
        page: _usersPage,
      ));
    } catch (err) {
      _emitError(emit, err);
    }
  }

  Future<void> _onCreateUser(
      CreateUser event, Emitter<AdminState> emit) async {
    try {
      await _repo.createUser(event.body);
      if (event.context.mounted) {
        ScaffoldMessenger.of(event.context).showSnackBar(
          const SnackBar(content: Text(ConstStrings.userCreatedSuccess)),
        );
      }
      add(LoadUsers());
    } catch (err) {
      _emitError(emit, err);
    }
  }

  Future<void> _onUpdateUser(
      UpdateUser event, Emitter<AdminState> emit) async {
    try {
      await _repo.updateUser(event.id, event.body);
      if (event.context.mounted) {
        ScaffoldMessenger.of(event.context).showSnackBar(
          const SnackBar(content: Text(ConstStrings.userUpdatedSuccess)),
        );
      }
      add(LoadUsers());
    } catch (err) {
      _emitError(emit, err);
    }
  }

  Future<void> _onDeleteUser(
      DeleteUser event, Emitter<AdminState> emit) async {
    try {
      await _repo.deleteUser(event.id);
      if (event.context.mounted) {
        ScaffoldMessenger.of(event.context).showSnackBar(
          const SnackBar(content: Text(ConstStrings.userDeactivatedSuccess)),
        );
      }
      add(LoadUsers());
    } catch (err) {
      _emitError(emit, err);
    }
  }

  Future<void> _onLoadUserActivity(
      LoadUserActivity event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final users = await _repo.getUserActivity();
      emit(UserActivityLoaded(users,
          filter: _activityFilter,
          searchQuery: _activitySearchQuery,
          page: _activityPage));
    } catch (err) {
      _emitError(emit, err);
    }
  }

  Future<void> _onLoadPendingUsers(
      LoadPendingUsers event, Emitter<AdminState> emit) async {
    final prevAll = (state is UsersScreenState)
        ? (state as UsersScreenState).allUsers
        : <AdminUserModel>[];
    emit(AdminLoading());
    try {
      final users = await _repo.getPendingUsers();
      emit(UsersScreenState(
        allUsers: prevAll,
        pendingUsers: users,
        selectedTab: _usersSelectedTab,
        searchQuery: _usersSearchQuery,
        showMissingCodeOnly: _usersShowMissingCodeOnly,
        page: _usersPage,
      ));
    } catch (err) {
      _emitError(emit, err);
    }
  }

  Future<void> _onApproveUser(
      ApproveUser event, Emitter<AdminState> emit) async {
    try {
      await _repo.approveUser(event.id);
      if (event.context.mounted) {
        ScaffoldMessenger.of(event.context).showSnackBar(
          const SnackBar(content: Text(ConstStrings.userApprovedSuccess)),
        );
      }
      add(LoadPendingUsers());
      add(LoadUsers());
    } catch (err) {
      _emitError(emit, err);
    }
  }

  Future<void> _onLoadDepartments(
      LoadDepartments event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final depts = await _repo.getDepartments();
      emit(DepartmentsLoaded(depts,
          searchQuery: _deptSearchQuery, page: _deptPage));
    } catch (err) {
      _emitError(emit, err);
    }
  }

  Future<void> _onCreateDept(
      CreateDepartment event, Emitter<AdminState> emit) async {
    try {
      await _repo.createDept(event.body);
      if (event.context.mounted) {
        ScaffoldMessenger.of(event.context).showSnackBar(
          const SnackBar(content: Text(ConstStrings.deptCreatedSuccess)),
        );
      }
      add(LoadDepartments());
    } catch (err) {
      _emitError(emit, err);
    }
  }

  Future<void> _onUpdateDept(
      UpdateDepartment event, Emitter<AdminState> emit) async {
    try {
      await _repo.updateDept(event.id, event.body);
      if (event.context.mounted) {
        ScaffoldMessenger.of(event.context).showSnackBar(
          const SnackBar(content: Text(ConstStrings.deptUpdatedSuccess)),
        );
      }
      add(LoadDepartments());
    } catch (err) {
      _emitError(emit, err);
    }
  }

  Future<void> _onDeleteDept(
      DeleteDepartment event, Emitter<AdminState> emit) async {
    try {
      await _repo.deleteDept(event.id);
      if (event.context.mounted) {
        ScaffoldMessenger.of(event.context).showSnackBar(
          const SnackBar(content: Text(ConstStrings.deptDeletedSuccess)),
        );
      }
      add(LoadDepartments());
    } catch (err) {
      _emitError(emit, err);
    }
  }

  Future<void> _onLoadTickets(
      LoadTickets event, Emitter<AdminState> emit) async {
    _ticketStatusFilter = event.status;
    emit(AdminLoading());
    try {
      final tickets = await _repo.getTickets(status: event.status);
      emit(TicketsLoaded(tickets,
          filterStatus: event.status, searchQuery: _ticketSearchQuery));
    } catch (err) {
      _emitError(emit, err);
    }
  }

  Future<void> _onDeleteTicket(
      DeleteTicket event, Emitter<AdminState> emit) async {
    try {
      await _repo.deleteTicket(event.id);
      if (event.context.mounted) {
        ScaffoldMessenger.of(event.context).showSnackBar(
          const SnackBar(content: Text(ConstStrings.ticketDeletedSuccess)),
        );
      }
      add(LoadTickets(status: _ticketStatusFilter));
    } catch (err) {
      _emitError(emit, err);
    }
  }

  void _onUpdateDeptSearch(
      UpdateDeptSearchQuery event, Emitter<AdminState> emit) {
    _deptSearchQuery = event.query;
    _deptPage = 1;
    if (state is DepartmentsLoaded) {
      emit(DepartmentsLoaded((state as DepartmentsLoaded).departments,
          searchQuery: _deptSearchQuery, page: _deptPage));
    }
  }

  void _onUpdateDeptPage(UpdateDeptPage event, Emitter<AdminState> emit) {
    _deptPage = event.page;
    if (state is DepartmentsLoaded) {
      emit(DepartmentsLoaded((state as DepartmentsLoaded).departments,
          searchQuery: _deptSearchQuery, page: _deptPage));
    }
  }

  void _onUpdateTicketSearch(
      UpdateTicketSearchQuery event, Emitter<AdminState> emit) {
    _ticketSearchQuery = event.query;
    if (state is TicketsLoaded) {
      final s = state as TicketsLoaded;
      emit(TicketsLoaded(s.tickets,
          filterStatus: s.filterStatus, searchQuery: _ticketSearchQuery));
    }
  }

  Future<void> _onUpdateTicketStatusFilter(
      UpdateTicketStatusFilter event, Emitter<AdminState> emit) async {
    _ticketStatusFilter = event.status;
    emit(AdminLoading());
    try {
      final tickets = await _repo.getTickets(status: event.status);
      emit(TicketsLoaded(tickets,
          filterStatus: event.status, searchQuery: _ticketSearchQuery));
    } catch (err) {
      _emitError(emit, err);
    }
  }

  void _onUpdateUsersTab(UpdateUsersTab event, Emitter<AdminState> emit) {
    _usersSelectedTab = event.tab;
    _usersPage = 0;
    if (state is UsersScreenState) {
      final s = state as UsersScreenState;
      emit(UsersScreenState(
        allUsers: s.allUsers,
        pendingUsers: s.pendingUsers,
        selectedTab: _usersSelectedTab,
        searchQuery: _usersSearchQuery,
        showMissingCodeOnly: _usersShowMissingCodeOnly,
        page: _usersPage,
      ));
    }
  }

  void _onUpdateUsersSearch(
      UpdateUsersSearchQuery event, Emitter<AdminState> emit) {
    _usersSearchQuery = event.query;
    _usersPage = 0;
    if (state is UsersScreenState) {
      final s = state as UsersScreenState;
      emit(UsersScreenState(
        allUsers: s.allUsers,
        pendingUsers: s.pendingUsers,
        selectedTab: _usersSelectedTab,
        searchQuery: _usersSearchQuery,
        showMissingCodeOnly: _usersShowMissingCodeOnly,
        page: _usersPage,
      ));
    }
  }

  void _onUpdateUsersMissingCode(
      UpdateUsersShowMissingCode event, Emitter<AdminState> emit) {
    _usersShowMissingCodeOnly = event.show;
    _usersPage = 0;
    if (state is UsersScreenState) {
      final s = state as UsersScreenState;
      emit(UsersScreenState(
        allUsers: s.allUsers,
        pendingUsers: s.pendingUsers,
        selectedTab: _usersSelectedTab,
        searchQuery: _usersSearchQuery,
        showMissingCodeOnly: _usersShowMissingCodeOnly,
        page: _usersPage,
      ));
    }
  }

  void _onUpdateUsersPage(UpdateUsersPage event, Emitter<AdminState> emit) {
    _usersPage = event.page;
    if (state is UsersScreenState) {
      final s = state as UsersScreenState;
      emit(UsersScreenState(
        allUsers: s.allUsers,
        pendingUsers: s.pendingUsers,
        selectedTab: _usersSelectedTab,
        searchQuery: _usersSearchQuery,
        showMissingCodeOnly: _usersShowMissingCodeOnly,
        page: _usersPage,
      ));
    }
  }

  void _onUpdateActivityFilter(
      UpdateActivityFilter event, Emitter<AdminState> emit) {
    _activityFilter = event.filter;
    _activityPage = 0;
    if (state is UserActivityLoaded) {
      final s = state as UserActivityLoaded;
      emit(UserActivityLoaded(s.users,
          filter: _activityFilter,
          searchQuery: _activitySearchQuery,
          page: _activityPage));
    }
  }

  void _onUpdateActivitySearch(
      UpdateActivitySearchQuery event, Emitter<AdminState> emit) {
    _activitySearchQuery = event.query;
    _activityPage = 0;
    if (state is UserActivityLoaded) {
      final s = state as UserActivityLoaded;
      emit(UserActivityLoaded(s.users,
          filter: _activityFilter,
          searchQuery: _activitySearchQuery,
          page: _activityPage));
    }
  }

  void _onUpdateActivityPage(
      UpdateActivityPage event, Emitter<AdminState> emit) {
    _activityPage = event.page;
    if (state is UserActivityLoaded) {
      final s = state as UserActivityLoaded;
      emit(UserActivityLoaded(s.users,
          filter: _activityFilter,
          searchQuery: _activitySearchQuery,
          page: _activityPage));
    }
  }
}
