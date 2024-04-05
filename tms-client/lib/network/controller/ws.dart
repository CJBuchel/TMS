import 'package:tms/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketController {
  WebSocketChannel? _channel;
  bool _connected = false;

  get connected => _connected;

  void _handleEvent(dynamic event) async {
    try {
      // handle the event
      TmsLogger().d("Websocket message: $event");
    } catch (e) {
      TmsLogger().e("Websocket error: $e");
    }
  }

  void _listen() async {
    if (!_connected) {
      TmsLogger().w("Websocket Not connected to TMS server");
      return;
    }

    try {
      _channel?.stream.listen((event) {
        _handleEvent(event);
      }, onDone: () {
        TmsLogger().d("Websocket connection closed");
        _connected = false;
      }, onError: (e) {
        TmsLogger().e("Websocket error: $e");
        _connected = false;
      });
    } catch (e) {
      TmsLogger().e("Websocket error: $e");
      _connected = false;
    }
  }

  Future<bool> connect(String url) async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _channel?.ready.then((_) {
        _connected = true;
        _listen();
      });
    } catch (e) {
      return false;
    }
    return true;
  }

  Future<void> disconnect() async {
    TmsLogger().i("Disconnecting from TMS server...");
    _connected = false;
    _channel?.sink.close();
  }
}
