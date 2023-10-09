// parse string time to DateTime (Time in the format of 10:00:00 AM)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

DateTime? parseStringTimeToDateTime(String time) {
  final format24 = RegExp(r'^(\d{2}):(\d{2}):(\d{2}) (AM|PM)$');
  final matchTime = format24.firstMatch(time); // heh, matching match time
  if (matchTime != null) {
    final hour = int.parse(matchTime.group(1)!);
    final minute = int.parse(matchTime.group(2)!);
    final second = int.parse(matchTime.group(3)!);
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute, second);
  } else {
    return null;
  }
}

// convert string time to time of day
TimeOfDay? parseStringTimeToTimeOfDay(String time) {
  final format24 = RegExp(r'^(\d{2}):(\d{2}):(\d{2}) (AM|PM)$');
  final matchTime = format24.firstMatch(time); // heh, matching match time
  if (matchTime != null) {
    final hour = int.parse(matchTime.group(1)!);
    final minute = int.parse(matchTime.group(2)!);
    return TimeOfDay(hour: hour, minute: minute);
  } else {
    return null;
  }
}

// convert date time to string (Time in the format of 10:00:00 AM)
String parseDateTimeToStringTime(DateTime time) {
  final DateFormat formatter = DateFormat('hh:mm:ss a');
  final String formattedTime = formatter.format(time);
  return formattedTime;
}

// convert time of day to string (Time in the format of 10:00:00 AM)
String parseTimeOfDayToString(TimeOfDay time) {
  final DateTime now = DateTime.now();
  final DateTime dateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
  return parseDateTimeToStringTime(dateTime);
}

String padTime(int value, int length) {
  return value.toString().padLeft(length, '0');
}

// parse time into string (Time in seconds to timer style 2:30)
String parseTime(int time) {
  String hourTime = padTime(time.abs() ~/ 3600, 2);
  String minuteTime = padTime((time.abs() % 3600) ~/ 60, 2);
  String secondTime = padTime(time.abs() % 60, 2);
  return "$hourTime:$minuteTime:$secondTime";
}

// parse server timestamp
DateTime parseServerTimestamp(int timestamp) {
  final int unixTimestampMilliseconds = timestamp * 1000;
  final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(unixTimestampMilliseconds);
  return dateTime;
}

// parse server timestamp to string
String parseServerTimestampToString(int timestamp) {
  final dateTime = parseServerTimestamp(timestamp);
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  final String formattedTime = formatter.format(dateTime);
  return formattedTime;
}
