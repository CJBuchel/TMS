import 'dart:convert';
import 'package:tms/schema/tms-schema.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:fast_rsa/fast_rsa.dart';

enum NetworkWebSocketState {
  disconnected,
  connectingEncryption,
  connectingCheck,
  connected,
}

class NetworkWebSocket {
  static NetworkWebSocketState _connectionState = NetworkWebSocketState.disconnected;
  static final _uuid = const Uuid().v4();
  static late WebSocketChannel _channel;
  static late KeyPair _keyPair;
  static late String _serverKey;

  static Future<KeyPair> generateKeyPair() async {
    _connectionState = NetworkWebSocketState.connectingEncryption;
    return await RSA.generate(1024);
  }

  static Future<RegisterResponse> register(String addr) async {
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

  static Future<bool> checkConnection() async {
    // print(_keyPair.publicKey);
    SocketMessage message = SocketMessage(message: "The Data is real extreme", topic: "Event");
    var result = await RSA.encryptPKCS1v15(jsonEncode(message.toJson()), _serverKey);
    _channel.sink.add(result);
    return true;
  }

  static void send(SocketMessage message) {
    _channel.sink.add(jsonEncode(message.toJson()));
  }

  static Future<bool> connect(String addr) async {
    var response = await register(addr);
    _serverKey = response.key;
    _channel = WebSocketChannel.connect(Uri.parse(response.url));
    await checkConnection();
    // SocketMessage message = SocketMessage(fromId: _uuid, message: "Hello from client", topic: "hello");
    // send(message);
    return true;
  }

  static void disconnect() async {
    _channel.sink.close();
  }
}
