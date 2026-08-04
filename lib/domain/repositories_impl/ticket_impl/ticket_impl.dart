import 'dart:async';
import 'package:tasknest/data/datasource/notification/notification_remote_data_source.dart';
import 'package:tasknest/data/datasource/socket_helper.dart';
import 'package:tasknest/data/repositories/ticket/ticket_realtime_repository.dart';
import 'package:tasknest/presentation/disputes/models/dispute_model.dart';
import 'package:tasknest/presentation/notification/models/notification_model.dart';
import 'package:tasknest/data/datasource/ticketdatasource/ticket_remote_data_source.dart';
import 'package:tasknest/data/repositories/ticket/ticket_repository.dart';
import 'package:tasknest/presentation/ticket/model/ticketmodel.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class TicketRepositoryImpl implements TicketRepository {
  final TicketRemoteDataSource _ticketDs;
  final NotificationRemoteDataSource _notificationDs;
  final TicketRealtimeRepository _realtime = TicketRealtimeRepository();

  TicketRepositoryImpl(this._ticketDs, this._notificationDs);

  @override
  Future<DashboardStats> getStats() => _ticketDs.getStats();

  @override
  Future<({List<TicketModel> tickets, int total, int page, int totalPages})> getTickets({
    String? status,
    String? priority,
    int page = 1,
    String? scope,
    String? search,
  }) =>
      _ticketDs.getTickets(
        status: status,
        priority: priority,
        page: page,
        scope: scope,
        search: search,
      );

  @override
  Future<({List<TicketModel> tickets, int total, int page, int totalPages})> filterTickets({
    String? status,
    String? priority,
    String? search,
    bool? teamOnly,
    int page = 1,
  }) =>
      _ticketDs.filterTickets(
        status: status,
        priority: priority,
        search: search,
        teamOnly: teamOnly,
        page: page,
      );

  @override
  Future<TicketModel> getTicket(int id) => _ticketDs.getTicket(id);

  @override
  Stream<TicketModel> watchTicket(int ticketId, {TicketModel? initial}) {
    SocketHelper().joinTicketRoom(ticketId);

    return _realtime.watchTicket(ticketId, _ticketDs, initial: initial);
  }

  @override
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
  }) =>
      _ticketDs.createTicket(
        title: title,
        description: description,
        priority: priority,
        departmentIds: departmentIds,
        createdById: createdById,
        createdByDept: createdByDept,
        assignedToId: assignedToId,
        dueDate: dueDate,
        parentTicketId: parentTicketId,
        selfAssign: selfAssign,
        subTitle: subTitle,
        subDescription: subDescription,
        deptTickets: deptTickets,
      );

  @override
  Future<TicketModel> createSubTicket({
    required String title,
    required String description,
    required String priority,
    required List<Map<String, dynamic>> departments,
    String? dueDate,
    int? parentTicketId,
  }) =>
      _ticketDs.createSubTicket(
        title: title,
        description: description,
        priority: priority,
        departments: departments,
        dueDate: dueDate,
        parentTicketId: parentTicketId,
      );

  @override
  Future<TicketModel> updateStatus(
    int id,
    String status, {
    String? remark,
  }) =>
      _ticketDs.updateStatus(id, status, remark: remark);

  @override
  Future<TicketModel> selfAssign(int id) => _ticketDs.selfAssign(id);

  @override
  Future<TicketModel> assignToEmployee(int ticketId, int employeeId) =>
      _ticketDs.assignToEmployee(ticketId, employeeId);

  @override
  Future<TicketModel> transferTicket(int ticketId, int targetDeptId, {String? title, String? description}) =>
      _ticketDs.transferTicket(ticketId, targetDeptId, title: title, description: description);

  @override
  Future<TicketModel> reopenTicket(int id) => _ticketDs.reopenTicket(id);

  @override
  Future<TicketModel> updateDescription(int id, String description) =>
      _ticketDs.updateDescription(id, description);

  @override
  Future<List<DepartmentModel>> getDepartments() => _ticketDs.getDepartments();

  @override
  Future<List<EmployeeModel>> getEmployees({int? departmentId}) =>
      _ticketDs.getEmployees(departmentId: departmentId);

  @override
  Future<List<TicketModel>> getSentTickets() => _ticketDs.getSentTickets();

  @override
  Future<int> getUnreadCount() => _ticketDs.getUnreadCount();

  @override
  Future<TicketModel> updateSubDeptProgress({
    required int ticketId,
    required int departmentId,
    String? status,
    String? note,
  }) =>
      _ticketDs.updateSubDeptProgress(
        ticketId: ticketId,
        departmentId: departmentId,
        status: status,
        note: note,
      );

  @override
  Future<TicketModel> selfAssignSubDept(int ticketId, int departmentId) =>
      _ticketDs.selfAssignSubDept(ticketId, departmentId);

  @override
  Future<TicketModel> assignSubDeptToEmployee({
    required int ticketId,
    required int departmentId,
    required int employeeId,
  }) =>
      _ticketDs.assignSubDeptToEmployee(
        ticketId: ticketId,
        departmentId: departmentId,
        employeeId: employeeId,
      );

  @override
  Future<TicketModel> completeSubTicket(int ticketId) => _ticketDs.completeSubTicket(ticketId);

  @override
  Future<TicketModel> reopenSubDept(int ticketId, int departmentId) =>
      _ticketDs.reopenSubDept(ticketId, departmentId);

  @override
  Future<DashboardStats> getDepartmentAnalytics(int departmentId) =>
      _ticketDs.getDepartmentAnalytics(departmentId);

  @override
  Future<List<dynamic>> getOrganizationAnalytics() => _ticketDs.getOrganizationAnalytics();

  @override
  Future<void> addComment(int ticketId, String message) => _ticketDs.addComment(ticketId, message);

  @override
  Future<NotificationListResponse> getNotifications() => _notificationDs.getNotifications();

  @override
  Future<int> markAsRead({List<int>? ids}) => _notificationDs.markAsRead(ids: ids);

  @override
  Future<TicketModel> disputeTicket(int ticketId, String argument) =>
      _ticketDs.disputeTicket(ticketId, argument);

  @override
  Future<DisputeModel?> getDisputeByTicket(int ticketId) =>
      _ticketDs.getDisputeByTicket(ticketId);

  @override
  Future<List<DisputeModel>> listDisputes() => _ticketDs.listDisputes();

  @override
  Future<DisputeModel> raiseDispute(
    int ticketId, {
    required String reason,
    required String description,
  }) =>
      _ticketDs.raiseDispute(
        ticketId,
        reason: reason,
        description: description,
      );

  @override
  Future<DisputeModel> addDisputeComment(int disputeId, String note) =>
      _ticketDs.addDisputeComment(disputeId, note);

  @override
  Future<DisputeModel> updateDisputeStatus(
    int disputeId, {
    required String status,
    String? note,
    int? reviewerId,
  }) =>
      _ticketDs.updateDisputeStatus(
        disputeId,
        status: status,
        note: note,
        reviewerId: reviewerId,
      );

  @override
  Future<DisputeModel> withdrawDispute(int disputeId) =>
      _ticketDs.withdrawDispute(disputeId);
}
