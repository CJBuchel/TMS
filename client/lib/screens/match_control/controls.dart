import 'dart:io';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:tms/requests/match_requests.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/screens/match_control/match_status.dart';
import 'package:tms/screens/match_control/ttl_clock.dart';

class MatchControlControls extends StatefulWidget {
  final BoxConstraints con;
  final List<Team> teams;
  final List<GameMatch> matches;
  final List<GameMatch> loadedMatches;
  final List<GameMatch> selectedMatches;
  const MatchControlControls(
      {Key? key, required this.con, required this.teams, required this.selectedMatches, required this.matches, required this.loadedMatches})
      : super(key: key);

  @override
  _MatchControlControlsState createState() => _MatchControlControlsState();
}

enum MatchLoadStatus {
  load,
  unload,
}

class _MatchControlControlsState extends State<MatchControlControls> {
  void displayErrorDialog(int serverRes) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Unauthorised"),
        content: SingleChildScrollView(
          child: Text(serverRes == HttpStatus.unauthorized ? "Invalid User Permissions" : "Server Error"),
        ),
      ),
    );
  }

  void loadMatch(MatchLoadStatus status) {
    loadMatchRequest(widget.selectedMatches.map((e) => e.matchNumber).toList());
    switch (status) {
      case MatchLoadStatus.load:
        loadMatchRequest(widget.selectedMatches.map((e) => e.matchNumber).toList()).then((res) {
          if (res != HttpStatus.ok) {
            displayErrorDialog(res);
          }
        });
        break;
      case MatchLoadStatus.unload:
        unloadMatchRequest().then((res) {
          if (res != HttpStatus.ok) {
            displayErrorDialog(res);
          }
        });
        break;
    }
  }

  Widget _styledHeader(String content) {
    return Text(content, style: const TextStyle(fontWeight: FontWeight.bold));
  }

  DataCell _styledCell(String context) {
    return DataCell(
      Text(
        context,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  DataRow2 _styledRow(OnTable table, String matchNumber) {
    return DataRow2(cells: [
      _styledCell(matchNumber),
      _styledCell(table.table),
      _styledCell(table.teamNumber),
      _styledCell(widget.teams.firstWhere((t) => t.teamNumber == table.teamNumber).teamName),
    ]);
  }

  List<DataRow2> _getRows(List<GameMatch> matches) {
    List<DataRow2> rows = [];
    for (var match in matches) {
      rows.add(_styledRow(match.onTableFirst, match.matchNumber));
      rows.add(_styledRow(match.onTableSecond, match.matchNumber));
    }
    return rows;
  }

  Widget getControls() {
    return Center(
      child: Column(
        children: [
          // Load/Unload Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: SizedBox(
                    height: Responsive.buttonHeight(context, 1),
                    child: ElevatedButton.icon(
                      style: ButtonStyle(
                        backgroundColor: (widget.selectedMatches.isNotEmpty && widget.loadedMatches.isEmpty)
                            ? MaterialStateProperty.all<Color>(Colors.orange)
                            : MaterialStateProperty.all<Color>(Colors.grey),
                      ),
                      onPressed: () {
                        if (widget.selectedMatches.isNotEmpty && widget.loadedMatches.isEmpty) {
                          loadMatch(MatchLoadStatus.load);
                        }
                      },
                      icon: const Icon(Icons.arrow_downward),
                      label: const Text("Load", style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ),
                const SizedBox(width: 16), // spacing
                Expanded(
                  child: SizedBox(
                    height: Responsive.buttonHeight(context, 1),
                    child: ElevatedButton.icon(
                      style: ButtonStyle(
                        backgroundColor: widget.loadedMatches.isNotEmpty
                            ? MaterialStateProperty.all<Color>(Colors.orange)
                            : MaterialStateProperty.all<Color>(Colors.grey),
                      ),
                      onPressed: () {
                        if (widget.loadedMatches.isNotEmpty) {
                          loadMatch(MatchLoadStatus.unload);
                        }
                      },
                      icon: const Icon(Icons.arrow_upward),
                      label: const Text("Unload", style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // TTL Clock
          Container(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: 3.0,
                  color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
                ),
                bottom: BorderSide(
                  width: 3.0,
                  color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
                ),
              ),
            ),
            child: Center(
              child: TTLClock(matches: widget.matches),
            ),
          ),

          // Status of Match
          Container(
            padding: const EdgeInsets.fromLTRB(0, 6, 0, 5),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 3.0,
                  color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
                ),
              ),
            ),
            child: Column(
              children: [
                MatchStatus(isLoaded: widget.loadedMatches.isNotEmpty),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getStagingTable() {
    if (widget.selectedMatches.isEmpty && widget.loadedMatches.isEmpty) {
      return const Center(child: Text("No Matches Staged", style: TextStyle(fontSize: 45)));
    } else {
      if (widget.loadedMatches.isNotEmpty) {
        return DataTable2(
          headingRowColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
            return Colors.transparent;
          }),
          columnSpacing: 10,
          columns: [
            DataColumn2(label: _styledHeader("Match"), size: ColumnSize.S),
            DataColumn2(label: _styledHeader("Table")),
            DataColumn2(label: _styledHeader("Team")),
            DataColumn2(label: _styledHeader("Name"), size: ColumnSize.L),
          ],
          rows: _getRows(widget.loadedMatches),
        );
      } else {
        return DataTable2(
          headingRowColor: MaterialStateColor.resolveWith((Set<MaterialState> states) {
            return Colors.transparent;
          }),
          columnSpacing: 10,
          columns: [
            DataColumn2(label: _styledHeader("Match"), size: ColumnSize.S),
            DataColumn2(label: _styledHeader("Table")),
            DataColumn2(label: _styledHeader("Team")),
            DataColumn2(label: _styledHeader("Name"), size: ColumnSize.L),
          ],
          rows: _getRows(widget.selectedMatches),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: widget.con.maxHeight / 3,
          child: getStagingTable(),
        ),
        SizedBox(
          height: (widget.con.maxHeight / 3) * 2,
          child: getControls(),
        )
      ],
    );
  }
}
