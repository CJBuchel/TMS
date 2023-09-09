import 'package:logger/logger.dart';
import 'package:tms/network/network.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tuple/tuple.dart';

Future<Tuple2<int, List<Team>>> getTeamsRequest() async {
  try {
    var res = await Network.serverGet("teams/get");

    if (res.item1) {
      return Tuple2(res.item2, TeamsResponse.fromJson(res.item3).teams);
    } else {
      return Tuple2(res.item2, []);
    }
  } catch (e) {
    Logger().e(e);
    rethrow;
  }
}
