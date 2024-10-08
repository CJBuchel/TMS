// import 'package:echo_tree_flutter/widgets/echo_tree_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:tms/generated/infra/database_schemas/game_match.dart';
// import 'package:tms/generated/infra/network_schemas/socket_protocol/match_state_event.dart';
// import 'package:tms/generated/infra/network_schemas/socket_protocol/server_socket_protocol.dart';
// import 'package:tms/mixins/server_event_subscriber_mixin.dart';
// import 'package:tms/network/connectivity.dart';
// import 'package:tms/network/network.dart';
// import 'package:tms/services/game_match_service.dart';
// import 'package:tms/utils/logger.dart';
// import 'package:tms/utils/sorter_util.dart';

// //
// // @TODO, split up the provider into smaller classes
// // The game match provider should just provide matches and a few useful functions for checking matches
// // The staged matches provider should handle staging matches
// // The loaded matches provider should handle loading and unloading matches
// // The table matches provider should handle getting matches for a specific table
// // Currently, the provider is doing too much causes too many rebuilds and likely lag
// //

// abstract class _BaseGameMatchProvider extends EchoTreeProvider<String, GameMatch> {
//   GameMatchService _service = GameMatchService();

//   bool _isMatchesReady = false;
//   List<String> _stagedMatchNumbers = [];
//   List<String> _loadedMatchNumbers = [];

//   _BaseGameMatchProvider()
//       : super(tree: ":robot_game:matches", fromJsonString: (json) => GameMatch.fromJsonString(json: json));

//   List<GameMatch> get matches {
//     // order matches by start time
//     List<GameMatch> matches = this.items.values.toList();
//     return sortMatchesByTime(matches);
//   }
// }

// class _StagedMatchesProvider extends _BaseGameMatchProvider with ServerEventSubscribeNotifierMixin {
//   //
//   // -- Staging Matches --
//   //

//   bool isMatchStaged(String matchNumber) {
//     return _stagedMatchNumbers.contains(matchNumber);
//   }

//   bool canStageMatch(String matchNumber) {
//     // check if this match is already staged
//     bool conflictingTable = stagedMatches.any((stagedMatch) {
//       // check against each staged match
//       GameMatch match = matches.firstWhere((match) => match.matchNumber == matchNumber);
//       return match.gameMatchTables.any((table) {
//         return stagedMatch.gameMatchTables.any((stagedTable) {
//           return table.table == stagedTable.table;
//         });
//       });
//     });

//     return !conflictingTable;
//   }

//   List<GameMatch> get stagedMatches {
//     return matches.where((match) => _stagedMatchNumbers.contains(match.matchNumber)).toList();
//   }

//   void stageMatches(List<String> matchNumbers) {
//     _stagedMatchNumbers = matchNumbers;
//     notifyListeners();
//   }

//   void clearStagedMatches() {
//     _stagedMatchNumbers = [];
//     notifyListeners();
//   }

//   void addMatchToStage(String matchNumber) {
//     // add match if not already staged
//     if (!_stagedMatchNumbers.contains(matchNumber)) {
//       _stagedMatchNumbers = List.from(_stagedMatchNumbers)..add(matchNumber);
//       notifyListeners();
//     }
//   }

//   void removeMatchFromStage(String matchNumber) {
//     // remove match if staged
//     if (_stagedMatchNumbers.contains(matchNumber)) {
//       _stagedMatchNumbers = List.from(_stagedMatchNumbers)..remove(matchNumber);
//       notifyListeners();
//     }
//   }
// }

// class _LoadedMatchesProvider extends _StagedMatchesProvider {
//   //
//   // -- Load/Unload Matches --
//   //

//   bool isMatchLoaded(String matchNumber) {
//     return _loadedMatchNumbers.contains(matchNumber);
//   }

//   bool get canLoad {
//     return _stagedMatchNumbers.isNotEmpty && _loadedMatchNumbers.isEmpty;
//   }

//   bool get canUnload {
//     return _loadedMatchNumbers.isNotEmpty && !_isMatchesReady;
//   }

//   List<GameMatch> get loadedMatches {
//     return matches.where((match) => _loadedMatchNumbers.contains(match.matchNumber)).toList();
//   }

//   void clearLoadedMatches() {
//     _loadedMatchNumbers = [];
//     notifyListeners();
//   }

//   Future<int> loadMatches() async {
//     return await _service.loadMatches(_stagedMatchNumbers);
//   }

//   Future<int> unloadMatches() async {
//     return await _service.unloadMatches();
//   }
// }

