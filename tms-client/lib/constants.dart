import 'package:shared_preferences/shared_preferences.dart';

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
  String get serverIp => _ls?.getString("serverIp") ?? "";

  String get serverAddress => "$serverHttpProtocol://$serverIp:$serverPort";

  set wsConnectionString(String value) => _ls?.setString("wsConnectionString", value);
  String get wsConnectionString => _ls?.getString("wsConnectionString") ?? "";

  set authToken(String value) => _ls?.setString("authToken", value);
  String get authToken => _ls?.getString("authToken") ?? "";

  set uuid(String value) => _ls?.setString("uuid", value);
  String get uuid => _ls?.getString("uuid") ?? "";
}
