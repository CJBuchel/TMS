import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:tms/logger.dart';
import 'package:tms/schemas/network.dart' as nts;
// import 'package:echo_tree_flutter/echo_tree_flutter.dart' as echo_tree;
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class Network {
  static final Network _instance = Network._internal();
  Network._internal();

  factory Network() {
    return _instance;
  }

  bool _connected = false;
  final String _tmsAddress = "http://localhost:8080";
  String _connectedUrl = "";
  String _authToken = "";
  String _uuid = "";
  WebSocketChannel? _channel;

  Future<nts.RegisterResponse> _register() async {
    var request = nts.RegisterRequest();

    var response = await http.post(
      Uri.parse("$_tmsAddress/register"),
      body: jsonEncode(request.toJson()),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      return nts.RegisterResponse.fromJson(jsonDecode(response.body));
    } else {
      TmsLogger().e("Failed to register with TMS server: ${response.statusCode}");
      throw Exception("Failed to register with TMS server");
    }
  }

  Future<int> _unregister() async {
    final response = await http.delete(
      Uri.parse("$_tmsAddress/unregister/$_uuid"),
      headers: {
        "X-Client-Id": _uuid,
        "X-Auth-Token": _authToken,
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      return response.statusCode;
    } else {
      TmsLogger().e("Failed to unregister with TMS server: ${response.statusCode}");
      throw Exception("Failed to unregister with TMS server");
    }
  }

  void _listen() async {
    if (!_connected) {
      TmsLogger().e("Not connected to TMS server");
      return;
    }

    try {
      _channel?.stream.listen((event) {
        try {
          var message = jsonDecode(event);
          TmsLogger().i("Received message: $message");
        } catch (e) {
          TmsLogger().e("Error: $e");
        }
      });
    } catch (e) {
      TmsLogger().e("Error: $e");
    }
  }

  Future<void> connect() async {
    TmsLogger().i("Connecting to TMS server...");
    var registerResponse = await _register();
    _connectedUrl = registerResponse.url;
    _authToken = registerResponse.authToken;
    _uuid = registerResponse.uuid;

    _channel = WebSocketChannel.connect(Uri.parse(_connectedUrl));
    _channel?.ready.then((_) {
      _connected = true;
      _listen();
    });
  }

  Future<void> disconnect() async {
    TmsLogger().i("Disconnecting from TMS server...");
    _connected = false;
    _channel?.sink.close();
  }
}
