import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/checks/judging_warning_checks.dart';
import 'package:tms/utils/checks/match_warning_checks.dart';
import 'package:tms/utils/checks/team_warning_checks.dart';
import 'package:tms/views/admin/dashboard/overview/event_overview/notifications/message_container.dart';

class WarningNotifications extends StatelessWidget {
  final ValueNotifier<Event> eventNotifier;
  final ValueNotifier<List<Team>> teamsNotifier;
  final ValueNotifier<List<GameMatch>> matchesNotifier;
  final ValueNotifier<List<JudgingSession>> judgingSessionsNotifier;

  const WarningNotifications({
    Key? key,
    required this.eventNotifier,
    required this.teamsNotifier,
    required this.matchesNotifier,
    required this.judgingSessionsNotifier,
  }) : super(key: key);

  Widget _matchesWarnings(Event event) {
    return ValueListenableBuilder(
      valueListenable: matchesNotifier,
      builder: (context, matches, child) {
        return ValueListenableBuilder(
            valueListenable: judgingSessionsNotifier,
            builder: (context, sessions, child) {
              List<MatchWarning> warnings = MatchWarningChecks.getWarnings(
                matches: matches,
                judgingSessions: sessions,
                event: event,
              );

              List<Widget> widgets = warnings.map((e) {
                return MessageContainer(
                  message: e.message,
                  teamNumber: e.teamNumber,
                  matchNumber: e.matchNumber,
                  accentColors: Colors.orange,
                );
              }).toList();

              return Column(children: widgets);
            });
      },
    );
  }

  Widget _judgingWarnings(Event event) {
    return ValueListenableBuilder(
      valueListenable: judgingSessionsNotifier,
      builder: (context, sessions, child) {
        return ValueListenableBuilder(
          valueListenable: matchesNotifier,
          builder: (context, matches, child) {
            List<JudgingWarning> warnings = JudgingWarningChecks.getWarnings(
              matches: matches,
              judgingSessions: sessions,
            );

            List<Widget> widgets = warnings.map((e) {
              return MessageContainer(
                message: e.message,
                teamNumber: e.teamNumber,
                sessionNumber: e.sessionNumber,
                accentColors: Colors.orange,
              );
            }).toList();

            return Column(children: widgets);
          },
        );
      },
    );
  }

  Widget _teamsWarnings(Event event) {
    return ValueListenableBuilder(
      valueListenable: teamsNotifier,
      builder: (context, teams, child) {
        List<TeamWarning> warnings = TeamWarningChecks.getWarnings(teams: teams, event: event);

        List<Widget> widgets = warnings.map((e) {
          return MessageContainer(
            message: e.message,
            teamNumber: e.teamNumber,
            accentColors: Colors.orange,
          );
        }).toList();

        return Column(children: widgets);
      },
    );
  }

  Widget _warnings() {
    return ValueListenableBuilder(
      valueListenable: eventNotifier,
      builder: (context, event, child) {
        return ListView(
          children: [
            _teamsWarnings(event),
            _judgingWarnings(event),
            _matchesWarnings(event),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        decoration: BoxDecoration(
          color: secondaryCardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Column(
          children: [
            Container(
              height: 50,
              decoration: const BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: const Center(
                child: Text(
                  "Warnings",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // warnings
            SizedBox(
              height: constraints.maxHeight - 60, // margin + header
              child: _warnings(),
            ),
          ],
        ),
      );
    });
  }
}
