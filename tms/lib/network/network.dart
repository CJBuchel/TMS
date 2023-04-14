import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms/constants.dart';
import 'package:tms/network/ws.dart';

enum NetworkConnectionState { disconnected, connectedNoPulse, connected }

// Pure static network class
class Network {
  static NetworkConnectionState _connectionState = NetworkConnectionState.disconnected;
  static final Future<SharedPreferences> _localStorage = SharedPreferences.getInstance();
  static NetworkWebSocket _websocket = NetworkWebSocket();

  static Future<void> connect() async {
    await _websocket.connect(await getServerIP());
  }

  static NetworkWebSocketState getWebsocketState() {
    return _websocket.getState();
  }

  static void setServerIP(String ip) {
    try {
      _localStorage.then((value) => value.setString(serverIP, ip));
    } catch (e) {
      print(e);
    }
  }

  static Future<String> getServerIP() async {
    try {
      var storage = await _localStorage;
      return storage.getString(serverIP).toString();
    } catch (e) {
      print(e);
      return '';
    }
  }

  static NetworkConnectionState getConnectionState() {
    return _connectionState;
  }

  // Get the pulse of the server, returns true if status is ok
  static Future<NetworkConnectionState> getPulse() async {
    try {
      var serverIP = await getServerIP();
      final response = await http.get(Uri.parse("http://$serverIP:$commsPort/pulse"));
      if (response.statusCode == 200) {
        _connectionState = NetworkConnectionState.connected;
      } else {
        _connectionState = NetworkConnectionState.connectedNoPulse;
      }
    } catch (e) {
      print(e);
      _connectionState = NetworkConnectionState.connectedNoPulse;
    }

    return _connectionState;
  }

  // Find Server
  static Future<NetworkConnectionState> findServer() async {
    String ip = '';
    if (kIsWeb) {
      var host = Uri.base.origin;
      print(host);
      if (host.isNotEmpty) {
        var addr = host.split('http://')[1];
        ip = addr.split(':')[0].isNotEmpty ? addr.split(':')[0] : '';
        _connectionState = ip.isNotEmpty ? NetworkConnectionState.connectedNoPulse : NetworkConnectionState.disconnected;
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
            _connectionState = ip.isNotEmpty ? NetworkConnectionState.connectedNoPulse : NetworkConnectionState.disconnected;
          }
        }
      }
    }

    _localStorage.then((value) => value.setString(serverIP, ip));
    if (_connectionState != NetworkConnectionState.disconnected) {
      return await getPulse();
    } else {
      return _connectionState;
    }
  }
}
