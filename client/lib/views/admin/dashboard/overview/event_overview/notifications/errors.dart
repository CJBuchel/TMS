import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/checks/judging_error_checks.dart';
import 'package:tms/utils/checks/match_error_checks.dart';
import 'package:tms/utils/checks/team_error_checks.dart';
import 'package:tms/views/admin/dashboard/overview/event_overview/notifications/message_container.dart';

class ErrorNotifications extends StatelessWidget {
  final ValueNotifier<Event> eventNotifier;
  final ValueNotifier<List<Team>> teamsNotifier;
  final ValueNotifier<List<GameMatch>> matchesNotifier;
  final ValueNotifier<List<JudgingSession>> judgingSessionsNotifier;

  const ErrorNotifications({
    Key? key,
    required this.eventNotifier,
    required this.teamsNotifier,
    required this.matchesNotifier,
    required this.judgingSessionsNotifier,
  }) : super(key: key);

  Widget _matchesErrors(Event event) {
    return ValueListenableBuilder(
      valueListenable: matchesNotifier,
      builder: (context, matches, child) {
        return ValueListenableBuilder(
          valueListenable: teamsNotifier,
          builder: (context, teams, child) {
            List<MatchError> errors = MatchErrorChecks.getErrors(
              matches: matches,
              teams: teams,
              event: event,
            );

            List<Widget> widgets = errors.map((e) {
              return MessageContainer(
                message: e.message,
                teamNumber: e.teamNumber,
                matchNumber: e.matchNumber,
                accentColors: Colors.red,
              );
            }).toList();

            return Column(children: widgets);
          },
        );
      },
    );
  }

  Widget _judgingErrors(Event event) {
    return ValueListenableBuilder(
      valueListenable: judgingSessionsNotifier,
      builder: (context, sessions, child) {
        return ValueListenableBuilder(
          valueListenable: teamsNotifier,
          builder: (context, teams, child) {
            List<JudgingError> errors = JudgingErrorChecks.getErrors(
              teams: teams,
              judgingSessions: sessions,
              event: event,
            );

            List<Widget> widgets = errors.map((e) {
              return MessageContainer(
                message: e.message,
                sessionNumber: e.sessionNumber,
                teamNumber: e.teamNumber,
                accentColors: Colors.red,
              );
            }).toList();

            return Column(children: widgets);
          },
        );
      },
    );
  }

  Widget _teamErrors(Event event) {
    return ValueListenableBuilder(
      valueListenable: teamsNotifier,
      builder: (context, teams, child) {
        List<TeamError> errors = TeamErrorChecks.getErrors(
          teams: teams,
        );

        List<Widget> widgets = errors.map((e) {
          return MessageContainer(
            message: e.message,
            teamNumber: e.teamNumber,
            accentColors: Colors.red,
          );
        }).toList();

        return Column(children: widgets);
      },
    );
  }

  Widget _errors() {
    return ValueListenableBuilder(
      valueListenable: eventNotifier,
      builder: (context, event, child) {
        return ListView(
          children: [
            _teamErrors(event),
            _judgingErrors(event),
            _matchesErrors(event),
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
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: const Center(
                child: Text(
                  "Errors",
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
              child: _errors(),
            ),
          ],
        ),
      );
    });
  }
}
