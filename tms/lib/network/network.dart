import 'dart:io';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms/constants.dart';
import 'package:tms/network/ws.dart';

enum NetworkConnectionState { disconnected, connectedNoPulse, connected }

// Pure static network class
class Network {
  static final Future<SharedPreferences> _localStorage = SharedPreferences.getInstance();

  static Future<void> setState(NetworkConnectionState state) async {
    await _localStorage.then((value) async {
      await value.setString(store_connection_state, EnumToString.convertToString(state));
    });
  }

  static Future<NetworkConnectionState> getState() async {
    try {
      var stateString = await _localStorage.then((value) => value.getString(store_connection_state));
      if (stateString != null) {
        var state = EnumToString.fromString(NetworkConnectionState.values, stateString);
        if (state != null) {
          return state;
        }
      }
    } catch (e) {
      return NetworkConnectionState.disconnected;
    }

    return NetworkConnectionState.disconnected;
  }

  static Future<void> setServerIP(String ip) async {
    try {
      await _localStorage.then((value) async => await value.setString(store_serverIP, ip));
    } catch (e) {
      throw Exception("Failed to set server ip");
    }
  }

  static Future<String> getServerIP() async {
    try {
      var storage = await _localStorage;
      return storage.getString(store_serverIP).toString();
    } catch (e) {
      throw Exception("Failed to get server ip from storage");
    }
  }

  static Future<void> connect() async {
    await NetworkWebSocket.connect(await getServerIP());
  }

  // Get the pulse of the server, returns the status of the connection
  static Future<NetworkConnectionState> getPulse() async {
    try {
      var serverIP = await getServerIP();
      if (serverIP.isEmpty || await getState() == NetworkConnectionState.disconnected) {
        await setState(NetworkConnectionState.disconnected);
      } else {
        final response = await http.get(Uri.parse("http://$serverIP:$requestPort/requests/pulse"));
        if (response.statusCode == 200) {
          await setState(NetworkConnectionState.connected);
        } else {
          await setState(NetworkConnectionState.connectedNoPulse);
        }
      }
    } catch (e) {
      await setState(NetworkConnectionState.connectedNoPulse);
    }

    return await getState();
  }

  // Find Server
  static Future<NetworkConnectionState> findServer() async {
    String ip = await getServerIP(); // set to the existing ip (local storage)
    if (kIsWeb) {
      var host = Uri.base.origin;

      if (host.isNotEmpty) {
        var addr = host.split('http://')[1];
        ip = addr.split(':')[0].isNotEmpty ? addr.split(':')[0] : '';
        await setState(ip.isNotEmpty ? NetworkConnectionState.connectedNoPulse : NetworkConnectionState.disconnected);
      }
    } else {
      const String name = mdnsName;
      final MDnsClient client = MDnsClient();
      await client.start();
      await for (final PtrResourceRecord ptr in client.lookup<PtrResourceRecord>(ResourceRecordQuery.serverPointer(name))) {
        await for (final SrvResourceRecord srv in client.lookup<SrvResourceRecord>(ResourceRecordQuery.service(ptr.domainName))) {
          final String bundleId = ptr.domainName;
          await for (final IPAddressResourceRecord addr in client.lookup<IPAddressResourceRecord>(ResourceRecordQuery.addressIPv4(srv.target))) {
            ip = addr.address.address.isNotEmpty ? addr.address.address : '';
            await setState(ip.isNotEmpty ? NetworkConnectionState.connectedNoPulse : NetworkConnectionState.disconnected);
          }
        }
      }
    }

    await setServerIP(ip);
    return await getPulse();
  }
}
