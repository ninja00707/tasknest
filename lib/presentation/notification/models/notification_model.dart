class NotificationModel {
  final int id;
  final int? ticketId;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final String? ticketNumber;

  const NotificationModel({
    required this.id,
    this.ticketId,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.ticketNumber,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> j) =>
      NotificationModel(
        id: j['id'],
        ticketId: j['ticket_id'],
        message: j['message'] ?? '',
        isRead: j['is_read'] ?? false,
        createdAt: DateTime.parse(j['created_at']),
        ticketNumber: j['ticket_number'],
      );
}

class NotificationListResponse {
  final List<NotificationModel> notifications;
  final int unreadCount;
  NotificationListResponse({required this.notifications, required this.unreadCount});

  factory NotificationListResponse.fromJson(Map<String, dynamic> j) {
    return NotificationListResponse(
      notifications: (j['notifications'] as List)
          .map((e) => NotificationModel.fromJson(e))
          .toList(),
      unreadCount: j['unreadCount'] as int,
    );
  }
}