// class _TableMatchesProvider extends _LoadedMatchesProvider {
//   //
//   // -- Table Matches --
//   //
//   List<GameMatch> getTableMatches(String table) {
//     return matches.where((match) {
//       return match.gameMatchTables.any((t) => t.table == table);
//     }).toList();
//   }

//   GameMatch? getNextTableMatch(String table) {
//     List<GameMatch> tableMatches = getTableMatches(table);
//     tableMatches = sortMatchesByTime(tableMatches);
//     if (tableMatches.isEmpty) {
//       return null;
//     }

//     // find the next match for this table

//     // check if any matches are loaded first (they take priority)
//     for (GameMatch match in tableMatches) {
//       if (isMatchLoaded(match.matchNumber)) {
//         return match;
//       }
//     }

//     // check if any matches are completed but not submitted (they take next priority)
//     for (GameMatch match in tableMatches) {
//       if (match.completed) {
//         // check if table submitted
//         bool tableSubmitted = match.gameMatchTables.any((t) => t.table == table && t.scoreSubmitted);
//         if (!tableSubmitted) {
//           return match;
//         }
//       }
//     }

//     // get the next match which is either incomplete
//     for (GameMatch match in tableMatches) {
//       if (!match.completed) {
//         return match;
//       }
//     }

//     return null;
//   }
// }

// class GameMatchProvider extends _TableMatchesProvider {
//   // network callback
//   late final VoidCallback _networkListener;

//   GameMatchProvider() {
//     _networkListener = () {
//       if (Network().state != NetworkConnectionState.connected) {
//         clearLoadedMatches();
//         _isMatchesReady = false;
//         _isMatchesRunning = false;
//       }
//     };

//     // listen to network state
//     Network().innerNetworkStates().$1.notifier.addListener(_networkListener);
//     Network().innerNetworkStates().$2.notifier.addListener(_networkListener);
//     Network().innerNetworkStates().$3.notifier.addListener(_networkListener);

//     subscribeToEvent(TmsServerSocketEvent.matchStateEvent, (event) {
//       if (event.message != null) {
//         try {
//           TmsServerMatchStateEvent matchStateEvent = TmsServerMatchStateEvent.fromJsonString(json: event.message!);
//           switch (matchStateEvent.state) {
//             // stage 1
//             case TmsServerMatchState.unload:
//               _loadedMatchNumbers = [];
//               _isMatchesReady = false;
//               _isMatchesRunning = false;
//               break;
//             // stage 2
//             case TmsServerMatchState.load:
//               _loadedMatchNumbers = matchStateEvent.gameMatchNumbers;
//               _isMatchesReady = false;
//               _isMatchesRunning = false;
//               break;
//             // stage 3
//             case TmsServerMatchState.ready:
//               _loadedMatchNumbers = matchStateEvent.gameMatchNumbers;
//               _isMatchesReady = true;
//               _isMatchesRunning = false;
//               break;
//             // stage 4
//             case TmsServerMatchState.running:
//               _loadedMatchNumbers = matchStateEvent.gameMatchNumbers;
//               _isMatchesReady = true;
//               _isMatchesRunning = true;
//               break;
//             default:
//               TmsLogger().e("Unknown match state event: ${matchStateEvent.state}");
//               break;
//           }
//           _loadedMatchNumbers = matchStateEvent.gameMatchNumbers;
//           notifyListeners();
//         } catch (e) {
//           TmsLogger().e("Error parsing match load event: $e");
//         }
//       } else {
//         TmsLogger().e("Error parsing match load event: message is null");
//       }
//     });
//   }

//   @override
//   void dispose() {
//     Network().innerNetworkStates().$1.notifier.removeListener(_networkListener);
//     Network().innerNetworkStates().$2.notifier.removeListener(_networkListener);
//     Network().innerNetworkStates().$3.notifier.removeListener(_networkListener);
//     super.dispose();
//   }

//   //
//   // -- Ready/Unready Matches --
//   //

//   bool get isReady => _isMatchesReady;

//   bool get canReady {
//     return _loadedMatchNumbers.isNotEmpty && !_isMatchesReady;
//   }

//   bool get canUnready {
//     return _isMatchesReady && !_isMatchesRunning;
//   }

//   Future<int> readyMatches() async {
//     return await _service.readyMatches();
//   }

//   Future<int> unreadyMatches() async {
//     return await _service.unreadyMatches();
//   }

//   //
//   // -- Running Matches --
//   //
//   bool _isMatchesRunning = false;
//   bool isMatchRunning(String matchNumber) {
//     return _loadedMatchNumbers.contains(matchNumber) && _isMatchesRunning;
//   }

//   bool get isMatchesRunning => _isMatchesRunning;
// }
