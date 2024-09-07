import 'package:echo_tree_flutter/widgets/echo_tree_provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/database_schemas/game_table.dart';
import 'package:tms/generated/infra/network_schemas/socket_protocol/match_state_event.dart';
import 'package:tms/generated/infra/network_schemas/socket_protocol/server_socket_protocol.dart';
import 'package:tms/mixins/server_event_subscriber_mixin.dart';
import 'package:tms/providers/local_storage_provider.dart';
import 'package:tms/utils/logger.dart';
import 'package:tms/utils/sorter_util.dart';

class GameTableProvider extends EchoTreeProvider<String, GameTable> with ServerEventSubscribeNotifierMixin {
  String _localGameTable = "";
  String _localReferee = "";
  List<String> _loadedMatchNumbers = [];

  void _onStorageChange() {
    if (_localGameTable != TmsLocalStorageProvider().gameTable) {
      _localGameTable = TmsLocalStorageProvider().gameTable;
      notifyListeners();
    }

    if (_localReferee != TmsLocalStorageProvider().gameReferee) {
      _localReferee = TmsLocalStorageProvider().gameReferee;
      notifyListeners();
    }
  }

  void _onMatchStateChange(List<String> matchNumbers) {
    if (matchNumbers != _loadedMatchNumbers) {
      _loadedMatchNumbers = matchNumbers;
      notifyListeners();
    }
  }

  GameTableProvider()
      : super(
          tree: ":robot_game:tables",
          fromJsonString: (json) => GameTable.fromJsonString(json: json),
        ) {
    _localGameTable = TmsLocalStorageProvider().gameTable;
    _localReferee = TmsLocalStorageProvider().gameReferee;
    TmsLocalStorageProvider().addListener(_onStorageChange);

    subscribeToEvent(TmsServerSocketEvent.matchStateEvent, (event) {
      if (event.message != null) {
        try {
          TmsServerMatchStateEvent matchStateEvent = TmsServerMatchStateEvent.fromJsonString(json: event.message!);
          switch (matchStateEvent.state) {
            case TmsServerMatchState.unload:
              _onMatchStateChange([]);
              break;
            case TmsServerMatchState.load:
              _onMatchStateChange(matchStateEvent.gameMatchNumbers);
              break;
            case TmsServerMatchState.ready:
              _onMatchStateChange(matchStateEvent.gameMatchNumbers);
              break;
            case TmsServerMatchState.running:
              _onMatchStateChange(matchStateEvent.gameMatchNumbers);
              break;
            default:
              break;
          }
        } catch (e) {
          TmsLogger().e("Error parsing match state event: $e");
        }
      }
    });
  }

  @override
  void dispose() {
    TmsLocalStorageProvider().removeListener(_onStorageChange);
    super.dispose();
  }

  List<GameTable> get tables => this.items.values.toList();
  List<String> get tableNames => this.items.values.map((e) => e.tableName).toList();

  // check if table is set in local storage
  // and if the table exists in the db
  bool isLocalGameTableSet() {
    bool isTableSet = _localGameTable.isNotEmpty;
    bool doesTableExist = this.items.containsValue(GameTable(tableName: _localGameTable));
    return isTableSet && doesTableExist;
  }

  String get localGameTable => _localGameTable;
  String get localReferee => _localReferee;

  set localGameTable(String table) {
    _localGameTable = table;
    TmsLocalStorageProvider().gameTable = table;
    notifyListeners();
  }

  set localReferee(String referee) {
    _localReferee = referee;
    TmsLocalStorageProvider().gameReferee = referee;
    notifyListeners();
  }

  void setLocalTableAndReferee(String table, String referee) {
    _localGameTable = table;
    _localReferee = referee;
    TmsLocalStorageProvider().gameTable = table;
    TmsLocalStorageProvider().gameReferee = referee;
    notifyListeners();
  }

  void clearLocalTable() {
    _localGameTable = "";
    TmsLocalStorageProvider().gameTable = "";
    notifyListeners();
  }

  void clearLocalReferee() {
    _localReferee = "";
    TmsLocalStorageProvider().gameReferee = "";
    notifyListeners();
  }

  List<GameMatch> getTableMatches(List<GameMatch> matches) {
    return matches.where((match) {
      return match.gameMatchTables.any((table) {
        return table.table == _localGameTable;
      });
    }).toList();
  }

  GameMatch? getNextTableMatch(List<GameMatch> matches) {
    List<GameMatch> tableMatches = sortMatchesByTime(getTableMatches(matches));

    if (tableMatches.isEmpty) {
      return null;
    }

    // check if any matches are loaded first (they take priority)
    for (GameMatch match in tableMatches) {
      if (_loadedMatchNumbers.contains(match.matchNumber)) {
        return match;
      }
    }

    // check if any matches are completed but not submitted (they take next priority)
    for (GameMatch match in tableMatches) {
      if (match.completed) {
        // check if table submitted
        bool tableSubmitted = match.gameMatchTables.any((t) => t.table == _localGameTable && t.scoreSubmitted);
        if (!tableSubmitted) {
          return match;
        }
      }
    }

    // get the next match which is not submitted
    for (GameMatch match in tableMatches) {
      bool tableSubmitted = match.gameMatchTables.any((t) => t.table == _localGameTable && t.scoreSubmitted);
      if (!tableSubmitted) {
        return match;
      }
    }

    return null;
  }
}
