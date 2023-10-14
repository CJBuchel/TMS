import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/edit_time.dart';
import 'package:tms/utils/parse_util.dart';
import 'package:tms/utils/sorter_util.dart';

class MatchStartTime extends StatelessWidget {
  final List<GameMatch> matches;
  final TextEditingController controller;
  final String? label;
  final String? initialTime;
  final Function(String)? onProposedMatchNumber;
  final Function(String)? onProposedEndTime;

  const MatchStartTime({
    Key? key,
    this.label,
    this.initialTime,
    this.onProposedMatchNumber,
    this.onProposedEndTime,
    required this.matches,
    required this.controller,
  }) : super(key: key);

  void setMatchNumber(String value) {
    // search through all matches and find the two matches that are closest to the start time
    TimeOfDay setTime = parseStringTimeToTimeOfDay(value) ?? TimeOfDay.now();
    GameMatch matchBefore = matches.first;

    List<GameMatch> sortedMatches = sortMatchesByTime(matches);
    // first iterate and find the match before the start time
    for (var match in sortedMatches) {
      TimeOfDay matchTime = parseStringTimeToTimeOfDay(match.startTime) ?? TimeOfDay.now();
      if (parseTimeOfDayToMinutes(matchTime) < parseTimeOfDayToMinutes(setTime)) {
        matchBefore = match;
      }
    }

    // check the first match number and create a sub match number, i.e 1.1, 1.2, 1.3, etc.
    List<String> beforeSplit = matchBefore.matchNumber.split(".");
    String beforeMain = beforeSplit[0];
    int beforeSub = beforeSplit.length > 1 ? (int.tryParse(beforeSplit[1]) ?? 0) : 0;

    String newMatchNumber;
    if (parseTimeOfDayToMinutes(setTime) < parseTimeOfDayToMinutes(parseStringTimeToTimeOfDay(matchBefore.startTime) ?? TimeOfDay.now())) {
      newMatchNumber = "";
    } else {
      newMatchNumber = "$beforeMain.${beforeSub + 1}";
    }

    if (onProposedMatchNumber != null) {
      onProposedMatchNumber!.call(newMatchNumber);
    }
  }

  void setEndTime(String value) {
    TimeOfDay setTime = parseStringTimeToTimeOfDay(value) ?? TimeOfDay.now();
    // end time should be 4 minutes after setTime
    TimeOfDay endTime = TimeOfDay(hour: setTime.hour, minute: setTime.minute + 4);
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
        setMatchNumber(v);
        setEndTime(v);
      },
    );
  }
}
