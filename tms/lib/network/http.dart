import 'dart:convert';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:fast_rsa/fast_rsa.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms/constants.dart';
import 'package:tms/network/network.dart';
import 'package:tms/schema/tms-schema.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

enum NetworkHttpConnectionState { disconnected, connectedNoPulse, connected }

enum HttpRegisterState {
  unregistered,
  registered,
  alreadyRegistered,
}

class NetworkHttp {
  final Future<SharedPreferences> _localStorage = SharedPreferences.getInstance();
  Future<void> setState(NetworkHttpConnectionState state) async {
    await _localStorage.then((value) => value.setString(store_http_connection_state, EnumToString.convertToString(state)));
  }

  Future<NetworkHttpConnectionState> getState() async {
    try {
      var stateString = await _localStorage.then((value) => value.getString(store_http_connection_state));
      var state = EnumToString.fromString(NetworkHttpConnectionState.values, stateString!);
      if (state != null) {
        return state;
      } else {
        return NetworkHttpConnectionState.disconnected;
      }
    } catch (e) {
      return NetworkHttpConnectionState.disconnected;
    }
  }

  Future<void> setUuid(String uuid) async {
    await _localStorage.then((value) => value.setString(store_nt_uuid, uuid));
  }

  Future<String> getUuid() async {
    try {
      var uuid = await _localStorage.then((value) => value.getString(store_nt_uuid));
      if (uuid != null) {
        return uuid;
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  Future<void> setKeys(KeyPair keys) async {
    await _localStorage.then((value) => value.setString(store_nt_publicKey, keys.publicKey));
    await _localStorage.then((value) => value.setString(store_nt_privateKey, keys.privateKey));
  }

  Future<KeyPair> getKeys() async {
    try {
      var pubKey = await _localStorage.then((value) => value.getString(store_nt_publicKey));
      var privKey = await _localStorage.then((value) => value.getString(store_nt_privateKey));
      if (pubKey != null && privKey != null) {
        return KeyPair(pubKey, privKey);
      } else {
        return KeyPair("", "");
      }
    } catch (e) {
      return KeyPair("", "");
    }
  }

  Future<void> setServerKey(String key) async {
    await _localStorage.then((value) => value.setString(store_nt_serverKey, key));
  }

  Future<String> getServerKey() async {
    try {
      var key = await _localStorage.then((value) => value.getString(store_nt_serverKey));
      if (key != null) {
        return key;
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  Future<KeyPair> generateKeyPair() async {
    return await RSA.generate(rsa_bit_size);
  }

  // Register with the server, provides uuid and key. Server returns the url and it's own key
  Future<RegisterResponse> register(String addr) async {
    var keyPair = await generateKeyPair();
    var uuid = await getUuid();
    if (uuid.isEmpty) {
      await setUuid(const Uuid().v4()).then((v) async {
        uuid = await getUuid();
      });
    }

    // Create the request
    final request = RegisterRequest(key: keyPair.publicKey, userId: uuid);

    // Get the response
    final response = await http.post(
      Uri.parse('http://$addr:$requestPort/requests/register'),
      body: jsonEncode(request.toJson()),
    );

    switch (response.statusCode) {
      case 200: // Status OK
        return RegisterResponse.fromJson(jsonDecode(response.body));

      // case 208: // Status Already Reported/ID Already Registered
      //   // @TODO, try existing connection with integrity
      //   break;
      default:
        await http.delete(Uri.parse('http://$addr:$requestPort/requests/register/$uuid'));
        throw Exception("Failed to load register response");
    }
  }

  // Checks pulse of server. (Generic ping with status back)
  Future<NetworkHttpConnectionState> getPulse(String addr) async {
    try {
      if (addr.isEmpty || await getState() == NetworkHttpConnectionState.disconnected) {
        await setState(NetworkHttpConnectionState.disconnected);
      } else {
        // check pulse
        final response = await http.get(Uri.parse("http://$addr:$requestPort/requests/pulse"));
        switch (response.statusCode) {
          case 200:
            await setState(NetworkHttpConnectionState.connected);
            break;
          default:
            await setState(NetworkHttpConnectionState.connectedNoPulse);
        }
      }
    } catch (e) {
      await setState(NetworkHttpConnectionState.disconnected);
    }

    return await getState();
  }

  // Checks integrity of pulse using encryption back
  Future<void> getPulseIntegrity(String addr) async {
    try {
      if (await getPulse(addr) == NetworkHttpConnectionState.connected) {
        // Check message integrity
        var random_uuid = const Uuid().v4();
        var message = IntegrityMessage(message: random_uuid);
        final response = await http.post(Uri.parse('http://$addr:$requestPort/requests/pulse_integrity'));
      }
    } catch (e) {}
  }
}
