import 'package:tms/schemas/database_schema.dart';
import 'package:tms/utils/tms_time_utils.dart';

List<GameMatch> sortMatchesByTime(List<GameMatch> matches) {
  matches.sort((a, b) {
    return tmsDateTimeCompare(a.startTime, b.startTime);
  });

  return matches;
}