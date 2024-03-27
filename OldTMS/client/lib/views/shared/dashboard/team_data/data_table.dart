import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/parse_util.dart';
import 'package:tms/views/shared/dashboard/team_data/td_table.dart';
import 'package:tms/views/shared/dashboard/team_data/td_table_types.dart';

class TeamDataTable extends StatefulWidget {
  final int rounds;
  final List<TDColumn> columns;
  final ValueNotifier<List<Team>> teams;
  final ValueNotifier<List<TDRow>> generatedRows;

  const TeamDataTable({
    Key? key,
    required this.rounds,
    required this.teams,
    required this.columns,
    required this.generatedRows,
  }) : super(key: key);

  @override
  State<TeamDataTable> createState() => _TeamDataTableState();
}

class _TeamDataTableState extends State<TeamDataTable> {
  Color _getColor(int i) {
    List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.yellow,
      Colors.pink,
      Colors.orange,
      Colors.teal,
      Colors.amber,
      Colors.cyan,
    ];

    return colors[i % colors.length].withOpacity(0.2);
  }

  List<TDCell> _scoreSubRow(Team team) {
    List<TDCell> scoreSubRow = [];

    for (int i = 1; i <= widget.rounds; i++) {
      List<TeamGameScore> scores = [];

      for (TeamGameScore score in team.gameScores) {
        if (score.scoresheet.round == i) {
          scores.add(score);
        }
      }

      String sc = "";
      String gp = "";
      String pub = "";
      String priv = "";

      if (scores.isNotEmpty) {
        if (scores.length > 1) {
          sc = "Conflict";
          gp = "Conflict";
        } else {
          sc = scores.first.score.toString();
          gp = parseGP(scores.first.gp);
          pub = scores.first.scoresheet.publicComment;
          priv = scores.first.scoresheet.privateComment;
        }
      }

      scoreSubRow.addAll([
        TDCell.text(
          sc,
          color: _getColor(i),
        ),
        TDCell.text(
          gp,
          color: _getColor(i),
        ),
        TDCell.text(
          pub,
          color: _getColor(i),
        ),
        TDCell.text(
          priv,
          color: _getColor(i),
        ),
      ]);
    }

    return scoreSubRow;
  }

  TDRow _row(Team team, int index) {
    Color? rowColor;
    if (index.isEven) {
      rowColor = primaryRowColor;
    } else {
      rowColor = secondaryRowColor;
    }

    return TDRow(
      rowColor: rowColor,
      height: 50,
      cells: [
        TDCell(type: TDCellType.number, value: team.ranking.toDouble()),
        TDCell(type: TDCellType.text, value: team.teamNumber),
        TDCell(type: TDCellType.text, value: team.teamName),
        ..._scoreSubRow(team),
      ],
    );
  }

  List<TDRow> _getRows(List<Team> teams) {
    List<TDRow> rows = [];

    for (Team t in teams) {
      int index = teams.indexOf(t);
      rows.add(_row(t, index));
    }

    return rows;
  }

  void _updateGeneratedRows() {
    widget.generatedRows.value = _getRows(widget.teams.value);
  }

  @override
  void initState() {
    super.initState();
    _updateGeneratedRows();

    widget.teams.addListener(_updateGeneratedRows);
    AppTheme.isDarkThemeNotifier.addListener(_updateGeneratedRows);
  }

  @override
  void dispose() {
    widget.teams.removeListener(_updateGeneratedRows);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.teams,
      builder: (context, teams, child) {
        return TDTable(
          showFilterRow: true,
          columns: widget.columns,
          rows: _getRows(teams),
        );
      },
    );
  }
}
