import 'package:enum_to_string/enum_to_string.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms/constants.dart';
import 'package:tms/network/security.dart';
import 'package:tms/schema/tms-schema.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum NetworkWebSocketState { disconnected, connected }

class NetworkWebSocket {
  final Future<SharedPreferences> _localStorage = SharedPreferences.getInstance();
  late WebSocketChannel _channel;
  final Map<String, List<void Function(SocketMessage message)>> _subscribers = Map(); // Topic and function/s

  Future<void> setState(NetworkWebSocketState state) async {
    await _localStorage.then((value) => value.setString(store_ws_connection_state, EnumToString.convertToString(state)));
  }

  Future<NetworkWebSocketState> getState() async {
    try {
      var stateString = await _localStorage.then((value) => value.getString(store_ws_connection_state));
      var state = EnumToString.fromString(NetworkWebSocketState.values, stateString!);
      if (state != null) {
        return state;
      } else {
        return NetworkWebSocketState.disconnected;
      }
    } catch (e) {
      return NetworkWebSocketState.disconnected;
    }
  }

  void subscribe(String topic, void Function(SocketMessage message) onEvent) {
    if (!_subscribers.containsKey(topic)) {
      _subscribers[topic];
    }

    _subscribers[topic]?.add(onEvent);
  }

  Future<void> publish(SocketMessage message) async {
    if (await getState() == NetworkWebSocketState.connected) {
      try {
        _channel.ready.then((v) {
          NetworkSecurity.encryptMessage(message).then((data) {
            _channel.sink.add(data);
          });
        });
      } catch (e) {
        setState(NetworkWebSocketState.disconnected);
      }
    }
  }

  // This can't return a future
  void _listen() async {
    if (await getState() == NetworkWebSocketState.connected) {
      try {
        // Listen to the socket
        _channel.stream.listen((event) {
          // On a regular data message decrypt the message
          NetworkSecurity.decryptMessage(event).then((value) {
            // Convert the message to a socket message type
            SocketMessage m = SocketMessage.fromJson(value);
            // Iterate through the subscribers and check if the topic matches
            _subscribers.forEach((topic, functionList) {
              if (topic == m.topic) {
                // If the topic matches run every onEvent function in the list associated with the topic
                for (final onEvent in functionList) {
                  onEvent(m);
                }
              }
            });
          });
        }, onDone: () {
          setState(NetworkWebSocketState.disconnected);
        }, onError: (e) {
          disconnect().then((v) {
            setState(NetworkWebSocketState.disconnected);
          });
        });
      } catch (e) {
        disconnect().then((v) {
          setState(NetworkWebSocketState.disconnected);
        });
      }
    }
  }

  Future<void> connect(String url) async {
    if (await getState() != NetworkWebSocketState.connected) {
      try {
        _channel = WebSocketChannel.connect(Uri.parse(url));

        _channel.ready.then((v) {
          setState(NetworkWebSocketState.connected);
          print("Connecting using url $url");
          _listen();
        });
      } catch (e) {
        setState(NetworkWebSocketState.disconnected);
      }
    } else {
      try {
        publish(SocketMessage(message: "ping", topic: "none"));
      } catch (e) {
        setState(NetworkWebSocketState.disconnected);
      }
    }
  }

  Future<void> disconnect() async {
    if (await getState() == NetworkWebSocketState.connected) {
      _channel.sink.close().then((v) {
        setState(NetworkWebSocketState.disconnected);
      });
    }
  }
}
