import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/parse_util.dart';
import 'package:tms/views/admin/dashboard/overview/scoring/scoring_tile_widgets.dart';

class TeamScoreWidget {
  final String teamNumber;
  final String session;
  final String scorer;
  final int timeStamp;
  final Widget scoreWidget;
  const TeamScoreWidget({
    required this.teamNumber,
    required this.session,
    required this.scorer,
    required this.timeStamp,
    required this.scoreWidget,
  });
}

class ScoringOverview extends StatefulWidget {
  final ValueNotifier<List<Team>> teamsNotifier;
  const ScoringOverview({Key? key, required this.teamsNotifier}) : super(key: key);

  @override
  State<ScoringOverview> createState() => _ScoringOverviewState();
}

class _ScoringOverviewState extends State<ScoringOverview> {
  List<TeamScoreWidget> _filteredScoreSheets = [];
  String _teamFilter = '';
  String _sessionFilter = '';
  String _scorerFilter = '';

  set _setTeamFilter(String t) {
    if (mounted) {
      setState(() {
        _teamFilter = t;
      });
    }
  }

  set _setSessionFilter(String s) {
    if (mounted) {
      setState(() {
        _sessionFilter = s;
      });
    }
  }

  set _setScorerFilter(String s) {
    if (mounted) {
      setState(() {
        _scorerFilter = s;
      });
    }
  }

  set _setFilteredScoresheets(List<TeamScoreWidget> sheets) {
    if (mounted) {
      setState(() {
        _filteredScoreSheets = sheets;
      });
    }
  }

  void _applyFilters() {
    List<TeamScoreWidget> filteredScoreSheets = [];

    // build the scoresheets
    for (Team t in widget.teamsNotifier.value) {
      // game scores
      for (TeamGameScore ts in t.gameScores) {
        filteredScoreSheets.add(
          TeamScoreWidget(
            teamNumber: t.teamNumber,
            session: "R${ts.scoresheet.round}",
            scorer: ts.referee,
            timeStamp: ts.timeStamp,
            scoreWidget: GameScoringTile(
              teamNumber: t.teamNumber,
              gameScore: ts,
              scores: t.gameScores,
            ),
          ),
        );
      }
    }

    if (_teamFilter.isNotEmpty) {
      String teamFilter = _teamFilter.toLowerCase();
      filteredScoreSheets = filteredScoreSheets.where((element) => element.teamNumber.toLowerCase().contains(teamFilter)).toList();
    }

    if (_sessionFilter.isNotEmpty) {
      String sessionFilter = _sessionFilter.toLowerCase();
      filteredScoreSheets = filteredScoreSheets.where((element) => element.session.toLowerCase().contains(sessionFilter)).toList();
    }

    if (_scorerFilter.isNotEmpty) {
      String scorerFilter = _scorerFilter.toLowerCase();
      filteredScoreSheets = filteredScoreSheets.where((element) => element.scorer.toLowerCase().contains(scorerFilter)).toList();
    }

    _setFilteredScoresheets = sortScoresByTimeStamp(filteredScoreSheets).reversed.toList();
  }

  List<TeamScoreWidget> sortScoresByTimeStamp(List<TeamScoreWidget> scores) {
    scores.sort((a, b) {
      DateTime aTime = parseServerTimestamp(a.timeStamp);
      DateTime bTime = parseServerTimestamp(b.timeStamp);
      return aTime.compareTo(bTime);
    });

    return scores;
  }

  @override
  void initState() {
    super.initState();
    widget.teamsNotifier.addListener(() {
      _applyFilters();
    });
  }

  Widget _filterTeam() {
    return TextField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Team',
      ),
      onChanged: (t) {
        _setTeamFilter = t;
        _applyFilters();
      },
    );
  }

  Widget _filterSession() {
    return TextField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Session',
      ),
      onChanged: (s) {
        _setSessionFilter = s;
        _applyFilters();
      },
    );
  }

  Widget _filterScorer() {
    return TextField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Scorer',
      ),
      onChanged: (s) {
        _setScorerFilter = s;
        _applyFilters();
      },
    );
  }

  Widget _getFilters() {
    return Row(
      children: [
        Expanded(flex: 1, child: _filterTeam()),
        Expanded(flex: 1, child: _filterSession()),
        Expanded(flex: 1, child: _filterScorer()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double margin = 10;
    double padding = 10;

    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        height: constraints.maxHeight,
        padding: EdgeInsets.all(padding),
        margin: EdgeInsets.fromLTRB(margin, margin, margin, 0),
        decoration: BoxDecoration(
          color: secondaryCardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: Column(
          children: [
            // filters
            SizedBox(
              height: 50,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
                child: _getFilters(),
              ),
            ),

            // list
            SizedBox(
              height: constraints.maxHeight - 80,
              child: ListView.builder(
                itemCount: _filteredScoreSheets.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: _filteredScoreSheets[index].scoreWidget,
                  );
                },
              ),
            )
          ],
        ),
      );
    });
  }
}
