import 'dart:io';

import 'package:echo_tree_flutter/widgets/echo_tree_provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/services/game_match_service.dart';
import 'package:tms/utils/sorter_util.dart';
import 'package:collection/collection.dart';

class GameMatchProvider extends EchoTreeProvider<String, GameMatch> {
  GameMatchService _service = GameMatchService();

  GameMatchProvider()
      : super(tree: ":robot_game:matches", fromJsonString: (json) => GameMatch.fromJsonString(json: json));

  List<GameMatch> get matches => matchesByTime;

  List<GameMatch> get matchesByNumber {
    // order matches by match number
    List<GameMatch> matches = this.items.values.toList();
    return sortMatchesByMatchNumber(matches);
  }

  List<GameMatch> get matchesByTime {
    // order matches by start time
    List<GameMatch> matches = this.items.values.toList();
    return sortMatchesByTime(matches);
  }

  List<GameMatch> getMatchesByCategory({
    required String category,
    List<String> subCategories = const [],
  }) {
    List<GameMatch> timeSortedMatches = matchesByTime;
    return timeSortedMatches.where((match) {
      if (match.category.category == category) {
        if (subCategories.isEmpty) {
          return true;
        } else {
          return match.category.subCategories.any((subCategory) => subCategories.contains(subCategory));
        }
      }

      return false;
    }).toList();
  }

  String? getIdFromMatchNumber(String matchNumber) {
    return this.items.keys.firstWhereOrNull((key) => this.items[key]?.matchNumber == matchNumber);
  }

  GameMatch? get nextMatch => matchesByTime.firstWhereOrNull((match) => !match.completed);

  List<GameMatch> getMatchesByTeamNumber(String teamNumber) {
    return matchesByTime.where((match) {
      return match.gameMatchTables.any((table) => table.teamNumber == teamNumber);
    }).toList();
  }

  GameMatch? getMatchByMatchNumber(String matchNumber) {
    return this.items.values.firstWhereOrNull((match) => match.matchNumber == matchNumber);
  }

  Future<int> insertGameMatch(String? matchNumber, GameMatch match) async {
    // try find match id from match number (if null this will create a new match using insert)
    String? matchId = matchNumber != null ? getIdFromMatchNumber(matchNumber) : null;
    return _service.insertMatch(matchId, match);
  }

  Future<int> removeGameMatch(String matchNumber) async {
    String? matchId = getIdFromMatchNumber(matchNumber);

    if (matchId != null) {
      return _service.removeMatch(matchId);
    }

    return HttpStatus.badRequest;
  }

  Future<int> removeTableFromMatch(String table, String matchNumber) async {
    GameMatch? match = this.items.values.firstWhereOrNull((match) => match.matchNumber == matchNumber);
    String? matchId = getIdFromMatchNumber(matchNumber);

    if (match != null && matchId != null) {
      match.gameMatchTables.removeWhere((gameMatchTable) => gameMatchTable.table == table);
      return _service.insertMatch(matchId, match);
    }

    return HttpStatus.badRequest;
  }

  Future<int> addTableToMatch(String table, String teamNumberOnTable, String matchNumber) async {
    GameMatch? match = this.items.values.firstWhereOrNull((match) => match.matchNumber == matchNumber);
    String? matchId = getIdFromMatchNumber(matchNumber);

    if (match != null && matchId != null) {
      match.gameMatchTables.add(
        GameMatchTable(
          table: table,
          teamNumber: teamNumberOnTable,
          scoreSubmitted: false,
        ),
      );
      return _service.insertMatch(matchId, match);
    }

    return HttpStatus.badRequest;
  }

  Future<int> updateTableOnMatch({
    required String originTable,
    required String originMatchNumber,
    required GameMatchTable updatedTable,
    String? updatedMatchNumber,
  }) async {
    if (updatedMatchNumber != null && updatedMatchNumber != originMatchNumber) {
      // handle table switch
      GameMatch? originMatch = this.items.values.firstWhereOrNull((match) => match.matchNumber == originMatchNumber);
      GameMatch? updatedMatch = this.items.values.firstWhereOrNull((match) => match.matchNumber == updatedMatchNumber);

      String? originMatchId = getIdFromMatchNumber(originMatchNumber);
      String? updatedMatchId = getIdFromMatchNumber(updatedMatchNumber);

      if (originMatch != null && updatedMatch != null && originMatchId != null && updatedMatchId != null) {
        originMatch.gameMatchTables.removeWhere((gameMatchTable) => gameMatchTable.table == originTable);
        if (updatedMatch.gameMatchTables.any((gameMatchTable) => gameMatchTable.table == updatedTable.table)) {
          return HttpStatus.badRequest;
        } else {
          updatedMatch.gameMatchTables.add(updatedTable);
        }

        int originStatus = await _service.insertMatch(originMatchId, originMatch);
        int updatedStatus = await _service.insertMatch(updatedMatchId, updatedMatch);
        return originStatus == HttpStatus.ok && updatedStatus == HttpStatus.ok ? HttpStatus.ok : HttpStatus.badRequest;
      }
    } else {
      // handle table update
      GameMatch? originMatch = this.items.values.firstWhereOrNull((match) => match.matchNumber == originMatchNumber);
      String? originMatchId = getIdFromMatchNumber(originMatchNumber);

      if (originMatch != null && originMatchId != null) {
        originMatch.gameMatchTables.removeWhere((gameMatchTable) => gameMatchTable.table == originTable);
        originMatch.gameMatchTables.add(updatedTable);
        return _service.insertMatch(originMatchId, originMatch);
      }
    }

    return HttpStatus.badRequest;
  }
}
