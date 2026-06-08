import 'package:tasknest/core/constant/api_client.dart';
import 'package:tasknest/presentation/dashboard/model/ticketmodel.dart';

class TicketRemoteDataSource {
  final ApiClient _api;
  TicketRemoteDataSource(this._api);

  Future<DashboardStats> getStats() async {
    final res = await _api.get('tickets/stats');
    return DashboardStats.fromJson(res['data']);
  }

  Future<({List<TicketModel> tickets, int total, int page, int totalPages})> getTickets({
    String? status,
    String? priority,
    int page = 1,
  }) async {
    final query = {
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      'page': page.toString(),
      'limit': '15',
    };
    final res = await _api.get('tickets', queryParams: query);
    final data = (res['data'] as List).map((e) => TicketModel.fromJson(e)).toList();
    final pagination = res['pagination'] as Map<String, dynamic>?;
    final total = pagination?['total'] as int? ?? data.length;
    final totalPages = pagination?['totalPages'] as int? ?? 1;
    final currentPage = pagination?['page'] as int? ?? page;
    return (tickets: data, total: total, page: currentPage, totalPages: totalPages);
  }

  Future<TicketModel> getTicket(int id) async {
    final res = await _api.get('tickets/$id');
    return TicketModel.fromJson(res['data']);
  }

  Future<TicketModel> createTicket({
    required String title,
    required String description,
    required String priority,
    required List<int> departmentIds,
    required int createdById,
    required int createdByDept,
    int? assignedToId,
    String? dueDate,
    int? parentTicketId,
    bool selfAssign = false,
    String? subTitle,
    String? subDescription,
    List<Map<String, dynamic>>? deptTickets,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'description': description,
      'priority': priority,
      'departmentIds': departmentIds,
      'createdById': createdById,
      'createdByDept': createdByDept,
      'selfAssign': selfAssign,
    };
    if (assignedToId != null) body['assignedToId'] = assignedToId;
    if (dueDate != null) body['dueDate'] = dueDate;
    if (parentTicketId != null) body['parentTicketId'] = parentTicketId;
    if (subTitle != null) body['subTitle'] = subTitle;
    if (subDescription != null) body['subDescription'] = subDescription;
    if (deptTickets != null) body['deptTickets'] = deptTickets;

    final res = await _api.post('tickets', body: body);

    return TicketModel.fromJson(res['data']);
  }

  Future<TicketModel> updateStatus(
    int id,
    String status, {
    String? remark,
  }) async {
    final res = await _api.patch(
      'tickets/$id/status',
      body: {
        'status': status,
        if (remark != null && remark.trim().isNotEmpty) 'remark': remark.trim(),
      },
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

  Future<TicketModel> transferTicket(int ticketId, int targetDeptId, {String? title, String? description}) async {
    final body = <String, dynamic>{'targetDeptId': targetDeptId};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    final res = await _api.patch(
      'tickets/$ticketId/transfer',
      body: body,
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
    final res = await _api.get(
      'tickets/analytics/organization',
    ); // Changed endpoint to be more specific
    return res['data'] ?? [];
  }

  Future<TicketModel> createSubTicket({
    required String title,
    required String description,
    required String priority,
    required List<Map<String, dynamic>> departments,
    String? dueDate,
    int? parentTicketId,
  }) async {
    final res = await _api.post(
      'tickets/sub-tickets',
      body: {
        'title': title,
        'description': description,
        'priority': priority,
        'departments': departments,
        if (dueDate != null) 'dueDate': dueDate,
        if (parentTicketId != null) 'parentTicketId': parentTicketId,
      },
    );
    return TicketModel.fromJson(res['data']);
  }

  Future<TicketModel> updateSubDeptProgress({
    required int ticketId,
    required int departmentId,
    String? status,
    String? note,
  }) async {
    final res = await _api.patch(
      'tickets/$ticketId/sub-departments/$departmentId',
      body: {
        if (status != null) 'status': status,
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      },
    );
    return TicketModel.fromJson(res['data']);
  }

  Future<TicketModel> selfAssignSubDept(int ticketId, int departmentId) async {
    final res = await _api.patch(
      'tickets/$ticketId/sub-departments/$departmentId/self-assign',
      body: {},
    );
    return TicketModel.fromJson(res['data']);
  }

  Future<TicketModel> assignSubDeptToEmployee({
    required int ticketId,
    required int departmentId,
    required int employeeId,
  }) async {
    final res = await _api.patch(
      'tickets/$ticketId/sub-departments/$departmentId/assign',
      body: {'employeeId': employeeId},
    );
    return TicketModel.fromJson(res['data']);
  }

  Future<TicketModel> completeSubTicket(int ticketId) async {
    final res = await _api.post('tickets/$ticketId/complete', body: {});
    return TicketModel.fromJson(res['data']);
  }

  Future<TicketModel> reopenSubDept(int ticketId, int departmentId) async {
    final res = await _api.patch(
      'tickets/$ticketId/sub-departments/$departmentId/reopen',
      body: {},
    );
    return TicketModel.fromJson(res['data']);
  }

  Future<void> addComment(int ticketId, String message) async {
    await _api.post('tickets/$ticketId/comments', body: {'message': message});
  }
}
