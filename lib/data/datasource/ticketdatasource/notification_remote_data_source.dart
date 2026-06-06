import 'package:tasknest/core/constant/api_client.dart';
import 'package:tasknest/presentation/dashboard/model/ticketmodel.dart';

class NotificationRemoteDataSource {
  final ApiClient _api;
  NotificationRemoteDataSource(this._api);

  Future<NotificationListResponse> getNotifications() async {
    final res = await _api.get('notifications');
    return NotificationListResponse.fromJson(res['data']);
  }

  Future<int> getUnreadCount() async {
    final res = await _api.get('notifications/unread-count');
    return res['data']['count'] as int;
  }

  Future<int> markAsRead({List<int>? ids}) async {
    final res = await _api.patch('notifications/read', body: ids != null ? {'ids': ids} : {});
    return res['data']['unreadCount'] as int;
  }
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
