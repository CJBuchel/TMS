// Static network class for the main application
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:multicast_dns/multicast_dns.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms/constants.dart';
import 'package:tms/network/http.dart';
import 'package:tms/network/security.dart';
import 'package:tms/network/ws.dart';
import 'package:tms/schema/tms-schema.dart';
import 'package:tuple/tuple.dart';

// Static implementation and combined classes of both network protocols
class Network {
  static final NetworkWebSocket _ws = NetworkWebSocket();
  static final NetworkHttp _http = NetworkHttp();
  static final Future<SharedPreferences> _localStorage = SharedPreferences.getInstance();

  static Future<void> setAutoConfig(bool auto) async {
    await _localStorage.then((value) => value.setBool(store_nt_auto_configure, auto));
  }

  static Future<bool> getAutoConfig() async {
    try {
      var auto = await _localStorage.then((value) => value.getBool(store_nt_auto_configure));
      if (auto != null) {
        return auto;
      } else {
        return true;
      }
    } catch (e) {
      return true;
    }
  }

  static Future<void> setServerIP(String ip) async {
    await _localStorage.then((value) => value.setString(store_nt_serverIP, ip));
  }

  static Future<String> getServerIP() async {
    try {
      var ip = await _localStorage.then((value) => value.getString(store_nt_serverIP));
      if (ip != null) {
        return ip;
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  // Get the overall state of the network, combined tuple containing both the protocol states
  static Future<Tuple3<NetworkHttpConnectionState, NetworkWebSocketState, SecurityState>> getStates() async {
    return Tuple3(await _http.getState(), _ws.getState(), await NetworkSecurity.getState());
  }

  // Try to connect to server and test endpoint
  static Future<void> connect() async {
    // Must register first before connecting to websocket
    await _http.register(await getServerIP()).then((registerResponse) async {
      await _ws.connect(registerResponse.url);
    });
  }

  // The opposite process of the connection
  static Future<void> disconnect() async {
    await _ws.disconnect();
    // await _ws.disconnect().then((v) async => {await _http.unregister(await getServerIP())});
  }

  static Future<void> reset() async {
    await _http.setState(NetworkHttpConnectionState.disconnected);
    _ws.setState(NetworkWebSocketState.disconnected);
    if (!kIsWeb) {
      disconnect();
    }
  }

  // Find the server using web address. (The web does not support mDNS)
  static Future<String> _findServerWeb(String ip) async {
    var host = Uri.base.origin;
    if (host.isNotEmpty) {
      var addr = host.split('http://')[1];
      ip = addr.split(':')[0].isNotEmpty ? addr.split(':')[0] : '';
    }

    return ip;
  }

  // Find the server using the Multicast DNS name
  static Future<String> _findServerMDNS(String ip) async {
    const String name = mdnsName;
    final MDnsClient client = MDnsClient();
    await client.start();
    await for (final PtrResourceRecord ptr in client.lookup<PtrResourceRecord>(ResourceRecordQuery.serverPointer(name))) {
      await for (final SrvResourceRecord srv in client.lookup<SrvResourceRecord>(ResourceRecordQuery.service(ptr.domainName))) {
        final String bundleId = ptr.domainName;
        await for (final IPAddressResourceRecord addr in client.lookup<IPAddressResourceRecord>(ResourceRecordQuery.addressIPv4(srv.target))) {
          ip = addr.address.address.isNotEmpty ? addr.address.address : '';
        }
      }
    }

    client.stop();

    return ip;
  }

  // Find the server and test the address
  static Future<bool> findServer() async {
    var states = await getStates();
    if (states.item1 != NetworkHttpConnectionState.connected && states.item2 != NetworkWebSocketState.connected) {
      String ip = await getServerIP();
      if (kIsWeb) {
        ip = await _findServerWeb(ip);
      } else {
        ip = await _findServerMDNS(ip);
      }

      // Test the ip with it's own raw sub pulse
      if (ip.isNotEmpty) {
        try {
          var res = await _http.getRawPulse(ip);
          if (res.statusCode == HttpStatus.ok) {
            await setServerIP(ip);
            return true;
          }
        } catch (e) {
          return false;
        }
      }
    }

    return false;
  }

  // Check the connection, reconnect on fail (returns false for bad check)
  static Future<bool> checkConnection() async {
    // Check the pulse of the server
    bool integrity = await _http.getPulseIntegrity(await getServerIP());
    var httpState = await _http.getState();
    var wsState = _ws.getState();
    // After the pulse has completed check the websocket state
    if (httpState != NetworkHttpConnectionState.connected || wsState != NetworkWebSocketState.connected || !integrity) {
      print("Trying reconnect");
      // If either of the protocols cannot connect, reconnect.
      if (wsState != NetworkWebSocketState.connected && httpState == NetworkHttpConnectionState.connected) {
        print("http fine, trying ws");
        // If the websocket is only disconnected (timeout issues or closing the app) then do an integrity check and reconnect ws
        var goodIntegrity = await _http.getPulseIntegrity(await getServerIP());
        if (goodIntegrity) {
          print("ws good, connecting");
          _ws.connect(await _http.getConnectUrl());
        } else {
          print("ws bad reconnected");
          await connect();
        }
      } else {
        // Fully reconnect
        print("full reconnect");
        await connect();
      }

      // Determine the states and check again
      var states = await getStates();
      if (states.item1 == NetworkHttpConnectionState.connected &&
          states.item2 == NetworkWebSocketState.connected &&
          states.item3 == SecurityState.secure) {
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  // Tuple3 (good access, res status code, res message)
  static Future<Tuple3<bool, int, dynamic>> serverGet(String route) async {
    Tuple3<bool, int, String> response = const Tuple3(false, 0, "");
    var st = await getStates();
    if (st.item1 == NetworkHttpConnectionState.connected && st.item3 == SecurityState.secure) {
      final serverIp = await getServerIP();
      final uuid = await _http.getUuid();
      try {
        final serverRes = await http.get(Uri.parse('http://$serverIp:$requestPort/requests/$route/$uuid'));
        var decryptedM = await NetworkSecurity.decryptMessage(serverRes.body);
        response = Tuple3(true, serverRes.statusCode, decryptedM);
      } catch (e) {
        _http.setState(NetworkHttpConnectionState.disconnected);
      }
    }

    return response;
  }

  // Tuple3 (good access, res status code, res message)
  static Future<Tuple3<bool, int, dynamic>> serverPost(String route, dynamic json) async {
    Tuple3<bool, int, String> response = const Tuple3(false, 0, "");
    var st = await getStates();
    if (st.item1 == NetworkHttpConnectionState.connected && st.item3 == SecurityState.secure) {
      print("Inside serverPost");
      final serverIp = await getServerIP();
      final uuid = await _http.getUuid();
      try {
        print("Encrypting");
        var encryptedM = await NetworkSecurity.encryptMessage(json);
        print("Encrypted");
        print("Post Url http://$serverIp:$requestPort/requests/$route/$uuid");
        final serverRes = await http.post(
          Uri.parse('http://$serverIp:$requestPort/requests/$route/$uuid'),
          body: encryptedM,
        );
        print("Posted");
        print("Res body: ${serverRes.body}");
        var decryptedM = await NetworkSecurity.decryptMessage(serverRes.body);
        print("Decrypted m");
        response = Tuple3(true, serverRes.statusCode, decryptedM);
      } catch (e) {
        _http.setState(NetworkHttpConnectionState.disconnected);
      }
    }

    return response;
  }

  // Tuple3 (good access, res status code, res message)
  static Future<Tuple3<bool, int, dynamic>> serverDelete(String route, dynamic json) async {
    Tuple3<bool, int, String> response = const Tuple3(false, 0, "");
    var st = await getStates();
    if (st.item1 == NetworkHttpConnectionState.connected && st.item3 == SecurityState.secure) {
      final serverIp = await getServerIP();
      final uuid = await _http.getUuid();
      try {
        var encryptedM = await NetworkSecurity.encryptMessage(json);
        final serverRes = await http.delete(
          Uri.parse('http://$serverIp:$requestPort/requests/$route/$uuid'),
          body: encryptedM,
        );
        var decryptedM = await NetworkSecurity.decryptMessage(serverRes.body);
        response = Tuple3(true, serverRes.statusCode, decryptedM);
      } catch (e) {
        _http.setState(NetworkHttpConnectionState.disconnected);
      }
    }

    return response;
  }
}
