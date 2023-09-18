import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/network/network.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/screens/scoring/mission.dart';
import 'package:tms/screens/scoring/scoring_header.dart';
import 'package:tms/screens/shared/tool_bar.dart';

class Scoring extends StatefulWidget {
  const Scoring({Key? key}) : super(key: key);

  @override
  _ScoringScreenState createState() => _ScoringScreenState();
}

class _ScoringScreenState extends State<Scoring> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  List<GameMatch> _matches = [];
  List<Team> _teams = [];
  Game _game = Game(
    name: "",
    program: "",
    missions: [],
    questions: [],
  );

  void colorChange() {
    setState(() {});
  }

  void setGame(Game game) async {
    if (mounted) {
      setState(() {
        _game = game;
      });
    }
  }

  void setTeams(List<Team> teams) {
    if (mounted) {
      setState(() {
        _teams = teams;
      });
    }
  }

  void setMatches(List<GameMatch> matches) {
    if (mounted) {
      setState(() {
        _matches = matches;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    AppTheme.isDarkThemeNotifier.addListener(colorChange);

    onGameEventUpdate((game) => setGame(game));
    onMatchesUpdate((matches) => setMatches(matches));
    onTeamsUpdate((teams) => setTeams(teams));

    // singular match update
    onMatchUpdate((match) {
      // find the first match that matches the match number and update it
      final idx = _matches.indexWhere((m) => m.matchNumber == match.matchNumber);
      if (idx != -1) {
        setState(() {
          _matches[idx] = match;
        });
      }
    });

    // singular team update
    onTeamUpdate((team) {
      final idx = _teams.indexWhere((t) => t.teamNumber == team.teamNumber);
      if (idx != -1) {
        setState(() {
          _teams[idx] = team;
        });
      }
    });

    // delay for 1 second and check if the network is connected, if not use last known game
    Future.delayed(const Duration(seconds: 1), () async {
      if (!await Network.isConnected()) {
        getGame().then((game) => setGame(game));
      }
    });
  }

  @override
  void dispose() {
    AppTheme.isDarkThemeNotifier.removeListener(colorChange);
    super.dispose();
  }

  List<Widget> getMissions() {
    return _game.missions.map((mission) {
      return MissionWidget(
        color: (AppTheme.isDarkTheme ? const Color.fromARGB(255, 69, 80, 100) : Colors.white),
        mission: mission,
        scores: _game.questions.where((q) {
          return q.id.startsWith(mission.prefix);
        }).toList(),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TmsToolBar(),
      body: Container(
        decoration: BoxDecoration(color: (AppTheme.isDarkTheme ? null : Colors.lightBlue[100])),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                SizedBox(
                  height: Responsive.isTablet(context) ? 50 : 80,
                  child: Center(
                    child: ScoringHeader(
                      matches: _matches,
                      teams: _teams,
                    ),
                  ),
                ),
                SizedBox(
                  height: constraints.maxHeight - (Responsive.isTablet(context) ? 50 : 80),
                  child: Center(
                    child: ListView(
                      cacheExtent: 10000, // 10,000 pixels in every direction
                      children: getMissions(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
