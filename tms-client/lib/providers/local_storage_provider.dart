import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tms/schemas/network_schema.dart';
import 'package:tms/services/local_storage_provider.dart';

// variable constants
const defaultServerPort = 8080;

abstract class _TmsLocalStorageBase extends ChangeNotifier {
  TmsLocalStorageService _storage = TmsLocalStorageService();

  Future<void> init() async => await _storage.init();
  bool get isReady => _storage.isReady;

  // ls generic sets and gets
  void setString(String k, String v) {
    _storage.setString(k, v).then((_) => notifyListeners());
  }

  String? getString(String k) => _storage.getString(k);

  void setBool(String k, bool v) {
    _storage.setBool(k, v).then((_) => notifyListeners());
  }

  bool? getBool(String k) => _storage.getBool(k);

  void setInt(String k, int v) {
    _storage.setInt(k, v).then((_) => notifyListeners());
  }

  int? getInt(String k) => _storage.getInt(k);

  void setDouble(String k, double v) {
    _storage.setDouble(k, v).then((_) => notifyListeners());
  }

  double? getDouble(String k) => _storage.getDouble(k);

  void setStringList(String k, List<String> v) {
    _storage.setStringList(k, v).then((_) => notifyListeners());
  }

  List<String>? getStringList(String k) => _storage.getStringList(k);
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

  set authRoles(List<EchoTreeRole> value) {
    List<String> roles = value.map((e) => jsonEncode(e.toJson())).toList();
    setStringList("authRoles", roles);
  }

  List<EchoTreeRole> get authRoles {
    List<String>? roles = getStringList("authRoles");
    return roles?.map((e) => EchoTreeRole.fromJson(jsonDecode(e))).toList() ?? [];
  }

  set isLoggedIn(bool value) => setBool("isLoggedIn", value);
  bool get isLoggedIn => getBool("isLoggedIn") ?? false;

  set themeMode(ThemeMode value) => setInt("themeMode", value.index);
  ThemeMode get themeMode => ThemeMode.values[getInt("themeMode") ?? 0]; // default to system theme

  set stagedMatches(List<String> matchNumbers) => setStringList("stagedMatches", matchNumbers);
  List<String> get stagedMatches => getStringList("stagedMatches") ?? [];
}
