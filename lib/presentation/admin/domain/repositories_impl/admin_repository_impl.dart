import 'package:tasknest/presentation/admin/data/datasource/admin_remote_data_source.dart';
import 'package:tasknest/presentation/admin/data/models/admin_models.dart';
import 'package:tasknest/presentation/admin/domain/repositories/admin_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _ds;
  AdminRepositoryImpl(this._ds);

  @override
  Future<AdminStats> getStats() => _ds.getStats();

  @override
  Future<List<AdminUserModel>> getUsers() => _ds.getUsers();

  @override
  Future<List<AdminUserModel>> getPendingUsers() => _ds.getPendingUsers();

  @override
  Future<AdminUserModel> createUser(Map<String, dynamic> body) => _ds.createUser(body);

  @override
  Future<AdminUserModel> updateUser(int id, Map<String, dynamic> body) => _ds.updateUser(id, body);

  @override
  Future<void> approveUser(int id) => _ds.approveUser(id);

  @override
  Future<void> deleteUser(int id) => _ds.deleteUser(id);

  @override
  Future<List<AdminUserModel>> getUserActivity() => _ds.getUserActivity();

  @override
  Future<List<AdminDeptModel>> getDepartments() => _ds.getDepartments();

  @override
  Future<AdminDeptModel> createDept(Map<String, dynamic> body) => _ds.createDept(body);

  @override
  Future<AdminDeptModel> updateDept(int id, Map<String, dynamic> body) => _ds.updateDept(id, body);

  @override
  Future<void> deleteDept(int id) => _ds.deleteDept(id);

  @override
  Future<List<AdminTicketModel>> getTickets({String? status}) => _ds.getTickets(status: status);

  @override
  Future<void> deleteTicket(int id) => _ds.deleteTicket(id);
}
