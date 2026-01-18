import 'package:tms_client/generated/common/common.pb.dart';

extension TmsDateTimeConversion on TmsDateTime {
  DateTime toDateTime() {
    final now = DateTime.now();
    DateTime dateTime = DateTime(
      hasDate() ? date.year : now.year,
      hasDate() ? date.month : now.month,
      hasDate() ? date.day : now.day,
      hasTime() ? time.hour : now.hour,
      hasTime() ? time.minute : now.minute,
      hasTime() ? time.second : now.second,
    );
    return dateTime;
  }

  /// Converts to DateTime, ensuring the result is the next occurrence of the time
  /// If the time has already passed today, it returns tomorrow's occurrence
  DateTime toNextOccurrence() {
    final now = DateTime.now();
    DateTime dateTime = DateTime(
      hasDate() ? date.year : now.year,
      hasDate() ? date.month : now.month,
      hasDate() ? date.day : now.day,
      hasTime() ? time.hour : now.hour,
      hasTime() ? time.minute : now.minute,
      hasTime() ? time.second : now.second,
    );

    // If this time has already passed today, move to tomorrow
    if (!hasDate() && dateTime.isBefore(now)) {
      dateTime = dateTime.add(const Duration(days: 1));
    }

    return dateTime;
  }
}

extension DateTimeConversion on DateTime {
  TmsDateTime fromDateTime() {
    return TmsDateTime(
      date: TmsDate(year: year, month: month, day: day),
      time: TmsTime(hour: hour, minute: minute, second: second),
    );
  }
}
