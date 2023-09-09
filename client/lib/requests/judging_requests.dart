import 'package:logger/logger.dart';
import 'package:tms/network/network.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tuple/tuple.dart';

Future<Tuple2<int, List<JudgingSession>>> getJudgingSessionsRequest() async {
  try {
    var res = await Network.serverGet("judging_sessions/get");

    if (res.item1) {
      return Tuple2(res.item2, JudgingSessionsResponse.fromJson(res.item3).judgingSessions);
    } else {
      return Tuple2(res.item2, []);
    }
  } catch (e) {
    Logger().e(e);
    rethrow;
  }
}
