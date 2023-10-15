import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/requests/team_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/parse_util.dart';
import 'package:tms/views/admin/dashboard/teams/team_editor/match_scores/add_score.dart';
import 'package:tms/views/admin/dashboard/teams/team_editor/match_scores/delete_score.dart';
import 'package:tms/views/admin/dashboard/teams/team_editor/match_scores/edit_score.dart';

class MatchScores extends StatefulWidget {
  final String teamNumber;
  const MatchScores({
    Key? key,
    required this.teamNumber,
  }) : super(key: key);

  @override
  State<MatchScores> createState() => _MatchScoresState();
}

class _MatchScoresState extends State<MatchScores> {
  Team? _team;

  set _setTeam(Team t) {
    if (mounted) {
      setState(() {
        _team = t;
      });
    }
  }

  Future<void> _fetchTeam() async {
    await getTeamRequest(widget.teamNumber).then((res) {
      if (res.item1 == HttpStatus.ok) {
        if (res.item2 != null) _setTeam = res.item2!;
      }
    });
  }

  @override
  void didUpdateWidget(covariant MatchScores oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.teamNumber != widget.teamNumber) {
      _fetchTeam();
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTeam();
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
    List<Widget> tags = [];

    // no show
    if (score.noShow) {
      tags.add(
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.orange),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          child: const Text("NS", style: TextStyle(color: Colors.orange)),
        ),
      );
    }

    // cloud publish
    if (score.cloudPublished) {
      tags.add(
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.cyan),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          child: const Text("CP", style: TextStyle(color: Colors.cyan)),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: tags,
    );
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
              team: _team!,
              index: index,
              onDelete: () => _fetchTeam(),
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
            child: _styledCell(_tags(score)),
          ),

          // edit button
          Expanded(
            flex: 1,
            child: EditScore(
              team: _team!,
              index: index,
              onUpdate: () => _fetchTeam(),
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
          child: AddScore(
            team: _team!,
            onAdd: () => _fetchTeam(),
          ),
        ),
        ...List.generate(7, (index) => const Expanded(flex: 1, child: SizedBox.shrink())),
      ],
    );
  }

  Widget _table() {
    final List<Widget> rows = List.generate(_team!.gameScores.length, (index) {
      return SizedBox(
        height: 50,
        child: _styledRow(
          _team!.gameScores[index],
          index,
        ),
      );
    });

    rows.add(SizedBox(height: 70, child: _addRow()));

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
    if (_team == null) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return _table();
    }
  }
}
