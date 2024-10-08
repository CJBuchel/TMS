import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/database_schemas/tournament_integrity_message.dart';
import 'package:tms/providers/tournament_integrity_provider.dart';
import 'package:tms/views/game_matches/on_add_match.dart';
import 'package:tms/widgets/integrity_checks/icon_tooltip_integrity_check.dart';
import 'package:tms/widgets/timers/match_schedule_timer.dart';

class MatchesInfoBanner extends StatelessWidget {
  final List<GameMatch> gameMatches;

  MatchesInfoBanner({
    Key? key,
    required this.gameMatches,
  }) : super(key: key);

  Widget _completedMatches() {
    int completedMatches = gameMatches.where((match) => match.completed).length;
    return Text("Completed: $completedMatches/${gameMatches.length}");
  }

  Widget _matchIntegrity() {
    return Selector<TournamentIntegrityProvider, List<TournamentIntegrityMessage>>(
      selector: (_, p) {
        return gameMatches.map((match) {
          return p.getMatchMessages(match.matchNumber);
        }).expand((element) {
          return element;
        }).toList();
      },
      builder: (context, messages, child) {
        return Row(
          children: [
            IconTooltipIntegrityCheck(messages: messages),
            Text("Match issues: ${messages.length}"),
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
      builder: (context, messages, child) {
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
          // time to next match
          Container(
            width: 150,
            child: const Center(
              child: MatchScheduleTimer(
                negativeStyle: TextStyle(color: Colors.red),
                positiveStyle: TextStyle(color: Colors.green),
              ),
            ),
          ),
          // completed matches
          _completedMatches(),
          // match checks
          _matchIntegrity(),
          // team checks
          _teamIntegrity(),
          // add match
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
            onPressed: () => OnAddMatch().call(context),
            icon: const Icon(Icons.add),
            label: const Text("Add match"),
          ),
        ],
      ),
    );
  }
}
