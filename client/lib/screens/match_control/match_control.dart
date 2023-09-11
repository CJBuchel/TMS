import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/network/network.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/screens/match_control/controls.dart';
import 'package:tms/screens/match_control/table.dart';
import 'package:tms/screens/shared/tool_bar.dart';

class MatchControl extends StatefulWidget {
  const MatchControl({Key? key}) : super(key: key);

  @override
  _MatchControlState createState() => _MatchControlState();
}

class _MatchControlState extends State<MatchControl> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  String? _loadedMatch;
  List<GameMatch> _matches = [];
  List<Team> _teams = [];
  final List<GameMatch> _selectedMatches = [];

  // Set teams
  void setTeams(List<Team> teams) async {
    List<Team> t = [];

    teams.sort((a, b) => int.parse(a.teamNumber).compareTo(int.parse(b.teamNumber)));

    for (var team in teams) {
      t.add(team);
    }

    setState(() {
      _teams = t;
    });
  }

  void setMatches(List<GameMatch> gameMatches) async {
    List<GameMatch> m = [];

    gameMatches.sort((a, b) => int.parse(a.matchNumber).compareTo(int.parse(b.matchNumber)));

    for (var match in gameMatches) {
      m.add(match);
    }

    setState(() {
      _matches = m;
    });
  }

  void onSelectedMatches(List<GameMatch> matches) {
    setState(() {
      _selectedMatches.clear();
      _selectedMatches.addAll(matches);
    });
  }

  @override
  void initState() {
    super.initState();
    onTeamsUpdate((teams) => setTeams(teams));
    onMatchesUpdate((matches) => setMatches(matches));

    onTeamUpdate((team) {
      int idx = _teams.indexWhere((t) => t.teamNumber == team.teamNumber);
      if (idx != -1) {
        setState(() {
          _teams[idx] = team;
        });
      }
    });

    onMatchUpdate((match) {
      int idx = _matches.indexWhere((m) => m.matchNumber == match.matchNumber);
      if (idx != -1) {
        setState(() {
          _matches[idx] = match;
        });
      }
    });

    Future.delayed(const Duration(seconds: 1), () async {
      if (!await Network.isConnected()) {
        getTeams().then((teams) => setTeams(teams));
        getMatches().then((matches) => setMatches(matches));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TmsToolBar(),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (!Responsive.isMobile(context)) {
            return Row(
              children: [
                SizedBox(
                  width: constraints.maxWidth / 2, // 50%
                  child: MatchControlControls(
                    con: constraints,
                    teams: _teams,
                    selectedMatches: _selectedMatches,
                    matches: _matches,
                  ),
                ),
                SizedBox(
                  width: (constraints.maxWidth / 2), // 50%
                  child: MatchControlTable(
                    con: constraints,
                    matches: _matches,
                    onSelected: onSelectedMatches,
                    loadedMatch: _loadedMatch,
                  ),
                ),
              ],
            );
          } else {
            return SizedBox(
              width: constraints.maxWidth,
              child: MatchControlTable(
                con: constraints,
                matches: _matches,
                onSelected: onSelectedMatches,
                loadedMatch: _loadedMatch,
              ),
            );
          }
        },
      ),
    );
  }
}
