import 'package:tasknest/core/constant/api_client.dart';
import 'package:tasknest/presentation/dashboard/model/ticketmodel.dart';

class TicketRemoteDataSource {
  final ApiClient _api;
  TicketRemoteDataSource(this._api);

  Future<DashboardStats> getStats() async {
    final res = await _api.get('tickets/stats');
    return DashboardStats.fromJson(res['data']);
  }

  Future<List<TicketModel>> getTickets({
    String? status,
    String? priority,
    int page = 1,
  }) async {
    final query = {
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      'page': page.toString(),
      'limit': '20',
    };
    final res = await _api.get('tickets', queryParams: query);
    return (res['data'] as List).map((e) => TicketModel.fromJson(e)).toList();
  }

  Future<TicketModel> getTicket(int id) async {
    final res = await _api.get('tickets/$id');
    return TicketModel.fromJson(res['data']);
  }

  Future<TicketModel> createTicket({
    required String title,
    required String description,
    required String priority,
    required int assignedDeptId,
    required int createdById,
    required int createdByDept,
    String? dueDate,
  }) async {
    final res = await _api.post(
      'tickets',
      body: {
        'title': title,
        'description': description,
        'priority': priority,
        'assignedDeptId': assignedDeptId,
        'createdById': createdById, // Explicitly adding this
        'createdByDept': createdByDept, // Explicitly adding this
        if (dueDate != null) 'dueDate': dueDate,
      },
    );

    return TicketModel.fromJson(res['data']);
  }

  Future<TicketModel> updateStatus(int id, String status) async {
    final res = await _api.patch(
      'tickets/$id/status',
      body: {'status': status},
    );
    return TicketModel.fromJson(res['data']);
  }

  Future<TicketModel> selfAssign(int id) async {
    final res = await _api.patch('tickets/$id/self-assign', body: {});
    return TicketModel.fromJson(res['data']);
  }

  Future<TicketModel> assignToEmployee(int ticketId, int employeeId) async {
    final res = await _api.patch(
      'tickets/$ticketId/assign',
      body: {'employeeId': employeeId},
    );
    return TicketModel.fromJson(res['data']);
  }

  Future<TicketModel> transferTicket(int ticketId, int targetDeptId) async {
    final res = await _api.patch(
      'tickets/$ticketId/transfer',
      body: {'targetDeptId': targetDeptId},
    );
    return TicketModel.fromJson(res['data']);
  }

  Future<TicketModel> reopenTicket(int id) async {
    final res = await _api.patch('tickets/$id/reopen', body: {});
    return TicketModel.fromJson(res['data']);
  }

  Future<List<DepartmentModel>> getDepartments() async {
    final res = await _api.get('tickets/departments');
    final data = res['data'];
    if (data is List) {
      return data.map((e) => DepartmentModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<EmployeeModel>> getEmployees({int? departmentId}) async {
    final query = {
      if (departmentId != null) 'departmentId': departmentId.toString(),
    };
    final res = await _api.get('tickets/employees', queryParams: query);
    final data = res['data'];
    if (data is List) {
      return data.map((e) => EmployeeModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<TicketModel>> getSentTickets() async {
    final res = await _api.get('tickets/sent-tickets');
    final data = res['data'];
    if (data is List) {
      return data.map((e) => TicketModel.fromJson(e)).toList();
    }
    return [];
  }

  /// Analytics endpoints
  Future<DashboardStats> getDepartmentAnalytics(int departmentId) async {
    final res = await _api.get('tickets/analytics/department/$departmentId');
    return DashboardStats.fromJson(res['data']);
  }

  Future<List<dynamic>> getOrganizationAnalytics() async {
    final res = await _api.get('tickets/analytics/by-department');
    return res['data'] ?? [];
  }
}
