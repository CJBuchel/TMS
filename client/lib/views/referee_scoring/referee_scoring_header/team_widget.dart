import 'package:flutter/material.dart';
import 'package:tms/mixins/teams_local_db.dart';
import 'package:tms/schema/tms_schema.dart';

class TeamDropdownWidget extends StatelessWidget {
  final GameMatch? nextMatch;
  final Team? nextTeam;
  final List<Team> teams;
  final bool locked;
  final Function(Team, GameMatch) onTeamChange;

  const TeamDropdownWidget({
    Key? key,
    required this.nextMatch,
    required this.nextTeam,
    required this.teams,
    required this.locked,
    required this.onTeamChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (locked) {
      return Text(
        "Team: ${nextTeam?.teamNumber} | ${nextTeam?.teamName}",
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    } else {
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
            if (nextMatch != null) onTeamChange(t, nextMatch!);
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
    }
  }
}
