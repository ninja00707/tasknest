import 'package:tasknest/core/constant/api_client.dart';
import 'package:tasknest/presentation/notification/models/notification_model.dart';

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
