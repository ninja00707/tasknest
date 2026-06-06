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
  bool _connecting = false;
  String? _token;
  int? _userId;
  int? _departmentId;
  int _retryCount = 0;
  Timer? _retryTimer;

  final StreamController<SocketEvent> _eventController =
      StreamController<SocketEvent>.broadcast();

  Stream<SocketEvent> get events => _eventController.stream;
  bool get isConnected => _isConnected;

  void connect(String token, {int? userId, int? departmentId}) {
    _retryCount = 0;
    _retryTimer?.cancel();
    // Force reconnect if credentials changed
    if (_isConnected && (_token != token || _userId != userId)) {
      disconnect();
    }
    _token = token;
    _userId = userId;
    _departmentId = departmentId;
    _doConnect();
  }

  void _doConnect() {
    if (_connecting) return;
    if (_isConnected && _socket != null) return;

    _connecting = true;

    if (_socket != null) {
      try {
        _socket!.disconnect();
        _socket!.dispose();
      } catch (_) {}
      _socket = null;
    }

    final uri = Env.isLive
        ? 'https://your-production-api.com'
        : 'http://localhost:5050';

    _socket = io.io(
      uri,
      OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .disableReconnection() // We handle reconnection ourselves
          .setAuth({
            'token': _token,
            'userId': _userId,
            'departmentId': _departmentId,
          })
          .build(),
    );

    _socket!.onConnect((_) {
      _isConnected = true;
      _connecting = false;
      _retryCount = 0; // Reset retry count on successful connection
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      _connecting = false;
      _scheduleRetry();
    });

    _socket!.onConnectError((_) {
      _isConnected = false;
      _connecting = false;
      _scheduleRetry();
    });

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

    _socket!.on('SUB_TICKET_CREATED', (data) {
      _eventController.add(SocketEvent('SUB_TICKET_CREATED', data));
    });

    _socket!.on('SUB_TICKET_ASSIGNED', (data) {
      _eventController.add(SocketEvent('SUB_TICKET_ASSIGNED', data));
    });

    _socket!.on('SUB_TICKET_PROGRESS', (data) {
      _eventController.add(SocketEvent('SUB_TICKET_PROGRESS', data));
    });

    _socket!.on('SUB_TICKET_COMPLETED', (data) {
      _eventController.add(SocketEvent('SUB_TICKET_COMPLETED', data));
    });

    _socket!.on('SUB_TICKET_REOPENED', (data) {
      _eventController.add(SocketEvent('SUB_TICKET_REOPENED', data));
    });

    _socket!.on('COMMENT_ADDED', (data) {
      _eventController.add(SocketEvent('COMMENT_ADDED', data));
    });

    _socket!.on('NOTIFICATION', (data) {
      _eventController.add(SocketEvent('NOTIFICATION', data));
    });

    _socket!.on('NOTIFICATION_COUNT', (data) {
      _eventController.add(SocketEvent('NOTIFICATION_COUNT', data));
    });

    _socket!.on('TICKET_UPDATED', (data) {
      _eventController.add(SocketEvent('TICKET_UPDATED', data));
    });

    _socket!.connect();
  }

  void _scheduleRetry() {
    if (_token == null) return;
    if (_retryCount >= 20) return; // Max 20 retries (~10 min)

    _retryTimer?.cancel();
    _retryCount++;

    // Exponential backoff: 2s, 4s, 8s, ... up to 30s max
    final delay = Duration(
      milliseconds: (_retryCount > 6 ? 30000 : 2000 * (1 << (_retryCount - 1)))
          .clamp(2000, 30000),
    );

    _retryTimer = Timer(delay, () {
      if (!_isConnected && !_connecting && _token != null) {
        _doConnect();
      }
    });
  }

  void reconnect() {
    _retryCount = 0;
    _retryTimer?.cancel();
    _isConnected = false;
    _connecting = false;
    _doConnect();
  }

  void disconnect() {
    _retryTimer?.cancel();
    _retryCount = 0;
    _isConnected = false;
    _connecting = false;
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
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
