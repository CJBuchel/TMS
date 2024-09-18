import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/providers/teams_provider.dart';
import 'package:tms/utils/color_modifiers.dart';

class TeamSelector extends StatefulWidget {
  final Function(Team) onTeamSelected;

  const TeamSelector({Key? key, required this.onTeamSelected}) : super(key: key);

  @override
  _TeamSelectorState createState() => _TeamSelectorState();
}

class _TeamSelectorState extends State<TeamSelector> {
  TextEditingController _teamSearchController = TextEditingController();
  TextEditingController _rankSearchController = TextEditingController();
  String _teamSearchText = "";
  String _rankSearchText = "";

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
        const Text("Header/add team button"),
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
        // main list
        Selector<TeamsProvider, List<Team>>(
          selector: (_, provider) {
            if (_teamSearchText.isEmpty && _rankSearchText.isEmpty) {
              return provider.teams;
            } else {
              return provider.teams.where((team) {
                // team search
                bool isMatch = team.name.toLowerCase().contains(_teamSearchText.toLowerCase());
                isMatch = isMatch || team.teamNumber.toLowerCase() == _teamSearchText.toLowerCase();

                // rank search
                isMatch = isMatch && team.ranking.toString().contains(_rankSearchText);
                return isMatch;
              }).toList();
            }
          },
          builder: (context, teams, _) {
            // silver list
            return Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        Color tileColor = index.isEven ? evenBackground : oddBackground;

                        final team = teams[index];
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
                          trailing: const Icon(
                            Icons.check,
                            color: Colors.green,
                          ),
                          onTap: () => widget.onTeamSelected(team),
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
