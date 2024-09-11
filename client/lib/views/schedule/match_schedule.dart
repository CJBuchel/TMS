import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/schema/tms_schema.dart';

class MatchSchedule extends StatelessWidget {
  final List<Team> teams;
  final List<GameMatch> matches;

  const MatchSchedule({
    Key? key,
    required this.teams,
    required this.matches,
  }) : super(key: key);

  Widget _cell(Widget inner) {
    return Center(
      child: inner,
    );
  }

  Widget _textCell(String label) {
    return _cell(Text(label));
  }

  Widget _getOnTableRow(OnTable table) {
    String teamText = "";

    for (Team t in teams) {
      if (t.teamNumber == table.teamNumber) {
        teamText = "${t.teamNumber} | ${t.teamName}";
        break;
      }
    }

    return Row(
      children: [
        Expanded(flex: 1, child: _textCell(table.table)),
        Expanded(flex: 1, child: _textCell(teamText)),
      ],
    );
  }

  Widget _getRow(GameMatch match, int index) {
    // get teams

    Color rowColor = index.isEven ? primaryRowColor : secondaryRowColor;

    if (match.complete) {
      rowColor = index.isEven ? Colors.green : Colors.green[300] ?? Colors.green;
    }

    List<Widget> tableRows = [];

    for (var table in match.matchTables) {
      tableRows.add(
        Expanded(
          flex: 2,
          child: _getOnTableRow(table),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: rowColor,
        border: const Border(
          bottom: BorderSide(
            color: Colors.grey,
          ),
        ),
      ),
      height: 50,
      child: Row(
        children: [
          Expanded(flex: 1, child: _textCell(match.matchNumber)),
          Expanded(flex: 1, child: _textCell(match.startTime)),
          ...tableRows,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: matches.length,
      itemBuilder: (context, index) {
        return _getRow(matches[index], index);
      },
    );
  }
}
