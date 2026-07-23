import 'dart:async';
import 'dart:html' as html;
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

  final StreamController<SocketEvent> _eventController =
      StreamController<SocketEvent>.broadcast();

  Stream<SocketEvent> get events => _eventController.stream;
  bool get isConnected => _isConnected;

  void connect(String token, {int? userId, int? departmentId}) {
    if (_isConnected && _socket != null && _token == token && _userId == userId)
      return;
    if (_connecting && _token == token && _userId == userId) return;
    if (_connecting) {
      disconnect();
    } else if (_isConnected && (_token != token || _userId != userId)) {
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

    final uri = Env.isLive ? html.window.location.origin : Env.socketUrl;

    _socket = io.io(
      uri,
      OptionBuilder()
          .setTransports(['polling', 'websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(30000)
          .setAuth({
            'token': _token,
            'userId': _userId,
            'departmentId': _departmentId,
          })
          .setExtraHeaders({'X-Department-Id': _departmentId?.toString() ?? ''})
          .build(),
    );

    _socket!.onConnect((_) {
      _isConnected = true;
      _connecting = false;
      _eventController.add(SocketEvent('SOCKET_CONNECTED', {}));
    });

    _socket!.onDisconnect((reason) {
      _isConnected = false;
      _connecting = false;
      print('[Socket] Disconnected: $reason');
    });

    _socket!.onConnectError((err) {
      _isConnected = false;
      _connecting = false;
      print('[Socket] Connect error: $err');
    });

    _socket!.onError((err) {
      _isConnected = false;
      _connecting = false;
      print('[Socket] Error: $err');
    });

    _socket!.onReconnect((_) {
      _isConnected = true;
      _connecting = false;
      _eventController.add(SocketEvent('SOCKET_CONNECTED', {}));
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

    _socket!.on('TICKET_CLOSED', (data) {
      _eventController.add(SocketEvent('TICKET_CLOSED', data));
    });

    _socket!.on('NOTIFICATION_COUNT', (data) {
      _eventController.add(SocketEvent('NOTIFICATION_COUNT', data));
    });

    _socket!.on('TICKET_UPDATED', (data) {
      _eventController.add(SocketEvent('TICKET_UPDATED', data));
    });

    _socket!.on('TICKET_ENRICHED', (data) {
      _eventController.add(SocketEvent('TICKET_ENRICHED', data));
    });

    _socket!.connect();
  }

  void joinTicketRoom(int ticketId) {
    _socket?.emit('ticket:join_details', ticketId);
  }

  void leaveTicketRoom(int ticketId) {
    _socket?.emit('ticket:leave_details', ticketId);
  }

  void reconnect() {
    if (_isConnected || _connecting) return;
    _doConnect();
  }

  void disconnect() {
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
