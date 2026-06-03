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
    int? assignedToId, // Added assignedToId
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
        if (assignedToId != null)
          'assignedToId': assignedToId, // Send assignedToId if present
        if (dueDate != null) 'dueDate': dueDate,
      },
    );

    return TicketModel.fromJson(res['data']);
  }

  Future<TicketModel> updateStatus(int id, String status, {String? remark}) async {
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
    final res = await _api.get(
      'tickets/analytics/organization',
    ); // Changed endpoint to be more specific
    return res['data'] ?? [];
  }

  Future<TicketModel> createMultiDeptSubTicket({
    required String title,
    required String description,
    required String priority,
    required List<Map<String, dynamic>> departments,
    String? dueDate,
  }) async {
    final res = await _api.post(
      'tickets/sub-tickets',
      body: {
        'title': title,
        'description': description,
        'priority': priority,
        'departments': departments,
        if (dueDate != null) 'dueDate': dueDate,
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

  // ── Standard Tickets ──────────────────────────────────────────────────

  Future<List<TicketModel>> getStandardTickets() async {
    final res = await _api.get('tickets/standard-tickets');
    return (res['data'] as List).map((e) => TicketModel.fromJson(e)).toList();
  }

  Future<TicketModel> createStandardTicket({
    required String title,
    required String description,
    required String priority,
    required List<int> departmentIds,
    String? dueDate,
  }) async {
    final res = await _api.post('tickets/standard-tickets', body: {
      'title': title,
      'description': description,
      'priority': priority,
      'departmentIds': departmentIds,
      if (dueDate != null) 'dueDate': dueDate,
    });
    return TicketModel.fromJson(res['data']);
  }

  // ── Multi Tickets ─────────────────────────────────────────────────────

  Future<TicketModel> createMultiTicket({
    required String title,
    required String description,
    required String priority,
    required List<int> departmentIds,
    String? dueDate,
  }) async {
    final res = await _api.post('tickets/multi-tickets', body: {
      'title': title,
      'description': description,
      'priority': priority,
      'departmentIds': departmentIds,
      if (dueDate != null) 'dueDate': dueDate,
    });
    return TicketModel.fromJson(res['data']);
  }

  // ── V2 Flow Actions ───────────────────────────────────────────────────

  Future<TicketModel> markComplete(int ticketId, String label) async {
    final res = await _api.patch('tickets/$ticketId/mark-complete', body: {
      'label': label,
    });
    return TicketModel.fromJson(res['data']);
  }

  Future<TicketModel> closeTicket(int ticketId) async {
    final res = await _api.patch('tickets/$ticketId/close', body: {});
    return TicketModel.fromJson(res['data']);
  }

  Future<TicketModel> createSubTicket({
    required int parentId,
    required String title,
    required String description,
    required String priority,
    int? targetDeptId,
    int? assignedToId,
    String? dueDate,
  }) async {
    final res = await _api.post('tickets/$parentId/sub-tickets', body: {
      'title': title,
      'description': description,
      'priority': priority,
      if (targetDeptId != null) 'targetDeptId': targetDeptId,
      if (assignedToId != null) 'assignedToId': assignedToId,
      if (dueDate != null) 'dueDate': dueDate,
    });
    return TicketModel.fromJson(res['data']);
  }

  Future<List<TicketModel>> getChildTickets(int ticketId) async {
    final res = await _api.get('tickets/$ticketId/children');
    if (res['data'] is List) {
      return (res['data'] as List).map((e) => TicketModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<dynamic>> getDescendants(int ticketId) async {
    final res = await _api.get('tickets/$ticketId/descendants');
    if (res['data'] is List) return res['data'];
    return [];
  }
}
