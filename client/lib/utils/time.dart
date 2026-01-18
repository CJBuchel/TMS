import 'package:tms_client/generated/common/common.pb.dart';

extension TmsDateTimeConversion on TmsDateTime {
  DateTime toDateTime() {
    DateTime dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
      time.second,
    );
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
