import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/admin/dashboard/overview/event_overview/notifications/notifications.dart';
import 'package:tms/views/admin/dashboard/overview/event_overview/timers/timers.dart';

class EventOverview extends StatelessWidget {
  final ValueNotifier<Event> eventNotifier;
  final ValueNotifier<List<Team>> teamsNotifier;
  final ValueNotifier<List<GameMatch>> matchesNotifier;
  final ValueNotifier<List<JudgingSession>> judgingSessionsNotifier;

  const EventOverview({
    Key? key,
    required this.eventNotifier,
    required this.teamsNotifier,
    required this.matchesNotifier,
    required this.judgingSessionsNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // timers
        Expanded(
          flex: 1,
          child: Timers(
            matchesNotifier: matchesNotifier,
            judgingSessionsNotifier: judgingSessionsNotifier,
          ),
        ),

        // warnings/errors
        Expanded(
          flex: 1,
          child: Notifications(
            eventNotifier: eventNotifier,
            teamsNotifier: teamsNotifier,
            matchesNotifier: matchesNotifier,
            judgingSessionsNotifier: judgingSessionsNotifier,
          ),
        ),
      ],
    );
  }
}
