import 'package:tasknest/core/constant/api_client.dart';
import 'package:tasknest/presentation/disputes/models/dispute_model.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
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
    String? scope,
    String? search,
  }) async {
    final query = <String, String>{
      'status': ?status,
      'priority': ?priority,
      'scope': ?scope,
      if (search != null && search.isNotEmpty) 'search': search,
      'page': page.toString(),
      'limit': '10',
    };
    final res = await _api.get('tickets', queryParams: query);
    final data = (res['data'] as List).map((e) => TicketModel.fromJson(e)).toList();
    final pagination = res['pagination'] as Map<String, dynamic>?;
    final total = int.tryParse(pagination?['total']?.toString() ?? '') ?? 0;
    final currentPage = int.tryParse(pagination?['page']?.toString() ?? '') ?? page;
    final totalPages = total > 0
        ? (total / 10).ceil()
        : (data.length >= 10 ? page + 1 : page);
    return (tickets: data, total: total, page: currentPage, totalPages: totalPages);
  }

  Future<({List<TicketModel> tickets, int total, int page, int totalPages})> filterTickets({
    String? status,
    String? priority,
    String? search,
    bool? teamOnly,
    int page = 1,
  }) async {
    final query = <String, String>{
      'status': ?status,
      'priority': ?priority,
      if (search != null && search.isNotEmpty) 'search': search,
      if (teamOnly == true) 'scope': 'team',
      'page': page.toString(),
      'limit': '10',
    };
    final res = await _api.get('tickets', queryParams: query);
    final data = (res['data'] as List).map((e) => TicketModel.fromJson(e)).toList();
    final pagination = res['pagination'] as Map<String, dynamic>?;
    final total = int.tryParse(pagination?['total']?.toString() ?? '') ?? 0;
    final currentPage = int.tryParse(pagination?['page']?.toString() ?? '') ?? page;
    final totalPages = total > 0
        ? (total / 10).ceil()
        : (data.length >= 10 ? page + 1 : page);
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
    int? projectId,
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
    if (projectId != null) body['projectId'] = projectId;

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

  Future<TicketModel> updateDescription(int id, String description) async {
    final res = await _api.patch('tickets/$id', body: {
      'description': description,
    });
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
        'dueDate': ?dueDate,
        'parentTicketId': ?parentTicketId,
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
        'status': ?status,
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

  Future<int> getUnreadCount() async {
    final res = await _api.get('notifications/unread-count');
    return res['data']['count'] as int;
  }

  Future<void> addComment(int ticketId, String message) async {
    await _api.post('tickets/$ticketId/comments', body: {'message': message});
  }

  // ── Disputes ──────────────────────────────────────────────────────────────

  /// Old manager-only flow: dispute & close a ticket with a solid argument.
  Future<TicketModel> disputeTicket(int ticketId, String argument) async {
    final res = await _api.patch(
      'tickets/$ticketId/dispute',
      body: {'argument': argument.trim()},
    );
    return TicketModel.fromJson(res['data']);
  }

  /// Full review workflow.
  Future<DisputeModel?> getDisputeByTicket(int ticketId) async {
    final res = await _api.get('tickets/$ticketId/dispute');
    final data = res['data'];
    if (data == null) return null;
    return DisputeModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<DisputeModel>> listDisputes() async {
    final res = await _api.get('tickets/disputes');
    final data = res['data'];
    if (data is List) {
      return data
          .map((e) => DisputeModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<DisputeModel> raiseDispute(
    int ticketId, {
    required String reason,
    required String description,
  }) async {
    final res = await _api.post(
      'tickets/$ticketId/dispute',
      body: {'reason': reason, 'description': description.trim()},
    );
    return DisputeModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<DisputeModel> addDisputeComment(int disputeId, String note) async {
    final res = await _api.post(
      'tickets/disputes/$disputeId/comments',
      body: {'note': note.trim()},
    );
    return DisputeModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<DisputeModel> updateDisputeStatus(
    int disputeId, {
    required String status,
    String? note,
    int? reviewerId,
  }) async {
    final res = await _api.patch(
      'tickets/disputes/$disputeId/status',
      body: {
        'status': status,
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
        'reviewerId': ?reviewerId,
      },
    );
    return DisputeModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<DisputeModel> withdrawDispute(int disputeId) async {
    final res = await _api.post(
      'tickets/disputes/$disputeId/withdraw',
      body: {},
    );
    return DisputeModel.fromJson(res['data'] as Map<String, dynamic>);
  }
}
