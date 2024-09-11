import 'package:flutter/material.dart';
import 'package:tms/mixins/teams_local_db.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/parse_util.dart';

class PodsTable extends StatelessWidget {
  final List<Team> teams;
  final JudgingSession session;

  const PodsTable({
    Key? key,
    required this.teams,
    required this.session,
  }) : super(key: key);

  Widget _cell({Widget? child, int flex = 1, Color? color}) {
    return Expanded(
      flex: flex,
      child: Container(
        color: color,
        child: Center(
          child: child,
        ),
      ),
    );
  }

  Widget _row(JudgingPod pod) {
    Team team = TeamsLocalDB.singleDefault();
    for (Team t in teams) {
      if (t.teamNumber == pod.teamNumber) {
        team = t;
        break;
      }
    }

    bool isInSession = DateTime.now().isAfter(parseStringTimeToDateTime(session.startTime) ?? DateTime.now());
    Color? color = pod.scoreSubmitted ? Colors.green : (isInSession ? Colors.red : null);

    Widget row = Row(
      children: [
        _cell(
          child: Text(
            pod.pod,
            style: const TextStyle(fontSize: 15),
          ),
        ),
        _cell(
          flex: 2,
          child: Text(
            "${team.teamNumber} | ${team.teamName}",
            style: const TextStyle(fontSize: 15),
          ),
        ),
        _cell(
          color: color,
          child: Text(
            pod.scoreSubmitted ? "OK" : "NS",
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ],
    );

    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: row,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        session.judgingPods.length,
        (index) {
          return _row(session.judgingPods[index]);
        },
      ),
    );
  }
}
