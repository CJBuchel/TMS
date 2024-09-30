import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/judging_session.dart';
import 'package:tms/generated/infra/database_schemas/tournament_integrity_message.dart';
import 'package:tms/providers/tournament_integrity_provider.dart';
import 'package:tms/views/judging_sessions/on_add_session.dart';
import 'package:tms/widgets/integrity_checks/icon_tooltip_integrity_check.dart';
import 'package:tms/widgets/timers/judging_schedule_timer.dart';

class JudgingInfoBanner extends StatelessWidget {
  final List<JudgingSession> judgingSessions;

  JudgingInfoBanner({
    Key? key,
    required this.judgingSessions,
  }) : super(key: key);

  Widget _completedSessions() {
    int completedSessions = judgingSessions.where((session) => session.completed).length;
    return Text("Completed: $completedSessions/${judgingSessions.length}");
  }

  Widget _sessionIntegrity() {
    return Selector<TournamentIntegrityProvider, List<TournamentIntegrityMessage>>(
      selector: (_, p) {
        return judgingSessions.map((session) {
          return p.getSessionMessages(session.sessionNumber);
        }).expand((element) {
          return element;
        }).toList();
      },
      builder: (_, messages, __) {
        return Row(
          children: [
            IconTooltipIntegrityCheck(messages: messages),
            Text("Session issues: ${messages.length}"),
          ],
        );
      },
    );
  }

  Widget _teamIntegrity() {
    return Selector<TournamentIntegrityProvider, List<TournamentIntegrityMessage>>(
      selector: (_, p) {
        return p.teamMessages;
      },
      builder: (_, messages, __) {
        return Row(
          children: [
            IconTooltipIntegrityCheck(messages: messages),
            Text("Team issues: ${messages.length}"),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // time to next session
          Container(
            width: 150,
            child: const Center(
              child: JudgingScheduleTimer(
                negativeStyle: TextStyle(color: Colors.red),
                positiveStyle: TextStyle(color: Colors.green),
              ),
            ),
          ),
          // completed sessions
          _completedSessions(),
          // session integrity
          _sessionIntegrity(),
          // team integrity
          _teamIntegrity(),
          // add session
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              overlayColor: Colors.white,
              foregroundColor: Colors.white,
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.green),
              ),
            ),
            onPressed: () => OnAddSession().call(context),
            icon: const Icon(Icons.add),
            label: const Text("Add session"),
          ),
        ],
      ),
    );
  }
}
