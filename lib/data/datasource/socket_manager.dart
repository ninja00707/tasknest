import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:tasknest/data/datasource/localstorage/sharedpreferences.dart';
import 'package:tasknest/env.dart';

class SocketManager {
  static final SocketManager _instance = SocketManager._internal();
  factory SocketManager() => _instance;
  SocketManager._internal();

  io.Socket? _socket;
  bool _connected = false;
  bool _connecting = false;

  // ── Stream controllers for multiplexed events ──────────────────────────
  final _ticketCreatedController = StreamController<Map<String, dynamic>>.broadcast();
  final _ticketUpdatedController = StreamController<Map<String, dynamic>>.broadcast();
  final _notificationController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  // ── Public streams ─────────────────────────────────────────────────────
  Stream<Map<String, dynamic>> get ticketCreated => _ticketCreatedController.stream;
  Stream<Map<String, dynamic>> get ticketUpdated => _ticketUpdatedController.stream;
  Stream<Map<String, dynamic>> get notificationNew => _notificationController.stream;
  Stream<bool> get connectionStatus => _connectionController.stream;

  bool get isConnected => _connected;

  /// Initialize the single socket connection. Safe to call multiple times.
  Future<void> connect() async {
    if (_connected || _connecting) return;
    _connecting = true;

    final token = await LocalStorageService().getToken();
    if (token == null || token.isEmpty) {
      _connecting = false;
      return;
    }

    _socket = io.io(
      Env.socketUrl,
      io.OptionBuilder()
          .setAuth({'token': token})
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(2000)
          .setReconnectionAttempts(50)
          .build(),
    );

    _socket!.onConnect((_) {
      _connected = true;
      _connecting = false;
      _connectionController.add(true);
    });

    _socket!.onDisconnect((_) {
      _connected = false;
      _connectionController.add(false);
    });

    _socket!.onConnectError((err) {
      _connected = false;
      _connecting = false;
      _connectionController.add(false);
    });

    // ── Multiplexed event listeners ───────────────────────────────────────
    _socket!.on('ticket:created', (data) {
      try {
        final map = _parseData(data);
        if (map != null) _ticketCreatedController.add(map);
      } catch (e) {
        debugPrint('[SocketManager] ticket:created parse error: $e');
      }
    });

    _socket!.on('ticket:updated', (data) {
      try {
        final map = _parseData(data);
        if (map != null) _ticketUpdatedController.add(map);
      } catch (e) {
        debugPrint('[SocketManager] ticket:updated parse error: $e');
      }
    });

    _socket!.on('notification:new', (data) {
      try {
        final map = _parseData(data);
        if (map != null) _notificationController.add(map);
      } catch (e) {
        debugPrint('[SocketManager] notification:new parse error: $e');
      }
    });
  }

  /// Emit a ticket action with ack callback.
  void emitTicketAction(String action, int ticketId,
      {Map<String, dynamic>? params, Function(Map<String, dynamic>)? onAck}) {
    if (_socket == null || !_connected) return;

    final payload = {
      'action': action,
      'ticketId': ticketId,
      ...?params,
    };

    _socket!.emitWithAck('ticket:action', payload, ack: (response) {
      if (onAck != null && response is Map) {
        onAck(Map<String, dynamic>.from(response));
      }
    });
  }

  /// Join a ticket detail room for live updates.
  void joinTicketRoom(int ticketId) {
    _socket?.emit('ticket:join_details', ticketId);
  }

  /// Leave a ticket detail room.
  void leaveTicketRoom(int ticketId) {
    _socket?.emit('ticket:leave_details', ticketId);
  }

  Map<String, dynamic>? _parseData(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is String) {
      try {
        return jsonDecode(data) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _connected = false;
    _connecting = false;
  }

  void dispose() {
    disconnect();
    _ticketCreatedController.close();
    _ticketUpdatedController.close();
    _notificationController.close();
    _connectionController.close();
  }
}
