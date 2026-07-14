import 'package:tasknest/core/constant/api_client.dart';
import 'package:tasknest/presentation/admin/data/models/admin_models.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AdminRemoteDataSource {
  final ApiClient _api;
  AdminRemoteDataSource(this._api);

  Future<AdminStats> getStats() async {
    final res = await _api.get('admin/stats');
    return AdminStats.fromJson(res['data']);
  }

  // ── Users ──────────────────────────────────────────────────────────
  Future<List<AdminUserModel>> getUsers() async {
    final res = await _api.get('admin/users');
    return (res['data'] as List).map((e) => AdminUserModel.fromJson(e)).toList();
  }

  Future<List<AdminUserModel>> getPendingUsers() async {
    final res = await _api.get('admin/users/pending');
    return (res['data'] as List).map((e) => AdminUserModel.fromJson(e)).toList();
  }

  Future<AdminUserModel> getUser(int id) async {
    final res = await _api.get('admin/users/$id');
    return AdminUserModel.fromJson(res['data']);
  }

  Future<AdminUserModel> createUser(Map<String, dynamic> body) async {
    final res = await _api.post('admin/users', body: body);
    return AdminUserModel.fromJson(res['data']);
  }

  Future<AdminUserModel> updateUser(int id, Map<String, dynamic> body) async {
    final res = await _api.patch('admin/users/$id', body: body);
    return AdminUserModel.fromJson(res['data']);
  }

  Future<void> approveUser(int id) async {
    await _api.patch('admin/users/$id/approve');
  }

  Future<void> deleteUser(int id) async {
    await _api.delete('admin/users/$id');
  }

  // ── User Activity ──────────────────────────────────────────────────
  Future<List<AdminUserModel>> getUserActivity() async {
    final res = await _api.get('admin/users/activity');
    return (res['data'] as List).map((e) => AdminUserModel.fromJson(e)).toList();
  }

  // ── Departments ────────────────────────────────────────────────────
  Future<List<AdminDeptModel>> getDepartments() async {
    final res = await _api.get('admin/departments');
    return (res['data'] as List).map((e) => AdminDeptModel.fromJson(e)).toList();
  }

  Future<AdminDeptModel> createDept(Map<String, dynamic> body) async {
    final res = await _api.post('admin/departments', body: body);
    return AdminDeptModel.fromJson(res['data']);
  }

  Future<AdminDeptModel> updateDept(int id, Map<String, dynamic> body) async {
    final res = await _api.patch('admin/departments/$id', body: body);
    return AdminDeptModel.fromJson(res['data']);
  }

  Future<void> deleteDept(int id) async {
    await _api.delete('admin/departments/$id');
  }

  // ── Tickets ────────────────────────────────────────────────────────
  Future<List<AdminTicketModel>> getTickets({String? status}) async {
    final query = <String, dynamic>{};
    if (status != null) query['status'] = status;
    final res = await _api.get('admin/tickets', queryParams: query);
    return (res['data'] as List).map((e) => AdminTicketModel.fromJson(e)).toList();
  }

  Future<void> deleteTicket(int id) async {
    await _api.delete('admin/tickets/$id');
  }
}
