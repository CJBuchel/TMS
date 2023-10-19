import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tms/constants.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/parse_util.dart';

class JudgingSchedule extends StatelessWidget {
  final List<Team> teams;
  final List<JudgingSession> sessions;

  const JudgingSchedule({
    Key? key,
    required this.teams,
    required this.sessions,
  }) : super(key: key);

  Widget _cell(Widget inner) {
    return Center(
      child: inner,
    );
  }

  Widget _textCell(String label) {
    return _cell(Text(label));
  }

  Widget _getPodRow(JudgingPod pod) {
    String teamText = "";

    for (Team t in teams) {
      if (t.teamNumber == pod.teamNumber) {
        teamText = "${t.teamNumber} | ${t.teamName}";
        break;
      }
    }

    return Row(
      children: [
        Expanded(flex: 1, child: _textCell(pod.pod)),
        Expanded(flex: 1, child: _textCell(teamText)),
      ],
    );
  }

  Widget _getRow(JudgingSession session, int index) {
    // get teams

    Color rowColor = index.isEven ? primaryRowColor : secondaryRowColor;

    // check if session start time is before now
    DateTime startTime = parseStringTimeToDateTime(session.startTime) ?? DateTime.now();
    if (DateTime.now().isAfter(startTime)) {
      rowColor = index.isEven ? Colors.green : Colors.green[300] ?? Colors.green;
    }

    if (session.complete) {
      rowColor = index.isEven ? Colors.green : Colors.green[300] ?? Colors.green;
    }

    List<Widget> tableRows = [];

    for (var table in session.judgingPods) {
      tableRows.add(
        Expanded(
          flex: 2,
          child: _getPodRow(table),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: rowColor,
        border: const Border(
          bottom: BorderSide(
            color: Colors.grey,
          ),
        ),
      ),
      height: 50,
      child: Row(
        children: [
          Expanded(flex: 1, child: _textCell(session.sessionNumber)),
          Expanded(flex: 1, child: _textCell(session.startTime)),
          ...tableRows,
        ],
      ),
    );
  }

  Widget _getTable(BuildContext context) {
    // split into

    List<JudgingSession> splitSessionList = [];

    // iterate through sessions, grab 2 pods at a time and place them in a single row
    for (JudgingSession session in sessions) {
      List<JudgingPod> podRows = [];
      int podCount = 0;
      for (JudgingPod pod in session.judgingPods) {
        podRows.add(pod);
        podCount++;

        if (podCount >= 2) {
          JudgingSession s = JudgingSession(
            complete: session.complete,
            judgingSessionDeferred: session.judgingSessionDeferred,
            startTime: session.startTime,
            endTime: session.endTime,
            sessionNumber: session.sessionNumber,
            judgingPods: List.from(podRows),
          );
          splitSessionList.add(s);
          podRows = [];
          podCount = 0;
        }
      }

      // add any remaining pods to a new session
      if (podCount > 0) {
        JudgingSession s = JudgingSession(
          complete: session.complete,
          judgingSessionDeferred: session.judgingSessionDeferred,
          startTime: session.startTime,
          endTime: session.endTime,
          sessionNumber: session.sessionNumber,
          judgingPods: List.from(podRows),
        );
        splitSessionList.add(s);
      }
    }

    return ListView.builder(
      itemCount: splitSessionList.length,
      itemBuilder: (context, index) {
        return _getRow(splitSessionList[index], index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _getTable(context);
  }
}
