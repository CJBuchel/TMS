import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms/generated/infra.dart';

// variable constants
const defaultServerPort = 8080;

abstract class _TmsLocalStorageBase extends ChangeNotifier {
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
class TmsLocalStorageProvider extends _TmsLocalStorageBase {
  static final TmsLocalStorageProvider _instance = TmsLocalStorageProvider._internal();
  TmsLocalStorageProvider._internal();

  factory TmsLocalStorageProvider() {
    return _instance;
  }

  set serverHttpProtocol(String value) => setString("serverHttpProtocol", value);
  String get serverHttpProtocol => getString("serverHttpProtocol") ?? "https";

  set serverPort(int value) => setInt("serverPort", value);
  int get serverPort => getInt("serverPort") ?? defaultServerPort;

  // server ip used for connecting (can be localhost)
  set serverIp(String value) => setString("serverIp", value);
  String get serverIp => getString("serverIp") ?? ""; // should be localhost

  // external ip used for sharing (cannot be localhost)
  set serverExternalIp(String value) => setString("serverExternalIp", value);
  String get serverExternalIp => getString("serverExternalIp") ?? "";

  String get serverAddress => "$serverHttpProtocol://$serverIp:$serverPort";
  String get serverExternalAddress => "$serverHttpProtocol://$serverExternalIp:$serverPort";

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

  set authRoles(List<TmsTreeRole> value) {
    List<String> roles = value.map((e) => e.toJsonString()).toList();
    setStringList("authRoles", roles);
  }

  List<TmsTreeRole> get authRoles {
    List<String>? roles = getStringList("authRoles");
    return roles?.map((e) => TmsTreeRole.fromJsonString(json: e)).toList() ?? [];
  }

  set isLoggedIn(bool value) => setBool("isLoggedIn", value);
  bool get isLoggedIn => getBool("isLoggedIn") ?? false;

  set themeMode(ThemeMode value) => setInt("themeMode", value.index);
  ThemeMode get themeMode => ThemeMode.values[getInt("themeMode") ?? 0]; // default to system theme

  set gameTable(String table) => setString("gameTable", table);
  String get gameTable => getString("gameTable") ?? "";

  set gameReferee(String referee) => setString("gameReferee", referee);
  String get gameReferee => getString("gameReferee") ?? "";
}
