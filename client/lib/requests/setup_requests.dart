import 'package:logger/logger.dart';
import 'package:tms/network/auth.dart';
import 'package:tms/network/network.dart';
import 'package:tms/schema/tms_schema.dart';

Future<int> setupRequest(SetupRequest request) async {
  try {
    request.authToken = await NetworkAuth.getToken();
    var res = await Network.serverPost("setup", request.toJson());

    if (res.item1) {
      return res.item2;
    } else {
      return res.item2;
    }
  } catch (e) {
    Logger().e(e);
    rethrow;
  }
}
