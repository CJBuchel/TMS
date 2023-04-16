import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/schema/tms-schema.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:fast_rsa/fast_rsa.dart';

enum NetworkWebSocketState {
  disconnected,
  connectingEncryption,
  connected,
}

class NetworkWebSocket {
  NetworkWebSocketState _connectionState = NetworkWebSocketState.disconnected;
  final _userID = const Uuid().v4();
  late WebSocketChannel _channel;
  late KeyPair _keyPair;
  late String _serverKey;

  NetworkWebSocketState getState() {
    return _connectionState;
  }

  Future<KeyPair> generateKeyPair() async {
    _connectionState = NetworkWebSocketState.connectingEncryption;
    return await RSA.generate(2048);
  }

  Future<RegisterResponse> register(String addr) async {
    _keyPair = await generateKeyPair();
    final request = RegisterRequest(key: _keyPair.publicKey, userId: _userID);
    final response = await http.post(Uri.parse('http://$addr:$requestPort/requests/register'), body: jsonEncode(request.toJson()));

    final register_response = RegisterResponse.fromJson(jsonDecode(response.body));
    if (response.statusCode == 200 || response.statusCode == 201) {
      return register_response;
    } else {
      await http.delete(Uri.parse('http://$addr:$requestPort/requests/register/${register_response.uuid}'));
      throw Exception("Failed to load register response");
    }
  }

  // static Future<bool> checkConnection() async {
  //   // print(_keyPair.publicKey);
  //   SocketMessage message = SocketMessage(fromId: _userID, message: "Ping", topic: "Ping");
  //   var result = await RSA.encryptPKCS1v15(jsonEncode(message.toJson()), _serverKey);
  //   _channel.sink.add(result);
  //   print(_keyPair.publicKey);
  //   _channel.stream.listen((event) async {
  //     var decrypted_message = await RSA.decryptPKCS1v15(event, _keyPair.privateKey);
  //     SocketMessage message_from_server = SocketMessage.fromJson(jsonDecode(decrypted_message));
  //     print(message_from_server.message);
  //     return;
  //   });
  //   return true;
  // }

  void send(SocketMessage message) {
    _channel.sink.add(jsonEncode(message.toJson()));
  }

  Future<void> connect(String addr) async {
    late RegisterResponse response;
    try {
      response = await register(addr);
      _serverKey = response.key;
    } catch (e) {
      print("Register Error");
      _connectionState = NetworkWebSocketState.disconnected;
      return;
    }

    try {
      _channel = WebSocketChannel.connect(Uri.parse('ws://$addr:$wsPort/ws/${response.uuid}'));
      _connectionState = NetworkWebSocketState.connected;
    } catch (e) {
      print("Websocket Error detected");
      _connectionState = NetworkWebSocketState.disconnected;
      return;
    }
  }

  void disconnect() async {
    _channel.sink.close();
  }
}
