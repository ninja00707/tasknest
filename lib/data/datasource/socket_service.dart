import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:tasknest/env.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  io.Socket? _socket;
  bool _isConnected = false;

  final StreamController<SocketEvent> _eventController =
      StreamController<SocketEvent>.broadcast();

  Stream<SocketEvent> get events => _eventController.stream;
  bool get isConnected => _isConnected;

  void connect(String token, {int? userId, int? departmentId}) {
    if (_socket != null && _isConnected) return;

    final uri = Env.isLive
        ? 'https://your-production-api.com'
        : 'http://localhost:5050';

    _socket = io.io(
      uri,
      OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({
            'token': token,
            'userId': userId,
            'departmentId': departmentId,
          })
          .build(),
    );

    _socket!.onConnect((_) {
      _isConnected = true;
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
    });

    _socket!.onConnectError((_) {
      _isConnected = false;
    });

    // ── Event listeners ────────────────────────────────────────────
    _socket!.on('TICKET_CREATED', (data) {
      _eventController.add(SocketEvent('TICKET_CREATED', data));
    });

    _socket!.on('TICKET_ASSIGNED', (data) {
      _eventController.add(SocketEvent('TICKET_ASSIGNED', data));
    });

    _socket!.on('TICKET_STATUS_UPDATED', (data) {
      _eventController.add(SocketEvent('TICKET_STATUS_UPDATED', data));
    });

    _socket!.on('TICKET_REOPENED', (data) {
      _eventController.add(SocketEvent('TICKET_REOPENED', data));
    });

    _socket!.on('COMMENT_ADDED', (data) {
      _eventController.add(SocketEvent('COMMENT_ADDED', data));
    });

    _socket!.on('NOTIFICATION', (data) {
      _eventController.add(SocketEvent('NOTIFICATION', data));
    });

    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
  }

  void dispose() {
    disconnect();
    _eventController.close();
  }
}

class SocketEvent {
  final String type;
  final dynamic data;
  const SocketEvent(this.type, this.data);
}
