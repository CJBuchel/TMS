// parse string time to DateTime (Time in the format of 10:00:00 AM)
DateTime? parseStringTime(String time) {
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
