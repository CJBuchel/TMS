import 'package:logger/logger.dart';
import 'package:tms/network/auth.dart';
import 'package:tms/network/network.dart';
import 'package:tms/schema/tms_schema.dart';

Future<int> timerStartRequest() async {
  try {
    var message = StartTimerRequest(authToken: await NetworkAuth.getToken());
    var res = await Network.serverPost("timer/start", message.toJson());

    if (res.item1) {
      Logger().i("Good Timer Start Request");
      return res.item2;
    } else {
      return res.item2;
    }
  } catch (e) {
    Logger().e(e);
    rethrow;
  }
}
