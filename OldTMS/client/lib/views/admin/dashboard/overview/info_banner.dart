import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';

class OverviewInfoBanner extends StatelessWidget {
  final ValueNotifier<List<GameMatch>> matchNotifier;
  final ValueNotifier<List<JudgingSession>> judgingSessionsNotifier;
  final ValueNotifier<List<Team>> teamsNotifier;
  const OverviewInfoBanner({
    Key? key,
    required this.matchNotifier,
    required this.judgingSessionsNotifier,
    required this.teamsNotifier,
  }) : super(key: key);

  Widget _matchesInfo() {
    return ValueListenableBuilder(
      valueListenable: matchNotifier,
      builder: (context, matches, child) {
        int total = matches.length;
        int completed = 0;
        for (var match in matches) {
          if (match.complete) {
            completed++;
          }
        }
        return Text(
          "Matches: $completed/$total",
          style: TextStyle(color: (completed == total) ? Colors.green : null),
        );
      },
    );
  }

  Widget _judgingSessions() {
    return ValueListenableBuilder(
      valueListenable: judgingSessionsNotifier,
      builder: (context, sessions, child) {
        int total = sessions.length;
        int completed = 0;
        for (var session in sessions) {
          if (session.complete) {
            completed++;
          }
        }
        return Text(
          "Sessions: $completed/$total",
          style: TextStyle(color: (completed == total) ? Colors.green : null),
        );
      },
    );
  }

  Widget _judgingScoresheets() {
    return ValueListenableBuilder(
      valueListenable: judgingSessionsNotifier,
      builder: (context, sessions, child) {
        return ValueListenableBuilder(
          valueListenable: teamsNotifier,
          builder: (context, teams, child) {
            int total = 0;
            int submitted = 0;

            for (var session in sessions) {
              for (var pod in session.judgingPods) {
                total++;
                if (pod.scoreSubmitted) {
                  submitted++;
                }
              }
            }

            return Text(
              "Pod Submissions: $submitted/$total",
              style: TextStyle(color: (submitted == total) ? Colors.green : null),
            );
          },
        );
      },
    );
  }

  Widget _gameScoresheets() {
    return ValueListenableBuilder(
      valueListenable: matchNotifier,
      builder: (context, matches, _) {
        return ValueListenableBuilder(
          valueListenable: teamsNotifier,
          builder: (context, teams, child) {
            int total = 0;
            int submitted = 0;

            for (var match in matches) {
              for (var table in match.matchTables) {
                total++;
                if (table.scoreSubmitted) {
                  submitted++;
                }
              }
            }

            return Text(
              "Table Submissions: $submitted/$total",
              style: TextStyle(color: (submitted == total) ? Colors.green : null),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // matches
          _matchesInfo(),

          // judging sessions
          _judgingSessions(),

          // judging scoresheets
          _judgingScoresheets(),

          // game scoresheets
          _gameScoresheets(),
        ],
      ),
    );
  }
}
