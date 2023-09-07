import 'package:logger/logger.dart';
import 'package:tms/network/auth.dart';
import 'package:tms/network/network.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tuple/tuple.dart';

Future<int> setupEventRequest(SetupRequest request) async {
  try {
    request.authToken = await NetworkAuth.getToken();
    var res = await Network.serverPost("event/setup", request.toJson());

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

Future<Tuple2<int, Event?>> getEventRequest() async {
  try {
    var res = await Network.serverGet("event/get");

    if (res.item1) {
      return Tuple2(res.item2, Event.fromJson(res.item3));
    } else {
      return Tuple2(res.item2, null);
    }
  } catch (e) {
    Logger().e(e);
    rethrow;
  }
}

Future<int> purgeEventRequest() async {
  try {
    var message = PurgeRequest(authToken: await NetworkAuth.getToken());
    var res = await Network.serverPost("event/purge", message.toJson());

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
