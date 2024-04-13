import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Style constants (dark)
// const primaryColorDark = Color(0xFF2697FF);
// const secondaryColorDark = Color(0xFF2A2D3E);
// const bgColorDark = Color(0xFF212332);
// const bgSecondaryColorDark = Color(0xFF2A2D3E);
// const primaryRowColorDark = Color(0xFF355558);
// const secondaryRowColorDark = Color(0xFF707279);
// const secondaryCardColorDark = Color.fromARGB(255, 69, 80, 100);

// Style constants (light)
// const primaryColorLight = Color(0xFF2697FF);
// const secondaryColorLight = Color(0xFF2A2D3E);
// const bgColorLight = Color(0xFFFFFFFF);
// const bgSecondaryColorLight = Color(0xFFEEEEEE);
// const primaryRowColorLight = Color(0xFFCBE2F5);
// const secondaryRowColorLight = Color(0xFFD8D8D8);
// const secondaryCardColorLight = Color.fromRGBO(225, 245, 254, 1);

// variable constants
const serverPort = 8080;
const mdnsName = '_mdns_tms_server._udp.local';

abstract class TmsLocalStorageBase extends ChangeNotifier {
  SharedPreferences? _ls;

  Future<void> init() async {
    if (_ls == null) {
      _ls = await SharedPreferences.getInstance();
      notifyListeners();
    }
  }

  bool get isReady => _ls != null ? true : false;

  // ls generic sets and gets
  void setString(String k, String v) {
    _ls?.setString(k, v);
    notifyListeners();
  }

  String? getString(String k) => _ls?.getString(k);

  void setBool(String k, bool v) {
    _ls?.setBool(k, v);
    notifyListeners();
  }

  bool? getBool(String k) => _ls?.getBool(k);

  void setInt(String k, int v) {
    _ls?.setInt(k, v);
    notifyListeners();
  }

  int? getInt(String k) => _ls?.getInt(k);

  void setDouble(String k, double v) {
    _ls?.setDouble(k, v);
    notifyListeners();
  }

  double? getDouble(String k) => _ls?.getDouble(k);

  void setStringList(String k, List<String> v) {
    _ls?.setStringList(k, v);
    notifyListeners();
  }

  List<String>? getStringList(String k) => _ls?.getStringList(k);
}

// shared preferences
class TmsLocalStorageProvider extends TmsLocalStorageBase {
  static final TmsLocalStorageProvider _instance = TmsLocalStorageProvider._internal();
  TmsLocalStorageProvider._internal();

  factory TmsLocalStorageProvider() {
    return _instance;
  }

  set serverHttpProtocol(String value) => setString("serverHttpProtocol", value);
  String get serverHttpProtocol => getString("serverHttpProtocol") ?? "https";

  set serverIp(String value) => setString("serverIp", value);
  String get serverIp => getString("serverIp") ?? ""; // should be localhost

  String get serverAddress => "$serverHttpProtocol://$serverIp:$serverPort";

  set wsConnectionString(String value) => setString("wsConnectionString", value);
  String get wsConnectionString => getString("wsConnectionString") ?? "";

  set authToken(String value) => setString("authToken", value);
  String get authToken => getString("authToken") ?? "";

  set uuid(String value) => setString("uuid", value);
  String get uuid => getString("uuid") ?? "";

  set isDarkTheme(bool value) => setBool("isDarkTheme", value);
  bool get isDarkTheme => getBool("isDarkTheme") ?? true;

  set authUsername(String value) => setString("authUsername", value);
  String get authUsername => getString("authUsername") ?? "";

  set authPassword(String value) => setString("authPassword", value);
  String get authPassword => getString("authPassword") ?? "";

  set authRoles(List<String> value) => setStringList("authRoles", value);
  List<String> get authRoles => getStringList("authRoles") ?? [];

  set isLoggedIn(bool value) => setBool("isLoggedIn", value);
  bool get isLoggedIn => getBool("isLoggedIn") ?? false;

  set themeMode(ThemeMode value) => setInt("themeMode", value.index);
  ThemeMode get themeMode => ThemeMode.values[getInt("themeMode") ?? 0]; // default to system theme
}
