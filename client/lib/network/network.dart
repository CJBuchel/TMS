// Static network class for the main application
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms/network/timeout_tracker.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/constants.dart';
import 'package:tms/network/http.dart';
import 'package:tms/network/security.dart';
import 'package:tms/network/ws.dart';
import 'package:tuple/tuple.dart';

// Static implementation and combined classes of both network protocols
class Network {
  static final NetworkWebSocket _ws = NetworkWebSocket();
  static final NetworkHttp _http = NetworkHttp();
  static final Future<SharedPreferences> _localStorage = SharedPreferences.getInstance();
  static ValueNotifier<String> serverVersion = ValueNotifier<String>("");

  static Future<void> setAutoConfig(bool auto) async {
    await _localStorage.then((value) => value.setBool(storeNtAutoConfigure, auto));
  }

  static Future<bool> getAutoConfig() async {
    try {
      var auto = await _localStorage.then((value) => value.getBool(storeNtAutoConfigure));
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
    await _localStorage.then((value) => value.setString(storeNtServerIP, ip));
  }

  static Future<String> getServerIP() async {
    try {
      var ip = await _localStorage.then((value) => value.getString(storeNtServerIP));
      if (ip != null) {
        return ip;
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  static Future<void> setServerVersion(String version) async {
    serverVersion.value = version;
    await _localStorage.then((value) => value.setString(storeNtServerVersion, version));
  }

  static Future<String> getServerVersion() async {
    try {
      var version = await _localStorage.then((value) => value.getString(storeNtServerVersion));
      if (version != null && version.isNotEmpty) {
        serverVersion.value = version;
        return version;
      } else {
        serverVersion.value = "";
        return "N/A";
      }
    } catch (e) {
      serverVersion.value = "";
      return "N/A";
    }
  }

  // Get the overall state of the network, combined tuple containing both the protocol states
  static Future<Tuple3<NetworkHttpConnectionState, NetworkWebSocketState, SecurityState>> getStates() async {
    return Tuple3(await _http.getState(), _ws.getState(), await NetworkSecurity.getState());
  }

  static Future<bool> isConnected() async {
    var s = await getStates();
    return (s.item1 == NetworkHttpConnectionState.connected && s.item2 == NetworkWebSocketState.connected && s.item3 == SecurityState.secure);
  }

  // Try to connect to server and test endpoint
  static Future<void> connect() async {
    // Must register first before connecting to websocket
    String ip = await getServerIP();
    await _http.register(ip).then((res) async {
      setServerVersion(res.item2);
      await _ws.connect(res.item1);
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
    Logger().w("Finding Server...");
    const String name = mdnsName;
    final MDnsClient client = MDnsClient();
    await client.start();
    await for (final PtrResourceRecord ptr in client.lookup<PtrResourceRecord>(ResourceRecordQuery.serverPointer(name))) {
      await for (final SrvResourceRecord srv in client.lookup<SrvResourceRecord>(ResourceRecordQuery.service(ptr.domainName))) {
        await for (final IPAddressResourceRecord addr in client.lookup<IPAddressResourceRecord>(ResourceRecordQuery.addressIPv4(srv.target))) {
          Logger().i("Found Match: ${addr.address.address}");
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
    var httpState = await _http.getState();
    var wsState = _ws.getState();
    // After the pulse has completed check the websocket state
    if (httpState != NetworkHttpConnectionState.connected || wsState != NetworkWebSocketState.connected) {
      // Logger().w("No Server Connection");
      // If either of the protocols cannot connect, reconnect.
      if (wsState != NetworkWebSocketState.connected && httpState == NetworkHttpConnectionState.connected) {
        // Logger().i("HTTP Connected , Testing Integrity");
        // If the websocket is only disconnected (timeout issues or closing the app) then do an integrity check and reconnect ws
        var goodIntegrity = await _http.getPulseIntegrity(await getServerIP());
        if (goodIntegrity) {
          // Logger().i("Server Integrity Holding, Connecting WS...");
          _ws.connect(await _http.getConnectUrl());
        } else {
          // Logger().w("Websocket Could Not Reconnect (Starting Full Reconnect...)");
          await connect();
        }
      } else {
        // Fully reconnect
        Logger().i("Starting Full Reconnect");
        await connect();
      }

      // Determine the states and check again
      var states = await getStates();
      if (states.item1 == NetworkHttpConnectionState.connected &&
          states.item2 == NetworkWebSocketState.connected &&
          states.item3 == SecurityState.secure) {
        Logger().i("Reconnection Successful");
        return true;
      } else {
        return false;
      }
    } else {
      return true;
    }
  }

  // Tuple3 (good access, res status code, res message)
  static Future<Tuple3<bool, int, Map<String, dynamic>>> _serverGet(String route) async {
    var timeout = OperationTimeoutTracker(const Duration(seconds: 10));
    Tuple3<bool, int, Map<String, dynamic>> response = const Tuple3(false, 0, {});
    var st = await getStates();
    if (st.item1 == NetworkHttpConnectionState.connected && st.item3 == SecurityState.secure) {
      final serverIp = await getServerIP();
      final uuid = await _http.getUuid();
      try {
        if (timeout.isTimedOut) {
          return const Tuple3(false, HttpStatus.requestTimeout, {});
        }
        final serverRes = await http.get(Uri.parse('http://$serverIp:$requestPort/requests/$route/$uuid'));
        if (serverRes.body.isNotEmpty) {
          var decryptedM = await NetworkSecurity.decryptMessage(serverRes.body);
          response = Tuple3(true, serverRes.statusCode, decryptedM);
        } else {
          response = Tuple3(true, serverRes.statusCode, {});
        }
      } catch (e) {
        Logger().e("Server Response Error $e");
        _http.setState(NetworkHttpConnectionState.disconnected);
      }
    }

    return response;
  }

  static Future<Tuple3<bool, int, Map<String, dynamic>>> serverGet(String route) async {
    return await _serverGet(route).timeout(const Duration(seconds: 15), onTimeout: () {
      return const Tuple3(false, HttpStatus.requestTimeout, {});
    });
  }

  // Tuple3 (good access, res status code, res message in json)
  static Future<Tuple3<bool, int, Map<String, dynamic>>> _serverPost(String route, dynamic json) async {
    var timeout = OperationTimeoutTracker(const Duration(seconds: 10));
    Tuple3<bool, int, Map<String, dynamic>> response = const Tuple3(false, 0, {});
    var st = await getStates();
    if (st.item1 == NetworkHttpConnectionState.connected && st.item3 == SecurityState.secure) {
      final serverIp = await getServerIP();
      final uuid = await _http.getUuid();
      try {
        var encryptedM = await NetworkSecurity.encryptMessage(json);
        if (timeout.isTimedOut) {
          return const Tuple3(false, HttpStatus.requestTimeout, {});
        }
        final serverRes = await http.post(Uri.parse('http://$serverIp:$requestPort/requests/$route/$uuid'), body: encryptedM);
        if (serverRes.body.isNotEmpty) {
          var decryptedM = await NetworkSecurity.decryptMessage(serverRes.body);
          response = Tuple3(true, serverRes.statusCode, decryptedM);
        } else {
          response = Tuple3(true, serverRes.statusCode, {});
        }
      } catch (e) {
        Logger().e("Server Response Error $e");
        _http.setState(NetworkHttpConnectionState.disconnected);
      }
    }

    return response;
  }

  static Future<Tuple3<bool, int, Map<String, dynamic>>> serverPost(String route, dynamic json) async {
    return await _serverPost(route, json).timeout(const Duration(seconds: 15), onTimeout: () {
      return const Tuple3(false, HttpStatus.requestTimeout, {});
    });
  }

  // Tuple3 (good access, res status code, res message)
  static Future<Tuple3<bool, int, Map<String, dynamic>>> _serverDelete(String route, dynamic json) async {
    var timeout = OperationTimeoutTracker(const Duration(seconds: 10));
    Tuple3<bool, int, Map<String, dynamic>> response = const Tuple3(false, 0, {});
    var st = await getStates();
    if (st.item1 == NetworkHttpConnectionState.connected && st.item3 == SecurityState.secure) {
      final serverIp = await getServerIP();
      final uuid = await _http.getUuid();
      try {
        var encryptedM = await NetworkSecurity.encryptMessage(json);
        if (timeout.isTimedOut) {
          return const Tuple3(false, HttpStatus.requestTimeout, {});
        }
        final serverRes = await http.delete(Uri.parse('http://$serverIp:$requestPort/requests/$route/$uuid'), body: encryptedM);
        if (serverRes.body.isNotEmpty) {
          var decryptedM = await NetworkSecurity.decryptMessage(serverRes.body);
          response = Tuple3(true, serverRes.statusCode, decryptedM);
        } else {
          response = Tuple3(true, serverRes.statusCode, {});
        }
      } catch (e) {
        Logger().e("Server Response Error $e");
        _http.setState(NetworkHttpConnectionState.disconnected);
      }
    }
    return response;
  }

  static Future<Tuple3<bool, int, Map<String, dynamic>>> serverDelete(String route, dynamic json) async {
    return await _serverDelete(route, json).timeout(const Duration(seconds: 15), onTimeout: () {
      return const Tuple3(false, HttpStatus.requestTimeout, {});
    });
  }

  // publish a message to the pub sub network
  static Future<void> publish(SocketMessage message) async {
    await _ws.publish(message);
  }

  // Subscribe to a topic and run the onEvent function when the topic is received.
  // Be careful using this method as it does not unsubscribe when the widget is disposed.
  // This can be problematic when dealing with topics that share the same name, keeping track of which function
  // to unsubscribe to is left to the user
  // Suggest using the auto subscribe mixin for stateful widgets
  static Function(SocketMessage) subscribe(String topic, Function(SocketMessage) onEvent) {
    return _ws.subscribe(topic, onEvent);
  }

  // unsubscribe the function using the topic and the reference to the onEvent function returned from the subscribe method
  static void unsubscribe(String topic, Function(SocketMessage) onEvent) {
    _ws.unsubscribe(topic, onEvent);
  }
}
