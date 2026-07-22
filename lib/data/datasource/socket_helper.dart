import 'dart:async';
import 'package:tasknest/data/datasource/socket_service.dart';

export 'package:tasknest/data/datasource/socket_service.dart' show SocketEvent;

class SocketHelper {
  static final SocketHelper _instance = SocketHelper._();
  factory SocketHelper() => _instance;
  SocketHelper._();

  final SocketService _service = SocketService();

  Stream<SocketEvent> get events => _service.events;
  bool get isConnected => _service.isConnected;

  void connect(String token, {int? userId, int? departmentId}) {
    _service.connect(token, userId: userId, departmentId: departmentId);
  }

  void disconnect() => _service.disconnect();
  void reconnect() => _service.reconnect();
  void joinTicketRoom(int ticketId) => _service.joinTicketRoom(ticketId);
  void leaveTicketRoom(int ticketId) => _service.leaveTicketRoom(ticketId);

  Stream<SocketEvent> onTicketEvents() => events.where((e) {
        return e.type == 'TICKET_CREATED' ||
            e.type == 'TICKET_ASSIGNED' ||
            e.type == 'TICKET_STATUS_UPDATED' ||
            e.type == 'TICKET_REOPENED' ||
            e.type == 'TICKET_UPDATED' ||
            e.type == 'TICKET_CLOSED' ||
            e.type == 'COMMENT_ADDED' ||
            e.type == 'SUB_TICKET_CREATED' ||
            e.type == 'SUB_TICKET_ASSIGNED' ||
            e.type == 'SUB_TICKET_PROGRESS' ||
            e.type == 'SUB_TICKET_COMPLETED' ||
            e.type == 'SUB_TICKET_REOPENED' ||
            e.type == 'TICKET_ENRICHED';
      });

  Stream<SocketEvent> onNotificationEvents() => events.where((e) {
        return e.type == 'NOTIFICATION_COUNT' || e.type == 'COMMENT_ADDED';
      });

  Stream<SocketEvent> onConnectionEvents() =>
      events.where((e) => e.type == 'SOCKET_CONNECTED');
}
