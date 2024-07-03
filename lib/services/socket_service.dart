import 'dart:developer';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart';

enum SocketState {
  connect,
  disconnect,
  connectError,
  connectTimeout,
  connecting,
  error,
  reconnect,
  reconnectAttempt,
  reconnectFailed,
  reconnectError,
  reconnecting,
  ping,
  pong,
}

class SocketService {
  late Socket? _socket;

  static final String _baseUrl = dotenv.env['API_URL']!;

  SocketService() {
    _socket = io(
      _baseUrl,
      OptionBuilder()
          .setTransports(['websocket'])
          .enableForceNewConnection()
          .build(),
    );
  }

  dynamic newMessage(dynamic message) {
    log(message);
  }

  void connect() {
    // Check if the socket is already connected
    if (_socket != null && _socket!.connected) {
      log("Warning: socket was already connected!");
      disconnect();
    }
    // Try to connect to the server
    try {
      _socket ??= io(
        _baseUrl,
        OptionBuilder()
            .setTransports(['websocket'])
            // Set Auth Headers in Future
            // .setExtraHeaders({
            //   "Authorization": "Bearer $token",
            //   "x-key": id,
            // })
            .enableForceNewConnection()
            .build(),
      );

      // Register handlers
      _receiveSMS();
      registerExtraHandlers();
    } on Exception catch (e) {
      // Anything else that is an exception
      log('Unknown exception: $e');
      exit(0);
    } catch (e) {
      // No specified type, handles all
      log('Something really unknown: $e');
      exit(0);
    }
  }

  // TODO: Remove unused method
  void oldconnect() {
    log("Connecting to server...");
    _socket?.connect();
    log("Connected to server...");

    // Register Handlers for incoming events
    _socket?.onConnect((data) {
      log('connect');
      log(data);

      _socket?.on('event', (data) => log(data));
      _socket?.on('fromServer', (_) => log(_));
      // new_message
      _socket?.on('new_message', (data) async {
        log(data);
      });
      _socket?.onDisconnect((_) => log('disconnect'));
    });
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }

  void sendSMS(String message) {
    _socket?.emit('new_sms_arrived', message);
  }

  void _receiveSMS() {
    // print message
    _socket?.on('new_message', (data) async {
      log(data);
    });
  }

  void registerExtraHandlers() {
    // Register connect handler
    _socket?.on(SocketState.connect.name, (_) {
      log("⚡ Socket id: ${_socket?.id}");
      // Take some actions after the socket is connected
    });
    // Register Disconnect handler
    _socket?.on(SocketState.disconnect.name, (_) {
      log("🔥 Socket disconncted");
    });
    // Register Other handlers
    for (var state in SocketState.values) {
      if (state != SocketState.connect && state != SocketState.disconnect) {
        _socket?.on(state.name, (_) {
          log("⚡ ${state.name}: ${_socket?.id}");
        });
      }
    }
  }
}

final socketServiceProvider = Provider<SocketService>((ref) {
  return SocketService();
});
