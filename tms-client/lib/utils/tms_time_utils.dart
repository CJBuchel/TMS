//
// This file is required for tms time based operations.
// While TmsDateTime does have the below functions natively, the communications between flutter and WASM seem to lag.
// Half of this is due to the large integer values, and the other half is based on the chrono library used in WASM.
// DateTime objects are used in flutter, and are much faster to work with.
// Hence, these functions are implemented in dart to improve performance for basic utility
//

import 'package:tms/generated/infra/database_schemas/tms_time/tms_date.dart';
import 'package:tms/generated/infra/database_schemas/tms_time/tms_date_time.dart';
import 'package:tms/generated/infra/database_schemas/tms_time/tms_time.dart';

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

int tmsDateTimeGetDifferenceFromNow(TmsDateTime a) {
  DateTime now = DateTime.now();
  DateTime aValueDateTime = tmsDateTimeToDateTime(a);
  return aValueDateTime.difference(now).inSeconds;
}

int tmsDateTimeGetDifference(TmsDateTime a, TmsDateTime b) {
  int aValue = getTmsDateTimestamp(a);
  int bValue = getTmsDateTimestamp(b);
  return aValue - bValue;
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

// convert DateTime obj to TmsDateTime obj
TmsDateTime dateTimeToTmsDateTime(DateTime dateTime) {
  return TmsDateTime(
    date: TmsDate(
      year: dateTime.year,
      month: dateTime.month,
      day: dateTime.day,
    ),
    time: TmsTime(
      hour: dateTime.hour,
      minute: dateTime.minute,
      second: dateTime.second,
    ),
  );
}

// // convert TmsDateTime obj to DateTime obj
DateTime tmsDateTimeToDateTime(TmsDateTime tmsDateTime) {
  DateTime now = DateTime.now();
  return DateTime(
    tmsDateTime.date?.year ?? now.year,
    tmsDateTime.date?.month ?? now.month,
    tmsDateTime.date?.day ?? now.day,
    tmsDateTime.time?.hour ?? now.hour,
    tmsDateTime.time?.minute ?? now.minute,
    tmsDateTime.time?.second ?? now.second,
  );
}

TmsDateTime nowToTmsDateTime() {
  return dateTimeToTmsDateTime(DateTime.now());
}

String _padTime(int value, int length) {
  return value.toString().padLeft(length, '0');
}

// to string
String secondsToTimeString(int seconds) {
  // Calculate hours, minutes, and seconds
  int hours = seconds.abs() ~/ 3600;
  int minutes = (seconds.abs() % 3600) ~/ 60;
  int secs = seconds.abs() % 60;

  // Build time string based on the presence of hours and minutes
  String timeString = '';
  if (hours.abs() > 0) {
    timeString += _padTime(hours, 2) + ':';
  }
  if (minutes.abs() > 0 || hours > 0) {
    // Include minutes if there are hours
    timeString += _padTime(minutes, 2) + ':';
  }
  if (seconds.abs() >= 10) {
    timeString += _padTime(secs, 2);
  } else {
    timeString += secs.toString();
  }

  return timeString;
}
