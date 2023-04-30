import 'dart:convert';
import 'dart:ffi';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms/constants.dart';
import 'package:tms/schema/tms-schema.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:fast_rsa/fast_rsa.dart';

// enum RegisterState {
//   unregistered,
//   registered,
//   alreadyRegistered,
// }

enum NetworkWebSocketState {
  disconnected,
  connectingEncryption,
  connected,
}

class NetworkWebSocket {
  // static NetworkWebSocketState _connectionState = NetworkWebSocketState.disconnected;
  final Future<SharedPreferences> _localStorage = SharedPreferences.getInstance();
  final _userID = const Uuid().v4();
  late WebSocketChannel _channel;
  late RegisterResponse _registerResponse;
  late KeyPair _keyPair;
  late String _serverKey;

  static void setState(NetworkWebSocketState state) async {
    await _localStorage.then((value) => value.setString(store_ws_connection_state, EnumToString.convertToString(state)));
  }

  static Future<NetworkWebSocketState> getState() async {
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

  static Future<KeyPair> generateKeyPair() async {
    setState(NetworkWebSocketState.connectingEncryption);
    return await RSA.generate(2048);
  }

  static Future<RegisterState> register(String addr) async {
    _keyPair = await generateKeyPair();
    final request = RegisterRequest(key: _keyPair.publicKey, userId: _userID);
    final response = await http.post(Uri.parse('http://$addr:$requestPort/requests/register'), body: jsonEncode(request.toJson()));

    print("Status code: ${response.statusCode}");
    if (response.statusCode == 200 || response.statusCode == 201) {
      _registerResponse = RegisterResponse.fromJson(jsonDecode(response.body));
      return RegisterState.registered;
    } else if (response.statusCode == 208) {
      print("Already registered");
      return RegisterState.alreadyRegistered;
    } else {
      await http.delete(Uri.parse('http://$addr:$requestPort/requests/register/$_userID'));
      throw Exception("Failed to load register response");
    }
  }

  static void listen() async {
    _channel.stream.listen((event) {}, onDone: () {
      setState(NetworkWebSocketState.disconnected);
      print("Closed");
    }, onError: (e) {
      print("Error");
      setState(NetworkWebSocketState.disconnected);
    });
  }

  static Future<void> connect(String addr) async {
    RegisterState state = RegisterState.unregistered;
    try {
      state = await register(addr);
      _serverKey = _registerResponse.key;
    } catch (e) {
      print("Register Error");
      setState(NetworkWebSocketState.disconnected);
      return;
    }

    try {
      if (state == RegisterState.registered) {
        _channel = WebSocketChannel.connect(Uri.parse(_registerResponse.url));
      }
      await _channel.ready.then((v) {
        print("Socket Ready");
        setState(NetworkWebSocketState.connected);
        listen();
      }).onError((error, stackTrace) {
        print("Websocket Connection Error");
        setState(NetworkWebSocketState.disconnected);
      });
    } catch (e) {
      print("Websocket Error detected");
      setState(NetworkWebSocketState.disconnected);
    }
  }

  static void disconnect() async {
    _channel.sink.close();
  }
}
