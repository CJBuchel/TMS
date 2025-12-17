import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tms_client/helpers/local_storage.dart';

part 'network_config_provider.g.dart';

@riverpod
class ServerIp extends _$ServerIp {
  static const String _key = 'server_address';
  static const String _defaultIp = '127.0.0.1';

  void setIp(String ip) {
    localStorage.setString(_key, ip);
    state = ip;
  }

  String getIp() {
    return state;
  }

  String _getStoredIp() {
    String ip = _defaultIp;
    if (localStorage.containsKey(_key)) {
      ip = localStorage.getString(_key) ?? _defaultIp;
    } else {
      if (kIsWasm || kIsWeb) {
        // use base
        ip = Uri.base.host;
      }
    }

    return ip;
  }

  @override
  String build() {
    return _getStoredIp();
  }
}

// Web Port
@riverpod
class ServerWebPort extends _$ServerWebPort {
  static const String _key = 'server_web_port';
  static const int _defaultPort = 8080;
  void setPort(int port) {
    localStorage.setInt(_key, port);
    state = port;
  }

  int getPort() {
    return state;
  }

  int _getStoredPort() {
    int port = _defaultPort;
    if (localStorage.containsKey(_key)) {
      port = localStorage.getInt(_key) ?? _defaultPort;
    }
    return port;
  }

  @override
  int build() {
    return _getStoredPort();
  }
}

// Api Port
@riverpod
class ServerApiPort extends _$ServerApiPort {
  static const String _key = 'server_api_port';
  static const int _defaultPort = 50051;
  void setPort(int port) {
    localStorage.setInt(_key, port);
    state = port;
  }

  int getPort() {
    return state;
  }

  int _getStoredPort() {
    int port = _defaultPort;
    if (localStorage.containsKey(_key)) {
      port = localStorage.getInt(_key) ?? _defaultPort;
    }
    return port;
  }

  @override
  int build() {
    return _getStoredPort();
  }
}

// TLS
@riverpod
class Tls extends _$Tls {
  static const String _key = 'tls';
  static const bool _defaultTls = false;
  void setTls(bool tls) {
    localStorage.setBool(_key, tls);
    state = tls;
  }

  bool getTls() {
    return state;
  }

  bool _getStoredTls() {
    bool tls = _defaultTls;
    if (localStorage.containsKey(_key)) {
      tls = localStorage.getBool(_key) ?? _defaultTls;
    }
    return tls;
  }

  @override
  bool build() {
    return _getStoredTls();
  }
}

@riverpod
String serverAddress(Ref ref) {
  final ip = ref.watch(serverIpProvider);
  final port = ref.watch(serverWebPortProvider);
  final tls = ref.watch(tlsProvider);

  final protocol = tls ? 'https' : 'http';
  return '$protocol://$ip:$port';
}
