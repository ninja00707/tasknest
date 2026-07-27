import 'package:tasknest/presentation/admin/data/models/admin_models.dart';

abstract class AdminRepository {
  Future<AdminStats> getStats();
  Future<List<AdminUserModel>> getUsers();
  Future<List<AdminUserModel>> getPendingUsers();
  Future<AdminUserModel> createUser(Map<String, dynamic> body);
  Future<AdminUserModel> updateUser(int id, Map<String, dynamic> body);
  Future<void> approveUser(int id);
  Future<void> deleteUser(int id);
  Future<List<AdminUserModel>> getUserActivity();
  Future<List<AdminDeptModel>> getDepartments();
  Future<AdminDeptModel> createDept(Map<String, dynamic> body);
  Future<AdminDeptModel> updateDept(int id, Map<String, dynamic> body);
  Future<void> deleteDept(int id);
  Future<Map<String, dynamic>> getTicketsWithTotal({String? status, String? search, int page, int limit});
  Future<AdminTicketModel> getTicketDetail(int id);
  Future<AdminTicketModel> updateTicket(int id, Map<String, dynamic> body);
  Future<List<AdminSubTicketModel>> getSubTickets(int parentId);
  Future<void> deleteTicket(int id);
}
