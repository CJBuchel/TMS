import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/admin/dashboard/matches/match_edit/edit_time.dart';
import 'package:tms/views/shared/parse_util.dart';
import 'package:tms/views/shared/sorter_util.dart';

class StartTime extends StatelessWidget {
  final List<GameMatch> matches;
  final TextEditingController controller;
  final String? label;
  final String? initialTime;
  final Function(String)? onProposedMatchNumber;
  final Function(String)? onProposedEndTime;

  const StartTime({
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
    GameMatch matchAfter = matches.last;

    List<GameMatch> sortedMatches = sortMatchesByTime(matches);
    // first iterate and find the match before the start time
    for (var match in sortedMatches) {
      TimeOfDay matchTime = parseStringTimeToTimeOfDay(match.startTime) ?? TimeOfDay.now();
      if (matchTime.hour < setTime.hour) {
        matchBefore = match;
      }
    }

    // then iterate and find the match after the start time
    for (var match in sortedMatches.reversed) {
      TimeOfDay matchTime = parseStringTimeToTimeOfDay(match.startTime) ?? TimeOfDay.now();
      if (matchTime.hour > setTime.hour) {
        matchAfter = match;
      }
    }

    // check the first match number and create a sub match number, i.e 1.1, 1.2, 1.3, etc.
    double beforeNumber = double.tryParse(matchBefore.matchNumber) ?? 0.0;
    double afterNumber = double.tryParse(matchAfter.matchNumber) ?? 0.0;

    String newMatchNumber;

    if (afterNumber - beforeNumber >= 1.0) {
      newMatchNumber = "$beforeNumber.1";
    } else {
      int decimalPart = int.tryParse(matchBefore.matchNumber.split(".").last) ?? 0;
      newMatchNumber = "${beforeNumber.toStringAsFixed(0)}.${decimalPart + 1}";
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
