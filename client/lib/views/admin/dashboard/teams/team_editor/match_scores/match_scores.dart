import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/requests/team_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/parse_util.dart';
import 'package:tms/views/admin/dashboard/teams/team_editor/match_scores/add_score.dart';
import 'package:tms/views/admin/dashboard/teams/team_editor/match_scores/delete_score.dart';
import 'package:tms/views/admin/dashboard/teams/team_editor/match_scores/edit_score.dart';

class MatchScores extends StatefulWidget {
  final Team team;
  const MatchScores({
    Key? key,
    required this.team,
  }) : super(key: key);

  @override
  State<MatchScores> createState() => _MatchScoresState();
}

class _MatchScoresState extends State<MatchScores> {
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
              team: widget.team,
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
            child: _styledCell(_tags(score)),
          ),

          // edit button
          Expanded(
            flex: 1,
            child: EditScore(
              team: widget.team,
              index: index,
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
            team: widget.team,
          ),
        ),
        ...List.generate(7, (index) => const Expanded(flex: 1, child: SizedBox.shrink())),
      ],
    );
  }

  Widget _table() {
    final List<Widget> rows = List.generate(widget.team.gameScores.length, (index) {
      return SizedBox(
        height: 50,
        child: _styledRow(
          widget.team.gameScores[index],
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
    return _table();
  }
}
