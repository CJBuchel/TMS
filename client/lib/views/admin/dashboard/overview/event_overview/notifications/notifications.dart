import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/admin/dashboard/overview/event_overview/notifications/errors.dart';
import 'package:tms/views/admin/dashboard/overview/event_overview/notifications/warnings.dart';

class Notifications extends StatelessWidget {
  final ValueNotifier<Event> eventNotifier;
  final ValueNotifier<List<Team>> teamsNotifier;
  final ValueNotifier<List<GameMatch>> matchesNotifier;
  final ValueNotifier<List<JudgingSession>> judgingSessionsNotifier;

  const Notifications({
    Key? key,
    required this.eventNotifier,
    required this.teamsNotifier,
    required this.matchesNotifier,
    required this.judgingSessionsNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // warnings
        Expanded(
          flex: 1,
          child: WarningNotifications(
            eventNotifier: eventNotifier,
            teamsNotifier: teamsNotifier,
            matchesNotifier: matchesNotifier,
            judgingSessionsNotifier: judgingSessionsNotifier,
          ),
        ),

        // errors
        Expanded(
          flex: 1,
          child: ErrorNotifications(
            eventNotifier: eventNotifier,
            teamsNotifier: teamsNotifier,
            matchesNotifier: matchesNotifier,
            judgingSessionsNotifier: judgingSessionsNotifier,
          ),
        )
      ],
    );
  }
}
