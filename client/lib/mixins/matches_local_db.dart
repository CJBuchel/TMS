import 'dart:convert';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms/constants.dart';
import 'package:tms/requests/match_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/sorter_util.dart';

class MatchesLocalDB {
  final Future<SharedPreferences> _ls = SharedPreferences.getInstance();

  final List<Function(List<GameMatch>)> _listTriggers = [];
  final List<Function(GameMatch)> _singleTriggers = [];

  bool _hasHandles = false;

  void onListUpdate(Function(List<GameMatch>) callback) {
    _hasHandles = true;
    _listTriggers.add(callback);
  }

  void onSingleUpdate(Function(GameMatch) callback) {
    _hasHandles = true;
    _singleTriggers.add(callback);
  }

  void dispose() {
    _listTriggers.clear();
    _singleTriggers.clear();
  }

  //
  // Data sets
  //
  static List<GameMatch> listDefault() => [];

  static GameMatch singleDefault() {
    return GameMatch(
      complete: false,
      exhibitionMatch: false,
      gameMatchDeferred: false,
      endTime: "",
      matchNumber: "",
      roundNumber: 0,
      matchTables: [],
      startTime: "",
    );
  }

  Future<List<GameMatch>> getList() async {
    try {
      var listString = await _ls.then((value) => value.getString(storeDbMatches));
      if (listString != null) {
        List<GameMatch> list = jsonDecode(listString).map<GameMatch>((s) => GameMatch.fromJson(s)).toList();
        return sortMatchesByTime(list);
      } else {
        return listDefault();
      }
    } catch (e) {
      return listDefault();
    }
  }

  Future<GameMatch> getSingle(String matchNumber) async {
    try {
      List<GameMatch> list = await getList();
      int idx = list.indexWhere((s) => s.matchNumber == matchNumber);
      if (idx != -1) {
        return list[idx];
      } else {
        return singleDefault();
      }
    } catch (e) {
      return singleDefault();
    }
  }

  Future<void> _setList(List<GameMatch> list) async {
    list = sortMatchesByTime(list);
    var listJson = list.map((e) => e.toJson()).toList();
    await _ls.then((value) => value.setString(storeDbMatches, jsonEncode(listJson)));
    // list triggers
    for (var trigger in _listTriggers) {
      Future(() => trigger(list)).catchError((e) {
        Logger().e("Error triggering list update: $e");
      });
    }

    // single triggers
    for (GameMatch s in list) {
      Future(() {
        for (var trigger in _singleTriggers) {
          Future(() => trigger(s)).catchError((e) {
            Logger().e("Error triggering single update: $e");
          });
        }
      });
    }
  }

  Future<void> _setSingle(GameMatch single) async {
    List<GameMatch> list = await getList();
    int idx = list.indexWhere((element) => element.matchNumber == single.matchNumber);
    if (idx != -1) {
      list[idx] = single;
    } else {
      list.add(single);
    }

    // update the list
    _setList(list);
  }

  Future<void> syncLocalList() async {
    if (_hasHandles) {
      await getMatchesRequest().then((value) async {
        if (value.item1 == HttpStatus.ok) {
          await _setList(value.item2);
        }
      });
    }
  }

  Future<void> syncLocalSingle(String matchNumber) async {
    if (_hasHandles && matchNumber.isNotEmpty) {
      await getMatchRequest(matchNumber).then((value) async {
        if (value.item1 == HttpStatus.ok) {
          await _setSingle(value.item2 ?? await getSingle(matchNumber));
        }
      });
    }
  }
}
