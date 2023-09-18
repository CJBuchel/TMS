import 'dart:io';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:tms/requests/match_requests.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';

enum MatchLoadStatus {
  load,
  unload,
}

enum MatchUpdateStatus {
  complete,
  incomplete,
  defer,
  expedite,
}

void displayErrorDialog(int serverRes, BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text("Bad Request"),
      content: SingleChildScrollView(
        child: Text(serverRes == HttpStatus.unauthorized ? "Invalid User Permissions" : "Server Error"),
      ),
    ),
  );
}

Future<int> loadMatch(MatchLoadStatus status, BuildContext context, List<GameMatch> selectedMatches) async {
  int statusCode = HttpStatus.ok;
  switch (status) {
    case MatchLoadStatus.load:
      statusCode = await loadMatchRequest(selectedMatches.map((e) => e.matchNumber).toList());
      break;
    case MatchLoadStatus.unload:
      statusCode = await unloadMatchRequest();
      break;
  }

  return statusCode;
}

Future<int> updateMatch(MatchUpdateStatus status, BuildContext context, List<GameMatch> selectedMatches) async {
  List<GameMatch> updateMatches = List.from(selectedMatches);
  int statusCode = HttpStatus.ok;
  for (var match in updateMatches) {
    switch (status) {
      case MatchUpdateStatus.complete:
        match.complete = true;
        break;
      case MatchUpdateStatus.incomplete:
        match.complete = false;
        break;
      case MatchUpdateStatus.defer:
        match.gameMatchDeferred = true;
        break;
      case MatchUpdateStatus.expedite:
        match.gameMatchDeferred = false;
        break;
    }
    int res = await updateMatchRequest(match.matchNumber, match);
    if (res != HttpStatus.ok) {
      statusCode = res;
    }
  }

  return statusCode;
}

Widget styledHeader(String content) {
  return Center(child: Text(content, style: const TextStyle(fontWeight: FontWeight.bold)));
}

DataCell styledCell(String text, AnimationController controller, List<GameMatch> loadedMatches, {bool? isTable}) {
  return DataCell(
    AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        if ((isTable ?? false) && loadedMatches.isNotEmpty) {
          // @TODO, check if loaded and if tables have sent their ready signals
          return Container(
            color: Colors.transparent,
            // width: 100,
            child: Stack(
              children: [
                Align(
                  alignment: Responsive.isMobile(context) ? const Alignment(-1.5, 0) : Alignment.centerLeft,
                  child: Text(
                    "SIG",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: controller.value < 0.5 ? Colors.red : Colors.transparent,
                    ),
                  ),
                ),
                Align(
                  alignment: Responsive.isMobile(context) ? const Alignment(1.5, 0) : Alignment.centerRight,
                  child: const Text(
                    "OK",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Center(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          );
        }
      },
    ),
  );
}

DataRow2 _styledRow(OnTable table, String matchNumber, List<Team> teams, AnimationController controller, List<GameMatch> loadedMatches) {
  return DataRow2(cells: [
    styledCell(matchNumber, controller, loadedMatches),
    styledCell(table.table, controller, loadedMatches, isTable: true),
    styledCell(table.teamNumber, controller, loadedMatches),
    styledCell(teams.firstWhere((t) => t.teamNumber == table.teamNumber).teamName, controller, loadedMatches),
  ]);
}

List<DataRow2> getRows(List<GameMatch> matches, List<GameMatch> loadedMatches, List<Team> teams, AnimationController controller) {
  List<DataRow2> rows = [];
  for (var match in matches) {
    rows.add(_styledRow(match.onTableFirst, match.matchNumber, teams, controller, loadedMatches));
    rows.add(_styledRow(match.onTableSecond, match.matchNumber, teams, controller, loadedMatches));
  }
  return rows;
}
