import 'package:socket_io_client/socket_io_client.dart' as io;
import '../storage/token_storage.dart';
import 'api_client.dart';

class SocketClient {
  static io.Socket? _socket;

  static Future<io.Socket> connect() async {
    if (_socket != null && _socket!.connected) {
      return _socket!;
    }

    final token = await TokenStorage.getToken();

    _socket = io.io(
      ApiClient.baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );

    _socket!.connect();
    return _socket!;
  }

  static io.Socket? get socket => _socket;

  static void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}