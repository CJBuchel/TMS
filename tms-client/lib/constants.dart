import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Style constants (dark)
const primaryColorDark = Color(0xFF2697FF);
const secondaryColorDark = Color(0xFF2A2D3E);
const bgColorDark = Color(0xFF212332);
const bgSecondaryColorDark = Color(0xFF2A2D3E);
const primaryRowColorDark = Color(0xFF355558);
const secondaryRowColorDark = Color(0xFF707279);
const secondaryCardColorDark = Color.fromARGB(255, 69, 80, 100);

// Style constants (light)
const primaryColorLight = Color(0xFF2697FF);
const secondaryColorLight = Color(0xFF2A2D3E);
const bgColorLight = Color(0xFFFFFFFF);
const bgSecondaryColorLight = Color(0xFFEEEEEE);
const primaryRowColorLight = Color(0xFFCBE2F5);
const secondaryRowColorLight = Color(0xFFD8D8D8);
const secondaryCardColorLight = Color.fromRGBO(225, 245, 254, 1);

// variable constants
const serverPort = 8080;
const mdnsName = '_mdns_tms_server._udp.local';

// shared preferences
class TmsLocalStorage {
  static final TmsLocalStorage _instance = TmsLocalStorage._internal();
  SharedPreferences? _ls;
  TmsLocalStorage._internal();

  factory TmsLocalStorage() {
    return _instance;
  }

  Future<void> init() async {
    if (_instance._ls == null) {
      _ls = await SharedPreferences.getInstance();
    }
  }

  bool get isReady => _ls != null ? true : false;

  set serverHttpProtocol(String value) => _ls?.setString("serverHttpProtocol", value);
  String get serverHttpProtocol => _ls?.getString("serverHttpProtocol") ?? "https";

  set serverIp(String value) => _ls?.setString("serverIp", value);
  String get serverIp => _ls?.getString("serverIp") ?? ""; // should be localhost

  String get serverAddress => "$serverHttpProtocol://$serverIp:$serverPort";

  set wsConnectionString(String value) => _ls?.setString("wsConnectionString", value);
  String get wsConnectionString => _ls?.getString("wsConnectionString") ?? "";

  set authToken(String value) => _ls?.setString("authToken", value);
  String get authToken => _ls?.getString("authToken") ?? "";

  set uuid(String value) => _ls?.setString("uuid", value);
  String get uuid => _ls?.getString("uuid") ?? "";

  set isDarkTheme(bool value) => _ls?.setBool("isDarkTheme", value);
  bool get isDarkTheme => _ls?.getBool("isDarkTheme") ?? true;
}
