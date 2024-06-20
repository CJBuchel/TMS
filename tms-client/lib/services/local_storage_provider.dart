import 'package:shared_preferences/shared_preferences.dart';

class TmsLocalStorageService {
  SharedPreferences? _ls;

  Future<void> init() async {
    if (_ls == null) {
      _ls = await SharedPreferences.getInstance();
    }
  }

  bool get isReady => _ls != null ? true : false;

  Future<void> setString(String k, String v) async {
    await _ls?.setString(k, v);
  }

  String? getString(String k) => _ls?.getString(k);

  Future<void> setBool(String k, bool v) async {
    await _ls?.setBool(k, v);
  }

  bool? getBool(String k) => _ls?.getBool(k);

  Future<void> setInt(String k, int v) async {
    await _ls?.setInt(k, v);
  }

  int? getInt(String k) => _ls?.getInt(k);

  Future<void> setDouble(String k, double v) async {
    await _ls?.setDouble(k, v);
  }

  double? getDouble(String k) => _ls?.getDouble(k);

  Future<void> setStringList(String k, List<String> v) async {
    await _ls?.setStringList(k, v);
  }

  List<String>? getStringList(String k) => _ls?.getStringList(k);
}
