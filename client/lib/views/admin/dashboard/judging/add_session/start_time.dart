import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/edit_time.dart';
import 'package:tms/views/shared/parse_util.dart';
import 'package:tms/views/shared/sorter_util.dart';

class JudgingStartTime extends StatelessWidget {
  final List<JudgingSession> sessions;
  final TextEditingController controller;
  final String? label;
  final String? initialTime;
  final Function(String)? onProposedSessionNumber;
  final Function(String)? onProposedEndTime;

  const JudgingStartTime({
    Key? key,
    this.label,
    this.initialTime,
    this.onProposedSessionNumber,
    this.onProposedEndTime,
    required this.sessions,
    required this.controller,
  }) : super(key: key);

  void setSessionNumber(String value) {
    TimeOfDay setTime = parseStringTimeToTimeOfDay(value) ?? TimeOfDay.now();
    JudgingSession sessionBefore = sessions.first;

    List<JudgingSession> sortedSessions = sortJudgingByTime(sessions);
    // first iterate and find the match before the start time
    for (var session in sortedSessions) {
      TimeOfDay sessionTime = parseStringTimeToTimeOfDay(session.startTime) ?? TimeOfDay.now();
      if (parseTimeOfDayToMinutes(sessionTime) < parseTimeOfDayToMinutes(setTime)) {
        sessionBefore = session;
      }
    }

    List<String> beforeSplit = sessionBefore.sessionNumber.split(".");
    String beforeMain = beforeSplit[0];
    int beforeSub = beforeSplit.length > 1 ? (int.tryParse(beforeSplit[1]) ?? 0) : 0;

    String newMatchNumber;
    if (parseTimeOfDayToMinutes(setTime) < parseTimeOfDayToMinutes(parseStringTimeToTimeOfDay(sessionBefore.startTime) ?? TimeOfDay.now())) {
      newMatchNumber = "";
    } else {
      newMatchNumber = "$beforeMain.${beforeSub + 1}";
    }

    if (onProposedSessionNumber != null) {
      onProposedSessionNumber!.call(newMatchNumber);
    }
  }

  void setEndTime(String value) {
    TimeOfDay setTime = parseStringTimeToTimeOfDay(value) ?? TimeOfDay.now();
    // end time should be 4 minutes after setTime
    TimeOfDay endTime = TimeOfDay(hour: setTime.hour, minute: setTime.minute + 30);
    String endTimeString = parseTimeOfDayToString(endTime);
    if (onProposedEndTime != null) {
      onProposedEndTime!.call(endTimeString);
    }
  }

  @override
  Widget build(BuildContext context) {
    return EditTime(
      controller: controller,
      label: "Start Time",
      onChange: (v) {
        setSessionNumber(v);
        setEndTime(v);
      },
    );
  }
}
