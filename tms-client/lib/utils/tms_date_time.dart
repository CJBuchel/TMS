// sort tms date time
import 'package:tms/schemas/database_schema.dart';

// provides unix timestamp for tms date time
int getTmsDateTimestamp(TmsDateTime tmsDateTime) {
  int timestamp = 0;

  // date
  timestamp += (tmsDateTime.date?.year ?? 0) * 10000000000; // 10 digits for year
  timestamp += (tmsDateTime.date?.month ?? 0) * 100000000; // 2 digits for month
  timestamp += (tmsDateTime.date?.day ?? 0) * 1000000; // 2 digits for day

  // time
  timestamp += (tmsDateTime.time?.hour ?? 0) * 10000; // 2 digits for hour
  timestamp += (tmsDateTime.time?.minute ?? 0) * 100; // 2 digits for minute
  timestamp += tmsDateTime.time?.second ?? 0; // 2 digits for second

  return timestamp;
}

int tmsDateTimeCompare(TmsDateTime a, TmsDateTime b) {
  int aValue = getTmsDateTimestamp(a);
  int bValue = getTmsDateTimestamp(b);
  return aValue.compareTo(bValue);
}

// to string
String tmsDateTimeToString(TmsDateTime tmsDateTime) {
  String date = "";
  String time = "";

  if (tmsDateTime.date != null) {
    String year = tmsDateTime.date!.year.toString();
    String month = tmsDateTime.date!.month.toString().padLeft(2, '0');
    String day = tmsDateTime.date!.day.toString().padLeft(2, '0');
    date = "$year-$month-$day";
  }

  if (tmsDateTime.time != null) {
    String hour = tmsDateTime.time!.hour.toString().padLeft(2, '0');
    String minute = tmsDateTime.time!.minute.toString().padLeft(2, '0');
    String second = tmsDateTime.time!.second.toString().padLeft(2, '0');
    time = "$hour:$minute:$second";
  }

  return "$date $time";
}
