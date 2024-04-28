import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:echo_tree_flutter/client/broker/broker.dart';
import 'package:echo_tree_flutter/db/db.dart';
import 'package:echo_tree_flutter/logging/logger.dart';
import 'package:echo_tree_flutter/schemas/echoTreeSchema.dart';
import 'package:echo_tree_flutter/utils/blocking_loop_timer.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

enum EchoTreeConnection {
  disconnected,
  connecting,
  connected,
}

class EchoTreeNetworkService {
  String _address = "http://localhost:2121";
  String _authToken = "";
  String _uuid = "";
  String _connectedUrl = "";
  Map<String, String> _roles = {};
  WebSocketChannel? _channel;

  // main connection flag
  ValueNotifier<EchoTreeConnection> _state = ValueNotifier(EchoTreeConnection.disconnected);
  BlockingLoopTimer? _checksumTimer;

  EchoTreeNetworkService() {
    _checksumTimer = BlockingLoopTimer(
      interval: const Duration(seconds: 20),
      callback: _sendChecksumsEvent,
    );
  }

  // getters
  ValueNotifier<EchoTreeConnection> get state => _state;
  String get address => _address;
  String get authToken => _authToken;
  String get uuid => _uuid;
  String get connectedUrl => _connectedUrl;
  Map<String, String> get roles => _roles;

  Future<bool> _checkPulse() async {
    final response = await http.get(Uri.parse("$_address/echo_tree/pulse"));
    return response.statusCode == HttpStatus.ok ? true : false;
  }

  Future<EchoTreeRegisterResponse> register({List<String>? echoTrees}) async {
    // register the client
    List<String> trees = echoTrees ?? [];
    final request = EchoTreeRegisterRequest(echoTrees: trees, roles: roles).toJson();

    final response = await http.post(
      Uri.parse("$address/echo_tree/register"),
      body: jsonEncode(request),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      return EchoTreeRegisterResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to register client ${response.statusCode}');
    }
  }

  Future<int> unregister() async {
    // unregister the client
    final response = await http.delete(
      Uri.parse("$address/echo_tree/register"),
      headers: {
        "X-Client-Id": _uuid,
        "X-Auth-Token": _authToken,
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == HttpStatus.ok) {
      return response.statusCode;
    } else {
      throw Exception('Failed to unregister client ${response.statusCode}');
    }
  }

  Future<int> authenticate(Map<String, String> roles) async {
    // authenticate the client
    final request = EchoTreeRoleAuthenticateRequest(roles: roles).toJson();

    return await http.post(
      Uri.parse("$address/echo_tree/role_auth"),
      body: jsonEncode(request),
      headers: {
        "X-Client-Id": _uuid,
        "X-Auth-Token": _authToken,
        "Content-Type": "application/json",
      },
    ).then((response) {
      if (response.statusCode == HttpStatus.ok) {
        return response.statusCode;
      } else {
        throw Exception('Failed to authenticate client ${response.statusCode}');
      }
    });
  }

  // send checksum event to server (if connected)
  Future<void> _sendChecksumsEvent() async {
    if (_state.value != EchoTreeConnection.connected) return;
    final event = ChecksumEvent(treeChecksums: Database().getChecksums).toJson();
    final message = EchoTreeClientSocketMessage(
      authToken: _authToken,
      messageEvent: EchoTreeClientSocketEvent.CHECKSUM_EVENT,
      message: jsonEncode(event),
    ).toJson();
    _channel?.sink.add(jsonEncode(message));
  }

  void _listen() async {
    try {
      _channel?.stream.listen((event) {
        try {
          final json = jsonDecode(event);
          EchoTreeServerSocketMessage message = EchoTreeServerSocketMessage.fromJson(json);
          EchoTreeMessageBroker().broker(message);

          // reset the checksum timer on a proper data change
          if (message.messageEvent == EchoTreeServerSocketEvent.ECHO_ITEM_EVENT ||
              message.messageEvent == EchoTreeServerSocketEvent.ECHO_TREE_EVENT) {
            _checksumTimer?.reset(); // reset the timer on server response
          }
        } catch (e) {
          EchoTreeLogger().e("Failed socket json decode. Error: $e");
        }
      }, onDone: () {
        EchoTreeLogger().d("Socket connection closed.");
        _state.value = EchoTreeConnection.disconnected;
      }, onError: (error) {
        EchoTreeLogger().e("Socket connection error: $error");
        _state.value = EchoTreeConnection.disconnected;
      });
    } catch (e) {
      EchoTreeLogger().f("Failed to listen to server on: $_connectedUrl");
      throw Exception('Failed to listen to server on: $_connectedUrl');
    }
  }

  Future<bool> connect(
    String dbPath, // e.g /et.kvdb
    String address, {
    Map<String, String>? roles, // e.g {"admin": "password"}
    List<String>? echoTrees,
  }) async {
    // reset values
    _state.value = EchoTreeConnection.connecting;
    _address = address;
    _roles = roles ?? {};

    // check server pulse
    final pulse = await _checkPulse();
    if (pulse) {
      final response = await register();

      // set the client properties
      _connectedUrl = response.url;
      _authToken = response.authToken;
      _uuid = response.uuid;

      // initialize the database
      if (response.hierarchy.isNotEmpty) {
        EchoTreeLogger().i("initializing metadata...");
        Database().init(dbPath, 'metadata', hierarchy: response.hierarchy);
      }

      // startup the websocket
      _channel = WebSocketChannel.connect(Uri.parse(_connectedUrl));
      _channel?.ready.then((_) {
        // startup the receivers and listeners
        _state.value = EchoTreeConnection.connected;
        _listen();
        _checksumTimer?.reset();
      });
      return true;
    } else {
      _state.value = EchoTreeConnection.disconnected;
      EchoTreeLogger().e("Failed to connect to server: $address");
      return false;
    }
  }

  Future<void> disconnect() async {
    _state.value = EchoTreeConnection.disconnected;
    // https://datatracker.ietf.org/doc/html/rfc6455#section-7.4 (i'm being proper XD )
    _channel?.sink.close(1000);
  }

  void subscribe(List<String> treeNames) {
    final event = SubscribeEvent(treeNames: treeNames).toJson();
    final message = EchoTreeClientSocketMessage(
      authToken: _authToken,
      messageEvent: EchoTreeClientSocketEvent.SUBSCRIBE_EVENT,
      message: jsonEncode(event),
    ).toJson();
    _channel?.sink.add(jsonEncode(message));
  }

  void unsubscribe(List<String> treeNames) {
    final event = UnsubscribeEvent(treeNames: treeNames).toJson();
    final message = EchoTreeClientSocketMessage(
      authToken: _authToken,
      messageEvent: EchoTreeClientSocketEvent.UNSUBSCRIBE_EVENT,
      message: jsonEncode(event),
    ).toJson();
    _channel?.sink.add(jsonEncode(message));
  }

  void sendMessage(EchoTreeClientSocketMessage message) {
    _channel?.sink.add(jsonEncode(message.toJson()));
  }
}
