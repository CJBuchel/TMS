import 'dart:convert';
import 'package:flutter/material.dart';
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
  final _uuid = const Uuid().v4();
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
    final request = RegisterRequest(key: _keyPair.publicKey, userId: _uuid);
    final response = await http.post(Uri.parse('http://$addr:2121/register'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()));
    if (response.statusCode == 200) {
      return RegisterResponse.fromJson(jsonDecode(response.body));
    } else {
      await http.delete(Uri.parse('http://localhost:2121/register/$_uuid'));
      throw Exception("Failed to load register response");
    }
  }

  // static Future<bool> checkConnection() async {
  //   // print(_keyPair.publicKey);
  //   SocketMessage message = SocketMessage(fromId: _uuid, message: "Ping", topic: "Ping");
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
    var response = await register(addr);
    _serverKey = response.key;
    _channel = WebSocketChannel.connect(Uri.parse(response.url));
    _connectionState = NetworkWebSocketState.connected;
  }

  void disconnect() async {
    _channel.sink.close();
  }
}
