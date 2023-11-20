import 'package:flutter/material.dart';
import 'package:tms/mixins/teams_local_db.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/value_listenable_utils.dart';

class TeamDropdownWidget extends StatelessWidget {
  final ValueNotifier<GameMatch?> nextMatchNotifier;
  final ValueNotifier<Team?> nextTeamNotifier;
  final ValueNotifier<List<Team>> teamsNotifier;
  final ValueNotifier<bool> lockedNotifier;
  final Function(Team, GameMatch) onTeamChange;

  const TeamDropdownWidget({
    Key? key,
    required this.nextMatchNotifier,
    required this.nextTeamNotifier,
    required this.teamsNotifier,
    required this.lockedNotifier,
    required this.onTeamChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: lockedNotifier,
      builder: (context, locked, _) {
        if (locked) {
          return ValueListenableBuilder2(
            first: nextMatchNotifier,
            second: nextTeamNotifier,
            builder: (context, nextMatch, nextTeam, _) {
              return Text(
                "Team: ${nextTeam?.teamNumber} | ${nextTeam?.teamName}",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              );
            },
          );
        } else {
          return ValueListenableBuilder(
            valueListenable: teamsNotifier,
            builder: (context, teams, _) {
              return ValueListenableBuilder2(
                first: nextMatchNotifier,
                second: nextTeamNotifier,
                builder: (context, nextMatch, nextTeam, _) {
                  return DropdownButton<String>(
                    value: nextTeam?.teamNumber.toString(),
                    dropdownColor: Colors.blueGrey[800],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        Team t = TeamsLocalDB.singleDefault();
                        for (Team team in teams) {
                          if (team.teamNumber == newValue) {
                            t = team;
                            break;
                          }
                        }
                        if (nextMatch != null) onTeamChange(t, nextMatch);
                      }
                    },
                    items: teams.map<DropdownMenuItem<String>>((Team team) {
                      return DropdownMenuItem<String>(
                        value: team.teamNumber,
                        child: Text(
                          "Team: ${team.teamNumber} | ${team.teamName}",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      );
                    }).toList(),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}
