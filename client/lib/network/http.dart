import 'dart:convert';
import 'dart:io';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms/constants.dart';
import 'package:tms/network/auth.dart';
import 'package:tms/network/security.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

enum NetworkHttpConnectionState { disconnected, connectedNoPulse, connected }

class NetworkHttp {
  final Future<SharedPreferences> _localStorage = SharedPreferences.getInstance();
  static ValueNotifier<NetworkHttpConnectionState> httpState = ValueNotifier<NetworkHttpConnectionState>(NetworkHttpConnectionState.disconnected);

  Future<void> setState(NetworkHttpConnectionState state) async {
    httpState.value = state;
    await _localStorage.then((value) => value.setString(storeHttpConnectionState, EnumToString.convertToString(state)));
  }

  Future<NetworkHttpConnectionState> getState() async {
    try {
      var stateString = await _localStorage.then((value) => value.getString(storeHttpConnectionState));
      var state = EnumToString.fromString(NetworkHttpConnectionState.values, stateString!);
      if (state != null) {
        httpState.value = state;
        return state;
      } else {
        httpState.value = NetworkHttpConnectionState.disconnected;
        return NetworkHttpConnectionState.disconnected;
      }
    } catch (e) {
      httpState.value = NetworkHttpConnectionState.disconnected;
      return NetworkHttpConnectionState.disconnected;
    }
  }

  Future<void> setConnectUrl(String url) async {
    await _localStorage.then((value) => value.setString(storeWsConnectUrl, url));
  }

  Future<String> getConnectUrl() async {
    try {
      var url = await _localStorage.then((value) => value.getString(storeWsConnectUrl));
      if (url != null) {
        return url;
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  Future<void> setUuid(String uuid) async {
    await _localStorage.then((value) => value.setString(storeNtUuid, uuid));
  }

  Future<String> getUuid() async {
    try {
      var uuid = await _localStorage.then((value) => value.getString(storeNtUuid));
      if (uuid != null) {
        return uuid;
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  // Checks pulse of server. (Generic ping with status back)
  Future<NetworkHttpConnectionState> getPulse(String addr) async {
    try {
      if (addr.isEmpty || await getState() == NetworkHttpConnectionState.disconnected) {
        await setState(NetworkHttpConnectionState.disconnected);
      } else {
        // check pulse
        final response = await getRawPulse(addr);
        switch (response.statusCode) {
          case 200:
            await setState(NetworkHttpConnectionState.connected);
            break;
          default:
            await setState(NetworkHttpConnectionState.connectedNoPulse);
        }
      }
    } catch (e) {
      await setState(NetworkHttpConnectionState.connectedNoPulse);
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
        var randomUuid = const Uuid().v4();
        var uuid = await getUuid();
        var message = IntegrityMessage(message: randomUuid);

        // Encrypt and send
        var encryptedM = await NetworkSecurity.encryptMessage(message.toJson());
        final response = await http.post(
          Uri.parse('http://$addr:$requestPort/requests/pulse_integrity/$uuid'),
          body: encryptedM,
        );

        // If the response is good (200) then decrypt the message and check if it's the same as the one sent before
        if (response.statusCode == HttpStatus.ok) {
          var decryptedM = IntegrityMessage.fromJson(await NetworkSecurity.decryptMessage(response.body));
          if (decryptedM.message == randomUuid) {
            return true;
          }
        }
      }
    } catch (e) {
      // Logger().w("Pulse Error");
      return false;
    }

    // Logger().w("Pulse Integrity Error");
    return false; // if it falls through returns false
  }

  // Unregister from the server (given that the uuid is correct)
  Future<http.Response> unregister(String addr) async {
    var uuid = await getUuid();
    return await http.delete(Uri.parse('http://$addr:$requestPort/requests/register/$uuid'));
  }

  // Register with the server, provides uuid and key. Server returns the url and it's own key
  Future<Tuple2<String, String>> register(String addr) async {
    var keyPair = await NetworkSecurity.generateKeyPair();
    var uuid = await getUuid();

    // If we're on the web always generate a new uuid
    // (the web can have multiple tabs, we want every tab to be a different client to stop confusion and bugs)
    // Yes, I'm aware this causes a high amount of unused uuids to be generated,
    // Dw, the server is specifically built to handle this with stale connection that exceed 5 minutes.
    // I thought of it :)
    if (uuid.isEmpty || kIsWeb) {
      await setUuid(const Uuid().v4()).then((v) async {
        uuid = await getUuid();
      });
    }

    // Create the request
    final request = RegisterRequest(key: keyPair.publicKey, userId: uuid);

    try {
      final response = await http.post(
        Uri.parse('http://$addr:$requestPort/requests/register'),
        body: jsonEncode(request.toJson()),
      );
      var message = RegisterResponse.fromJson(await NetworkSecurity.decryptMessage(response.body, key: keyPair.privateKey));
      String url = "${message.urlScheme}$addr${message.urlPath}";

      switch (response.statusCode) {
        case HttpStatus.ok: // Status OK
          NetworkSecurity.setKeys(keyPair);
          NetworkSecurity.setServerKey(message.key);
          setState(NetworkHttpConnectionState.connected);
          setConnectUrl(url);
          NetworkAuth.login(addr, uuid);
          return Tuple2(url, message.version);

        case HttpStatus.alreadyReported: // Status Already Reported/ID Already Registered
          // Check the network integrity
          switch (await getPulseIntegrity(addr)) {
            case true:
              // Pulse is good, integrity is good. Use existing settings (don't set keys)
              setState(NetworkHttpConnectionState.connected);
              setConnectUrl(url);
              NetworkAuth.login(addr, uuid);
              Logger().i("Already Registered, Keeping Settings");
              return Tuple2(url, message.version);
            case false:
              // Pulse is bad, delete the existing uuid and start again
              Logger().w("Existing Register Unstable, Re-Registering...");
              await unregister(addr);
              return register(addr); // return with a new registration
            default:
              Logger().e("Failed to Determine Pulse Integrity");
              throw Exception("Failed to determine pulse integrity");
          }
        default:
          Logger().e("Failed to Load Register Response");
          await unregister(addr);
          throw Exception("Failed to Load Register Response");
      }
    } catch (e) {
      setState(NetworkHttpConnectionState.disconnected);
      return const Tuple2("", "");
    }
  }

  Future<http.Response> getRawPulse(String addr) async {
    try {
      final response = await http.get(Uri.parse("http://$addr:$requestPort/requests/pulse"));
      return response;
    } catch (e) {
      throw Exception("Could not determine raw pulse response");
    }
  }
}
