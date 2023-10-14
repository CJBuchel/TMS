import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/parse_util.dart';
import 'package:tms/views/admin/dashboard/teams/team_editor/match_scores/delete_score.dart';

class MatchScores extends StatefulWidget {
  final String teamNumber;
  const MatchScores({
    Key? key,
    required this.teamNumber,
  }) : super(key: key);

  @override
  State<MatchScores> createState() => _MatchScoresState();
}

class _MatchScoresState extends State<MatchScores> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  Team _team = LocalDatabaseMixin.teamDefault();

  set _setTeam(Team t) {
    if (mounted) {
      setState(() {
        _team = t;
      });
    }
  }

  set _setTeams(List<Team> teams) {
    if (mounted) {
      for (Team t in teams) {
        if (t.teamNumber == widget.teamNumber) {
          _setTeam = t;
          break;
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    onTeamsUpdate((t) => _setTeams = t);
    onTeamUpdate((t) => _setTeam = t);
  }

  Widget _styledCell(Widget inner) {
    return Container(
      padding: const EdgeInsets.all(5),
      child: Center(
        child: inner,
      ),
    );
  }

  Widget _styledTextCell(String label, {Color? textColor}) {
    return _styledCell(Text(
      label,
      style: TextStyle(color: textColor),
    ));
  }

  Widget _tags(TeamGameScore score) {
    if (score.noShow) {
      return const Text("No Show", style: TextStyle(color: Colors.orange));
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _styledRow(TeamGameScore score, int index) {
    String timeStamp = parseDateTimeToStringTime(parseServerTimestamp(score.timeStamp));
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
          ),
        ),
      ),
      child: Row(
        children: [
          // delete button
          Expanded(
            flex: 1,
            child: DeleteScore(
              team: _team,
              index: index,
            ),
          ),

          // time stamp
          Expanded(
            flex: 1,
            child: _styledTextCell(timeStamp),
          ),

          // round number
          Expanded(
            flex: 1,
            child: _styledTextCell(score.scoresheet.round.toString()),
          ),

          // referee
          Expanded(
            flex: 1,
            child: _styledTextCell(score.referee),
          ),

          // gp
          Expanded(
            flex: 1,
            child: _styledTextCell(score.gp, textColor: Colors.green),
          ),

          // score
          Expanded(
            flex: 1,
            child: _styledTextCell(score.score.toString(), textColor: Colors.green),
          ),

          Expanded(
            flex: 1,
            child: _tags(score),
          ),

          // edit button
          Expanded(
            flex: 1,
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _styledHeaders() {
    return Row(
      children: [
        // delete button
        const Expanded(
          flex: 1,
          child: SizedBox.shrink(),
        ),
        // timestamp
        Expanded(
          flex: 1,
          child: _styledCell(const Text("Time", style: TextStyle(fontWeight: FontWeight.bold))),
        ),
        // round number
        Expanded(
          flex: 1,
          child: _styledCell(const Text("Round", style: TextStyle(fontWeight: FontWeight.bold))),
        ),

        // referee
        Expanded(
          flex: 1,
          child: _styledCell(const Text("Referee", style: TextStyle(fontWeight: FontWeight.bold))),
        ),

        // gp
        Expanded(
          flex: 1,
          child: _styledCell(const Text("GP", style: TextStyle(fontWeight: FontWeight.bold))),
        ),

        // score
        Expanded(
          flex: 1,
          child: _styledCell(const Text("Score", style: TextStyle(fontWeight: FontWeight.bold))),
        ),

        // info tags
        Expanded(
          flex: 1,
          child: _styledCell(const Text("Tags", style: TextStyle(fontWeight: FontWeight.bold))),
        ),

        // edit button
        const Expanded(
          flex: 1,
          child: SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _addRow() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: IconButton(
            icon: const Icon(Icons.add, color: Colors.green),
            onPressed: () {},
          ),
        ),
        ...List.generate(7, (index) => const Expanded(flex: 1, child: SizedBox.shrink())),
      ],
    );
  }

  Widget _table() {
    final List<Widget> rows = List.generate(_team.gameScores.length, (index) {
      return SizedBox(
        height: 50,
        child: _styledRow(
          _team.gameScores[index],
          index,
        ),
      );
    });

    rows.add(_addRow());

    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey,
              ),
            ),
          ),
          child: _styledHeaders(),
        ),
        ...rows,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _table();
  }
}
