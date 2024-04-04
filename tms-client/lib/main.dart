import 'package:logger/web.dart';
import 'package:tms/network/network.dart';

void main() async {
  Logger().i("TMS App starting...");

  Network().connect();

  // wait for 30 seconds
  await Future.delayed(const Duration(seconds: 30), () {
    Logger().i("TMS App stopping...");
  });

  Network().disconnect();
}
