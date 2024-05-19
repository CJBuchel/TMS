// sort tms date time
import 'package:tms/schemas/database_schema.dart';

int getTmsDateTimeAsValue(TmsDateTime tmsDateTime) {
  int value = 0;
  value += tmsDateTime.date?.year ?? 0;
  value += tmsDateTime.date?.month ?? 0;
  value += tmsDateTime.date?.day ?? 0;

  value += tmsDateTime.time?.hour ?? 0;
  value += tmsDateTime.time?.minute ?? 0;
  value += tmsDateTime.time?.second ?? 0;

  return value;
}

// -1 if a < b
// 1 if a > b
// 0 if a == b
int tmsDateTimeCompare(TmsDateTime a, TmsDateTime b) {
  int aValue = getTmsDateTimeAsValue(a);
  int bValue = getTmsDateTimeAsValue(b);

  if (aValue < bValue) {
    return -1;
  } else if (aValue > bValue) {
    return 1;
  } else {
    return 0;
  }
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
