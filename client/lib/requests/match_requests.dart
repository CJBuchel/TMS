import 'package:logger/logger.dart';
import 'package:tms/network/network.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tuple/tuple.dart';

Future<Tuple2<int, List<GameMatch>>> getMatchesRequest() async {
  try {
    var res = await Network.serverGet("matches/get");

    if (res.item1) {
      return Tuple2(res.item2, MatchesResponse.fromJson(res.item3).matches);
    } else {
      return Tuple2(res.item2, []);
    }
  } catch (e) {
    Logger().e(e);
    rethrow;
  }
}
