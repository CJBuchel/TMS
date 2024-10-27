import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/generated/infra/database_schemas/tournament_integrity_message.dart';
import 'package:tms/providers/teams_provider.dart';
import 'package:tms/providers/tournament_integrity_provider.dart';
import 'package:tms/utils/color_modifiers.dart';
import 'package:tms/utils/sorter_util.dart';
import 'package:tms/views/teams/add_team_button.dart';
import 'package:tms/widgets/integrity_checks/icon_tooltip_integrity_check.dart';

class TeamSelector extends StatefulWidget {
  final Function(String teamId) onTeamSelected;

  const TeamSelector({Key? key, required this.onTeamSelected}) : super(key: key);

  @override
  _TeamSelectorState createState() => _TeamSelectorState();
}

class _TeamSelectorState extends State<TeamSelector> {
  TextEditingController _teamSearchController = TextEditingController();
  TextEditingController _rankSearchController = TextEditingController();
  String _teamSearchText = "";
  String _rankSearchText = "";

  String _selectedTeamId = "";

  set _selectedTeam(String teamId) {
    setState(() {
      _selectedTeamId = teamId;
      widget.onTeamSelected(teamId);
    });
  }

  String get _selectedTeam => _selectedTeamId;

  @override
  void initState() {
    super.initState();
    _teamSearchController.addListener(() {
      setState(() {
        _teamSearchText = _teamSearchController.text;
      });
    });
    _rankSearchController.addListener(() {
      setState(() {
        _rankSearchText = _rankSearchController.text;
      });
    });
  }

  @override
  void dispose() {
    _teamSearchController.dispose();
    _rankSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color evenBackground = Theme.of(context).cardColor;
    Color oddBackground = lighten(Theme.of(context).cardColor, 0.05);

    return Column(
      children: [
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, left: 8, right: 8, bottom: 4),
                child: Row(
                  children: [
                    Expanded(child: AddTeamButton()),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: _rankSearchController,
                        decoration: const InputDecoration(
                          labelText: "Rank",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _teamSearchController,
                        decoration: const InputDecoration(
                          labelText: "Team",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // main list
        Selector<TeamsProvider, Map<String, Team>>(
          selector: (_, provider) {
            if (_teamSearchText.isEmpty && _rankSearchText.isEmpty) {
              return provider.teamsMap;
            } else {
              return Map.fromEntries(
                provider.teamsMap.entries.where((entry) {
                  final team = entry.value;
                  // team search
                  bool isMatch = team.name.toLowerCase().contains(_teamSearchText.toLowerCase());
                  isMatch = isMatch || team.teamNumber.toLowerCase() == _teamSearchText.toLowerCase();

                  // rank search
                  isMatch = isMatch && team.ranking.toString().contains(_rankSearchText);
                  return isMatch;
                }),
              );
            }
          },
          shouldRebuild: (previous, next) => !listEquals(previous.entries.toList(), next.entries.toList()),
          builder: (context, teams, _) {
            // sort teams by their number
            final teamsList = teams.entries.toList();
            teamsList.sort((a, b) {
              int aNum = extractNumberFromString(a.value.teamNumber);
              int bNum = extractNumberFromString(b.value.teamNumber);
              return aNum.compareTo(bNum);
            });

            // silver list
            return Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        Color tileColor = index.isEven ? evenBackground : oddBackground;
                        // if this is the selected team, highlight it
                        if (teamsList[index].key == _selectedTeam) {
                          if (Theme.of(context).brightness == Brightness.light) {
                            tileColor = Colors.blue[200] ?? Colors.blue;
                          } else {
                            tileColor = Colors.blue[800] ?? Colors.blue;
                          }
                        }

                        final teamId = teamsList[index].key;
                        final team = teamsList[index].value;
                        return ListTile(
                          tileColor: tileColor,
                          leading: CircleAvatar(
                            child: Text(team.ranking.toString()),
                          ),
                          title: Text(team.name),
                          subtitle: Text(
                            team.teamNumber,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: Selector<TournamentIntegrityProvider, List<TournamentIntegrityMessage>>(
                            selector: (_, provider) => provider.getTeamMessages(team.teamNumber),
                            builder: (_, messages, __) {
                              return IconTooltipIntegrityCheck(messages: messages);
                            },
                          ),
                          onTap: () => _selectedTeam = teamId,
                        );
                      },
                      childCount: teams.length,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
