import 'package:flutter/material.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/network_schemas/socket_protocol/match_state_event.dart';
import 'package:tms/generated/infra/network_schemas/socket_protocol/server_socket_protocol.dart';
import 'package:tms/mixins/server_event_subscriber_mixin.dart';
import 'package:tms/network/connectivity.dart';
import 'package:tms/network/network.dart';
import 'package:collection/collection.dart';
import 'package:tms/services/game_match_service.dart';
import 'package:tms/utils/logger.dart';

abstract class _BaseGameMatchStatusProvider extends ChangeNotifier {
  GameMatchService _service = GameMatchService();
  bool _isMatchesReady = false;
  bool _isMatchesRunning = false;
  List<String> _stagedMatchNumbers = [];
  List<String> _loadedMatchNumbers = [];
}

class _StagedGameMatchStatusProvider extends _BaseGameMatchStatusProvider {
  List<String> get stagedMatchNumbers {
    return _stagedMatchNumbers;
  }

  bool isMatchStaged(String matchNumber) {
    return _stagedMatchNumbers.contains(matchNumber);
  }

  bool canStageMatch(String matchNumber, List<GameMatch> matches) {
    // check if this match is already staged
    if (_stagedMatchNumbers.contains(matchNumber)) {
      return false;
    }

    // check if the match is already completed
    GameMatch? match = matches.firstWhereOrNull((match) => match.matchNumber == matchNumber);
    if (match == null || match.completed) {
      return false;
    }

    // check over the staged matches
    for (var stagedMatchNumber in _stagedMatchNumbers) {
      GameMatch? stagedMatch = matches.firstWhereOrNull((match) => match.matchNumber == stagedMatchNumber);

      if (stagedMatch == null) {
        return false;
      }

      // check if any table is already staged
      for (var stagedTable in stagedMatch.gameMatchTables) {
        for (var table in match.gameMatchTables) {
          if (stagedTable.table == table.table) {
            return false;
          }
        }
      }
    }

    return true;
  }

  List<GameMatch> getStagedMatches(List<GameMatch> matches) {
    return matches.where((match) => _stagedMatchNumbers.contains(match.matchNumber)).toList();
  }

  void stageMatches(List<String> matchNumbers) {
    _stagedMatchNumbers = matchNumbers;
    notifyListeners();
  }

  void clearStagedMatches() {
    _stagedMatchNumbers = [];
    notifyListeners();
  }

  void addMatchToStage(String matchNumber) {
    // add match if not already staged
    if (!_stagedMatchNumbers.contains(matchNumber)) {
      _stagedMatchNumbers = List.from(_stagedMatchNumbers)..add(matchNumber);
      notifyListeners();
    }
  }

  void removeMatchFromStage(String matchNumber) {
    // remove match if staged
    if (_stagedMatchNumbers.contains(matchNumber)) {
      _stagedMatchNumbers = List.from(_stagedMatchNumbers)..remove(matchNumber);
      notifyListeners();
    }
  }
}

class _LoadedGameMatchStatusProvider extends _StagedGameMatchStatusProvider {
  List<String> get loadedMatchNumbers {
    return _loadedMatchNumbers;
  }

  List<GameMatch> getLoadedMatches(List<GameMatch> matches) {
    return matches.where((match) => _loadedMatchNumbers.contains(match.matchNumber)).toList();
  }

  bool isMatchLoaded(String matchNumber) {
    return _loadedMatchNumbers.contains(matchNumber);
  }

  bool hasTableSubmittedPriorScoreSheets(String table, List<GameMatch> matches) {
    // get all matches that are complete
    List<GameMatch> completedMatches = matches.where((match) => match.completed).toList();

    // Check if any of the completed matches have the specified table with a submitted score sheet
    for (var match in completedMatches) {
      for (var gameMatchTable in match.gameMatchTables) {
        if (gameMatchTable.table == table && !gameMatchTable.scoreSubmitted) {
          return false;
        }
      }
    }

    // Return false if no such table is found
    return true;
  }

  bool canLoad(List<GameMatch> matches) {
    // check if all staged matches have submitted prior score sheets
    bool tablesReady = _stagedMatchNumbers.every((matchNumber) {
      GameMatch? match = matches.firstWhereOrNull((match) => match.matchNumber == matchNumber);
      if (match == null) {
        return false;
      }

      return match.gameMatchTables.every((table) {
        return hasTableSubmittedPriorScoreSheets(table.table, matches);
      });
    });
    return _stagedMatchNumbers.isNotEmpty && _loadedMatchNumbers.isEmpty && tablesReady;
  }

