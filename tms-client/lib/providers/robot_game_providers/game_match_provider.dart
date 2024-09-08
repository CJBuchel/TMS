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

  List<GameMatch> get matches => matchesByNumber;

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

  String? getIdFromMatchNumber(String matchNumber) {
    return this.items.keys.firstWhereOrNull((key) => this.items[key]?.matchNumber == matchNumber);
  }

  Future<int> updateGameMatch(String matchNumber, GameMatch match) async {
    String? matchId = getIdFromMatchNumber(matchNumber);

    if (matchId != null) {
      return _service.updateMatch(matchId, match);
    }

    return HttpStatus.badRequest;
  }

  Future<int> removeTableFromMatch(String table, String matchNumber) async {
    GameMatch? match = this.items.values.firstWhereOrNull((match) => match.matchNumber == matchNumber);
    String? matchId = getIdFromMatchNumber(matchNumber);

    if (match != null && matchId != null) {
      match.gameMatchTables.removeWhere((gameMatchTable) => gameMatchTable.table == table);
      return _service.updateMatch(matchId, match);
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
      return _service.updateMatch(matchId, match);
    }

    return HttpStatus.badRequest;
  }

  Future<int> updateTableOnMatch(String table, String matchNumber, GameMatchTable updatedTable) async {
    GameMatch? match = this.items.values.firstWhereOrNull((match) => match.matchNumber == matchNumber);
    String? matchId = getIdFromMatchNumber(matchNumber);

    if (match != null && matchId != null) {
      match.gameMatchTables.removeWhere((gameMatchTable) => gameMatchTable.table == table);
      match.gameMatchTables.add(updatedTable);
      return _service.updateMatch(matchId, match);
    }

    return HttpStatus.badRequest;
  }
}
