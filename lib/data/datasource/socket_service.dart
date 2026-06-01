import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket? socket;
  final String baseUrl;

  SocketService({required this.baseUrl});

  void initSocket(String? token, Map<String, Function(dynamic)> listeners) {
    if (socket != null && socket!.connected) {
      debugPrint('Socket already connected. Skipping initialization.');
      return;
    }

    socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'extraHeaders': token != null ? {'Authorization': 'Bearer $token'} : {},
    });

    socket?.connect();

    socket?.onConnect((_) {
      debugPrint('Real-time connection established');
    });

    // Dynamically register listeners for all API data types
    listeners.forEach((event, callback) {
      socket?.on(event, (data) {
        debugPrint('Real-time event [$event] received: $data');
        callback(data);
      });
    });

    socket?.onDisconnect((_) => debugPrint('Real-time connection lost'));
    socket?.onConnectError(
      (err) => debugPrint('Socket connection error: $err'),
    );
    socket?.onError((err) => debugPrint('Socket error: $err'));
  }

  void dispose() {
    socket?.dispose();
    socket = null;
  }
}