  bool get canUnload {
    return _loadedMatchNumbers.isNotEmpty && !_isMatchesReady;
  }

  void clearLoadedMatches() {
    _loadedMatchNumbers = [];
    notifyListeners();
  }

  Future<int> loadMatches() async {
    return await _service.loadMatches(_stagedMatchNumbers);
  }

  Future<int> unloadMatches() async {
    return await _service.unloadMatches();
  }
}

class _ReadyGameMatchStatusProvider extends _LoadedGameMatchStatusProvider {
  bool get isMatchesReady => _isMatchesReady;

  bool get canReady {
    return _loadedMatchNumbers.isNotEmpty && !_isMatchesReady;
  }

  bool get canUnready {
    return _isMatchesReady && !_isMatchesRunning;
  }

  Future<int> readyMatches() async {
    return await _service.readyMatches();
  }

  Future<int> unreadyMatches() async {
    return await _service.unreadyMatches();
  }
}

class _RunningGameMatchStatusProvider extends _ReadyGameMatchStatusProvider {
  bool get isMatchesRunning => _isMatchesRunning;

  bool isMatchRunning(String matchNumber) {
    return _loadedMatchNumbers.contains(matchNumber) && _isMatchesRunning;
  }
}

class GameMatchStatusProvider extends _RunningGameMatchStatusProvider with ServerEventSubscribeNotifierMixin {
  late final VoidCallback _networkListener;

  void _onChangeMatchStatus(bool isMatchesReady, bool isMatchesRunning, List<String> loadedMatchNumbers) {
    bool shouldNotify = false;

    if (_isMatchesReady != isMatchesReady) {
      _isMatchesReady = isMatchesReady;
      shouldNotify = true;
    }

    if (_isMatchesRunning != isMatchesRunning) {
      _isMatchesRunning = isMatchesRunning;
      shouldNotify = true;
    }

    if (!const IterableEquality().equals(_loadedMatchNumbers, loadedMatchNumbers)) {
      _loadedMatchNumbers = loadedMatchNumbers;
      shouldNotify = true;
    }

    if (shouldNotify) notifyListeners();
  }

  GameMatchStatusProvider() {
    _networkListener = () {
      if (Network().state != NetworkConnectionState.connected) {
        _isMatchesReady = false;
        _isMatchesRunning = false;
        clearLoadedMatches();
      }
    };

    // add the listener
    Network().innerNetworkStates().$1.notifier.addListener(_networkListener);
    Network().innerNetworkStates().$2.notifier.addListener(_networkListener);
    Network().innerNetworkStates().$3.notifier.addListener(_networkListener);

    subscribeToEvent(TmsServerSocketEvent.matchStateEvent, (event) {
      if (event.message != null) {
        try {
          TmsServerMatchStateEvent matchStateEvent = TmsServerMatchStateEvent.fromJsonString(json: event.message!);
          switch (matchStateEvent.state) {
            // stage 1
            case TmsServerMatchState.unload:
              _onChangeMatchStatus(false, false, []);
              break;
            // stage 2
            case TmsServerMatchState.load:
              _onChangeMatchStatus(false, false, matchStateEvent.gameMatchNumbers);
              break;
            // stage 3
            case TmsServerMatchState.ready:
              _onChangeMatchStatus(true, false, matchStateEvent.gameMatchNumbers);
              break;
            // stage 4
            case TmsServerMatchState.running:
              _onChangeMatchStatus(true, true, matchStateEvent.gameMatchNumbers);
              break;
            default:
              TmsLogger().e("Unknown match state event: ${matchStateEvent.state}");
              break;
          }
        } catch (e) {
          TmsLogger().e("Error parsing match load event: $e");
        }
      } else {
        TmsLogger().e("Error parsing match load event: message is null");
      }
    });
  }

  @override
  void dispose() {
    // remove the listener
    Network().innerNetworkStates().$1.notifier.removeListener(_networkListener);
    Network().innerNetworkStates().$2.notifier.removeListener(_networkListener);
    Network().innerNetworkStates().$3.notifier.removeListener(_networkListener);

    super.dispose();
  }
}
