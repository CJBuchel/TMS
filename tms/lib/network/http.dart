import 'dart:convert';
import 'dart:io';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms/constants.dart';
import 'package:tms/network/security.dart';
import 'package:tms/schema/tms-schema.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

enum NetworkHttpConnectionState { disconnected, connectedNoPulse, connected }

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

  // Register with the server, provides uuid and key. Server returns the url and it's own key
  Future<RegisterResponse> register(String addr) async {
    var keyPair = await NetworkSecurity.generateKeyPair();
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
      case HttpStatus.ok: // Status OK
        NetworkSecurity.setKeys(keyPair);
        return RegisterResponse.fromJson(await NetworkSecurity.decryptMessage(response.body, key: keyPair.privateKey));

      case HttpStatus.alreadyReported: // Status Already Reported/ID Already Registered
        var message = RegisterResponse.fromJson(await NetworkSecurity.decryptMessage(response.body, key: keyPair.privateKey));
        // Check the network integrity
        switch (await getPulseIntegrity(addr)) {
          case true:
            // Pulse is good, integrity is good. Use existing settings (don't set keys)
            return message;
          case false:
            // Pulse is bad, delete the existing uuid and start again
            await http.delete(Uri.parse('http://$addr:$requestPort/requests/register/$uuid'));
            return register(addr); // return with a new registration
          default:
            throw Exception("Failed to determine pulse integrity");
        }
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

  // Checks integrity of pulse using encryption back response
  // It's considered a pulse but in reality it checks the integrity of the connection, not the availability of the connection
  // So it returns a true or false statement instead of stateful suggestion of the current connection "setState()"
  Future<bool> getPulseIntegrity(String addr) async {
    try {
      if (await getPulse(addr) == NetworkHttpConnectionState.connected) {
        // generate random uuid to send to the server and check against
        var random_uuid = const Uuid().v4();
        var message = IntegrityMessage(message: random_uuid);

        // Encrypt and send
        var encrypted_m = await NetworkSecurity.encryptMessage(message.toJson());
        final response = await http.post(
          Uri.parse('http://$addr:$requestPort/requests/pulse_integrity'),
          body: encrypted_m,
        );

        // If the response is good (200) then decrypt the message and check if it's the same as the one sent before
        if (response.statusCode == HttpStatus.ok) {
          var decrypted_m = IntegrityMessage.fromJson(await NetworkSecurity.decryptMessage(response.body));
          if (decrypted_m.message == random_uuid) {
            return true;
          }
        }
      }
    } catch (e) {
      return false;
    }

    return false; // if it falls through returns false
  }
}
