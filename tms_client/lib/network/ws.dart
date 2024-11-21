import 'package:tms/generated/infra/network_schemas/socket_protocol/server_socket_protocol.dart';
import 'package:tms/utils/logger.dart';
import 'package:tms/network/connectivity.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

typedef TmsEventHandler = void Function(TmsServerSocketMessage event);

class WebsocketController {
  final NetworkConnectivity _connectivity = NetworkConnectivity();
  WebSocketChannel? _channel;
  NetworkConnectionState get state => _connectivity.state;
  NetworkConnectivity get connectivity => _connectivity;

  // events
  final Map<TmsServerSocketEvent, List<TmsEventHandler>> _eventHandlers = {};

  void _handleMessage(TmsServerSocketMessage message) async {
    if (_eventHandlers.containsKey(message.messageEvent)) {
      List<TmsEventHandler>? handlers = _eventHandlers[message.messageEvent];
      if (handlers != null) {
        for (TmsEventHandler handler in handlers) {
          handler(message);
        }
      }
    }
  }

  void _listen() async {
    try {
      _channel?.stream.listen((event) {
        try {
          var message = TmsServerSocketMessage.fromJsonString(json: event);
          _handleMessage(message);
        } catch (e) {
          TmsLogger().e("Error parsing message: $e");
        }
      }, onDone: () {
        TmsLogger().w("Websocket  connection closed");
        _connectivity.state = NetworkConnectionState.disconnected;
      }, onError: (e) {
        TmsLogger().e("Websocket error: $e");
        _connectivity.state = NetworkConnectionState.disconnected;
      });
    } catch (e) {
      TmsLogger().e("Websocket error: $e");
      _connectivity.state = NetworkConnectionState.disconnected;
    }
  }

  Future<bool> connect(String url) async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _channel?.ready.then((_) {
        _connectivity.state = NetworkConnectionState.connected;
        TmsLogger().d("Connected to TMS server websocket");
        _listen();
      });
    } catch (e) {
      _connectivity.state = NetworkConnectionState.disconnected;
      return false;
    }
    return true;
  }

  Future<void> disconnect() async {
    TmsLogger().i("Disconnecting from TMS server...");
    _connectivity.state = NetworkConnectionState.disconnected;
    _channel?.sink.close();
  }

  void subscribe(TmsServerSocketEvent event, TmsEventHandler handler) {
    if (!_eventHandlers.containsKey(event)) {
      _eventHandlers[event] = [];
    }
    _eventHandlers[event]?.add(handler);
  }

  void unsubscribe(TmsServerSocketEvent event, TmsEventHandler handler) {
    if (_eventHandlers.containsKey(event)) {
      _eventHandlers[event]?.remove(handler);
    }
  }
}
