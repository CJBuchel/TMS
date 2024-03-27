import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/requests/match_requests.dart';
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
        child: Text(serverRes == HttpStatus.unauthorized ? "Invalid User Permissions" : "Server Error $serverRes"),
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

// checks previous matches to see if the table has submitted their scores
// returns false if the any of the selected matches still need to submit their scores
bool checkCompletedMatchesHaveScores(List<GameMatch> selectedMatches, List<GameMatch> matches) {
  for (var selectedMatch in selectedMatches) {
    // find any previous matches that are complete
    for (var previousMatch in matches.where((m) => m.complete)) {
      for (var prevOnTable in previousMatch.matchTables) {
        for (var onTable in selectedMatch.matchTables) {
          if (prevOnTable.table == onTable.table) {
            if (!prevOnTable.scoreSubmitted) {
              return false;
            }
          }
        }
      }
    }
  }

  return true;
}
