import 'dart:convert';

import 'package:echo_tree_flutter/widgets/echo_tree_provider.dart';
import 'package:flutter/material.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/network_schemas/socket_protocol/server_socket_protocol.dart';
import 'package:tms/mixins/server_event_subscriber_mixin.dart';
import 'package:tms/network/connectivity.dart';
import 'package:tms/network/network.dart';
import 'package:tms/services/game_match_service.dart';
import 'package:tms/utils/logger.dart';
import 'package:tms/utils/tms_time_utils.dart';

abstract class _BaseGameMatchProvider extends EchoTreeProvider<String, GameMatch> {
  _BaseGameMatchProvider()
      : super(tree: ":robot_game:matches", fromJsonString: (json) => GameMatch.fromJsonString(json: json));

  List<GameMatch> get matches {
    // order matches by start time
    List<GameMatch> matches = this.items.values.toList();
    matches.sort((a, b) {
      // sort by start time
      return tmsDateTimeCompare(a.startTime, b.startTime);
    });

    return matches;
  }
}

class GameMatchProvider extends _BaseGameMatchProvider with ServerEventSubscribeNotifierMixin {
  // network callback
  late final VoidCallback _networkListener;

  GameMatchProvider() {
    _networkListener = () {
      if (Network().state != NetworkConnectionState.connected) {
        clearLoadedMatches();
      }
    };

    // listen to network state
    Network().innerNetworkStates().$1.notifier.addListener(_networkListener);
    Network().innerNetworkStates().$2.notifier.addListener(_networkListener);
    Network().innerNetworkStates().$3.notifier.addListener(_networkListener);

    subscribeToEvent(TmsServerSocketEvent.matchLoadEvent, (event) {
      if (event.message != null) {
        try {
          final json = jsonDecode(event.message!);
          TmsServerMatchLoadEvent matchLoadEvent = TmsServerMatchLoadEvent.fromJsonString(json: json);
          _loadedMatchNumbers = matchLoadEvent.gameMatchNumbers;
          notifyListeners();
        } catch (e) {
          TmsLogger().e("Error parsing match load event: $e");
        }
      } else {
        TmsLogger().e("Error parsing match load event: message is null");
      }
    });

    subscribeToEvent(TmsServerSocketEvent.matchUnloadEvent, (event) {
      try {
        _loadedMatchNumbers = [];
        notifyListeners();
      } catch (e) {
        TmsLogger().e("Error parsing match unload event: $e");
      }
    });
  }

  @override
  void dispose() {
    Network().innerNetworkStates().$1.notifier.removeListener(_networkListener);
    Network().innerNetworkStates().$2.notifier.removeListener(_networkListener);
    Network().innerNetworkStates().$3.notifier.removeListener(_networkListener);
    super.dispose();
  }

  GameMatchService _service = GameMatchService();

  //
  // -- Staging Matches --
  //

  List<String> _stagedMatchNumbers = [];

  bool isMatchStaged(String matchNumber) {
    return _stagedMatchNumbers.contains(matchNumber);
  }

  bool canStageMatch(String matchNumber) {
    // check if this match is already staged
    bool conflictingTable = stagedMatches.any((stagedMatch) {
      // check against each staged match
      GameMatch match = matches.firstWhere((match) => match.matchNumber == matchNumber);
      return match.gameMatchTables.any((table) {
        return stagedMatch.gameMatchTables.any((stagedTable) {
          return table.table == stagedTable.table;
        });
      });
    });

    return !conflictingTable;
  }

  List<GameMatch> get stagedMatches {
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

  //
  // -- Load/Unload Matches --
  //

  List<String> _loadedMatchNumbers = [];

  bool isMatchLoaded(String matchNumber) {
    return _loadedMatchNumbers.contains(matchNumber);
  }

  bool get canLoad {
    return _stagedMatchNumbers.isNotEmpty && _loadedMatchNumbers.isEmpty;
  }

  bool get canUnload {
    return _loadedMatchNumbers.isNotEmpty;
  }

  List<GameMatch> get loadedMatches {
    return matches.where((match) => _loadedMatchNumbers.contains(match.matchNumber)).toList();
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
