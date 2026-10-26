import 'package:tasknest/presentation/disputes/models/dispute_model.dart';
import 'package:tasknest/presentation/notification/models/notification_model.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';

abstract class TicketRepository {
  Future<DashboardStats> getStats();

  Future<({List<TicketModel> tickets, int total, int page, int totalPages})> getTickets({
    String? status,
    String? priority,
    int page = 1,
    String? scope,
    String? search,
  });

  Future<({List<TicketModel> tickets, int total, int page, int totalPages})> filterTickets({
    String? status,
    String? priority,
    String? search,
    bool? teamOnly,
    int page = 1,
  });

  Future<TicketModel> getTicket(int id);

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
  });

  Future<TicketModel> createSubTicket({
    required String title,
    required String description,
    required String priority,
    required List<Map<String, dynamic>> departments,
    String? dueDate,
    int? parentTicketId,
  });

  Future<TicketModel> updateStatus(
    int id,
    String status, {
    String? remark,
  });

  Future<TicketModel> selfAssign(int id);

  Future<TicketModel> assignToEmployee(int ticketId, int employeeId);

  Future<TicketModel> transferTicket(int ticketId, int targetDeptId, {String? title, String? description});

  Future<TicketModel> reopenTicket(int id);

  Future<TicketModel> updateDescription(int id, String description);

  /// Updates the editable core fields of a ticket (title, description,
  /// priority, due date).
  Future<TicketModel> updateTicket(int id, Map<String, dynamic> fields);

  /// Replaces the whole member list of a task (Trello-style).
  Future<List<TicketMemberModel>> setTicketMembers(
    int id,
    List<int> memberIds,
  );

  /// Archives a project task (Trello-style) — hidden from the board.
  Future<void> archiveTicket(int id);

  /// Restores an archived task back onto the board.
  Future<void> unarchiveTicket(int id);

  /// Creates a Trello-style project task in one call (list + team applied
  /// at creation time). Regular tickets keep using the ticket workflow.
  Future<TicketModel> createProjectTask({
    required String title,
    required String description,
    required int projectId,
    required int assignedDeptId,
    String priority = 'medium',
    String? dueDate,
    String status = 'open',
    List<int> memberIds = const [],
  });

  Future<List<DepartmentModel>> getDepartments();

  Future<List<EmployeeModel>> getEmployees({int? departmentId});

  Future<List<TicketModel>> getSentTickets();

  Future<int> getUnreadCount();

  Future<TicketModel> updateSubDeptProgress({
    required int ticketId,
    required int departmentId,
    String? status,
    String? note,
  });

  Future<TicketModel> selfAssignSubDept(int ticketId, int departmentId);

  Future<TicketModel> assignSubDeptToEmployee({
    required int ticketId,
    required int departmentId,
    required int employeeId,
  });

  Future<TicketModel> completeSubTicket(int ticketId);

  Future<TicketModel> reopenSubDept(int ticketId, int departmentId);

  Future<DashboardStats> getDepartmentAnalytics(int departmentId);

  Future<List<dynamic>> getOrganizationAnalytics();

  Stream<TicketModel> watchTicket(int ticketId, {TicketModel? initial});

  Future<void> addComment(int ticketId, String message);

  Future<NotificationListResponse> getNotifications();

  Future<int> markAsRead({List<int>? ids});

  Future<TicketModel> disputeTicket(int ticketId, String argument);

  Future<DisputeModel?> getDisputeByTicket(int ticketId);

  Future<List<DisputeModel>> listDisputes();

  Future<DisputeModel> raiseDispute(
    int ticketId, {
    required String reason,
    required String description,
  });

  Future<DisputeModel> addDisputeComment(int disputeId, String note);

  Future<DisputeModel> updateDisputeStatus(
    int disputeId, {
    required String status,
    String? note,
    int? reviewerId,
  });

  Future<DisputeModel> withdrawDispute(int disputeId);
}
