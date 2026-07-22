import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:tasknest/data/datasource/localstorage/sharedpreferences.dart';
import 'package:tasknest/env.dart';

/// Matches backend socketHelper events (UPPER_CASE naming).
/// Backend emits: TICKET_CREATED, TICKET_STATUS_UPDATED, TICKET_ASSIGNED,
/// TICKET_REOPENED, SUB_TICKET_CREATED, SUB_TICKET_ASSIGNED,
/// SUB_TICKET_PROGRESS, SUB_TICKET_COMPLETED, SUB_TICKET_REOPENED,
/// COMMENT_ADDED, TICKET_CLOSED, TICKET_UPDATED, NOTIFICATION_COUNT
class SocketManager {
  static final SocketManager _instance = SocketManager._internal();
  factory SocketManager() => _instance;
  SocketManager._internal();

  io.Socket? _socket;
  bool _connected = false;
  bool _connecting = false;

  // ── Stream controllers for multiplexed events ──────────────────────────
  final _ticketCreatedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _ticketUpdatedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  // ── Public streams ─────────────────────────────────────────────────────
  Stream<Map<String, dynamic>> get ticketCreated =>
      _ticketCreatedController.stream;
  Stream<Map<String, dynamic>> get ticketUpdated =>
      _ticketUpdatedController.stream;
  Stream<Map<String, dynamic>> get notificationNew =>
      _notificationController.stream;
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
      debugPrint('[SocketManager] Connected');
      _connected = true;
      _connecting = false;
      _connectionController.add(true);
    });

    _socket!.onDisconnect((_) {
      debugPrint('[SocketManager] Disconnected');
      _connected = false;
      _connectionController.add(false);
    });

    _socket!.onConnectError((err) {
      debugPrint('[SocketManager] Connect error: $err');
      _connected = false;
      _connecting = false;
      _connectionController.add(false);
    });

    // ── Listen for backend events (UPPER_CASE - matches socketHelper) ───
    _socket!.on('TICKET_CREATED', (data) {
      debugPrint('[SocketManager] Received TICKET_CREATED');
      try {
        final map = _parseData(data);
        if (map != null) _ticketCreatedController.add(map);
      } catch (e) {
        debugPrint('[SocketManager] TICKET_CREATED parse error: $e');
      }
    });

    _socket!.on('TICKET_STATUS_UPDATED', (data) {
      debugPrint('[SocketManager] Received TICKET_STATUS_UPDATED');
      try {
        final map = _parseData(data);
        if (map != null) _ticketUpdatedController.add(map);
      } catch (e) {
        debugPrint('[SocketManager] TICKET_STATUS_UPDATED parse error: $e');
      }
    });

    _socket!.on('TICKET_ASSIGNED', (data) {
      debugPrint('[SocketManager] Received TICKET_ASSIGNED');
      try {
        final map = _parseData(data);
        if (map != null) _ticketUpdatedController.add(map);
      } catch (e) {
        debugPrint('[SocketManager] TICKET_ASSIGNED parse error: $e');
      }
    });

    _socket!.on('TICKET_UPDATED', (data) {
      debugPrint('[SocketManager] Received TICKET_UPDATED');
      try {
        final map = _parseData(data);
        if (map != null) _ticketUpdatedController.add(map);
      } catch (e) {
        debugPrint('[SocketManager] TICKET_UPDATED parse error: $e');
      }
    });

    _socket!.on('TICKET_REOPENED', (data) {
      debugPrint('[SocketManager] Received TICKET_REOPENED');
      try {
        final map = _parseData(data);
        if (map != null) _ticketUpdatedController.add(map);
      } catch (e) {
        debugPrint('[SocketManager] TICKET_REOPENED parse error: $e');
      }
    });

    _socket!.on('TICKET_CLOSED', (data) {
      debugPrint('[SocketManager] Received TICKET_CLOSED');
      try {
        final map = _parseData(data);
        if (map != null) _ticketUpdatedController.add(map);
      } catch (e) {
        debugPrint('[SocketManager] TICKET_CLOSED parse error: $e');
      }
    });

    _socket!.on('SUB_TICKET_CREATED', (data) {
      debugPrint('[SocketManager] Received SUB_TICKET_CREATED');
      try {
        final map = _parseData(data);
        if (map != null) _ticketUpdatedController.add(map);
      } catch (e) {
        debugPrint('[SocketManager] SUB_TICKET_CREATED parse error: $e');
      }
    });

    _socket!.on('SUB_TICKET_ASSIGNED', (data) {
      debugPrint('[SocketManager] Received SUB_TICKET_ASSIGNED');
      try {
        final map = _parseData(data);
        if (map != null) _ticketUpdatedController.add(map);
      } catch (e) {
        debugPrint('[SocketManager] SUB_TICKET_ASSIGNED parse error: $e');
      }
    });

    _socket!.on('SUB_TICKET_PROGRESS', (data) {
      debugPrint('[SocketManager] Received SUB_TICKET_PROGRESS');
      try {
        final map = _parseData(data);
        if (map != null) _ticketUpdatedController.add(map);
      } catch (e) {
        debugPrint('[SocketManager] SUB_TICKET_PROGRESS parse error: $e');
      }
    });

    _socket!.on('SUB_TICKET_COMPLETED', (data) {
      debugPrint('[SocketManager] Received SUB_TICKET_COMPLETED');
      try {
        final map = _parseData(data);
        if (map != null) _ticketUpdatedController.add(map);
      } catch (e) {
        debugPrint('[SocketManager] SUB_TICKET_COMPLETED parse error: $e');
      }
    });

    _socket!.on('SUB_TICKET_REOPENED', (data) {
      debugPrint('[SocketManager] Received SUB_TICKET_REOPENED');
      try {
        final map = _parseData(data);
        if (map != null) _ticketUpdatedController.add(map);
      } catch (e) {
        debugPrint('[SocketManager] SUB_TICKET_REOPENED parse error: $e');
      }
    });

    _socket!.on('TICKET_ENRICHED', (data) {
      debugPrint('[SocketManager] Received TICKET_ENRICHED');
      try {
        final map = _parseData(data);
        if (map != null) _ticketUpdatedController.add(map);
      } catch (e) {
        debugPrint('[SocketManager] TICKET_ENRICHED parse error: $e');
      }
    });

    _socket!.on('COMMENT_ADDED', (data) {
      debugPrint('[SocketManager] Received COMMENT_ADDED');
      try {
        final map = _parseData(data);
        if (map != null) _ticketUpdatedController.add(map);
      } catch (e) {
        debugPrint('[SocketManager] COMMENT_ADDED parse error: $e');
      }
    });

    _socket!.on('NOTIFICATION_COUNT', (data) {
      try {
        final map = _parseData(data);
        if (map != null) _notificationController.add(map);
      } catch (e) {
        debugPrint('[SocketManager] NOTIFICATION_COUNT parse error: $e');
      }
    });

    // ── Also listen for colon-notation events as fallback ──────────────
    _socket!.on('ticket:created', (data) {
      debugPrint('[SocketManager] (fallback) Received ticket:created');
      try {
        final map = _parseData(data);
        if (map != null) _ticketCreatedController.add(map);
      } catch (e) {
        debugPrint('[SocketManager] ticket:created parse error: $e');
      }
    });

    _socket!.on('ticket:updated', (data) {
      debugPrint('[SocketManager] (fallback) Received ticket:updated');
      try {
        final map = _parseData(data);
        if (map != null) _ticketUpdatedController.add(map);
      } catch (e) {
        debugPrint('[SocketManager] ticket:updated parse error: $e');
      }
    });
  }

  /// Emit a ticket action with ack callback.
  void emitTicketAction(
    String action,
    int ticketId, {
    Map<String, dynamic>? params,
    Function(Map<String, dynamic>)? onAck,
  }) {
    if (_socket == null || !_connected) return;

    final payload = {'action': action, 'ticketId': ticketId, ...?params};

    _socket!.emitWithAck(
      'ticket:action',
      payload,
      ack: (response) {
        if (onAck != null && response is Map) {
          onAck(Map<String, dynamic>.from(response));
        }
      },
    );
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
        return Map<String, dynamic>.from(jsonDecode(data));
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
