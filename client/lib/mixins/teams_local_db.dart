import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms/constants.dart';
import 'package:tms/requests/team_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/sorter_util.dart';

class TeamsLocalDB {
  final Future<SharedPreferences> _ls = SharedPreferences.getInstance();

  final List<Function(List<Team>)> _listTriggers = [];
  final List<Function(Team)> _singleTriggers = [];

  bool _hasHandles = false;

  void onListUpdate(Function(List<Team>) callback) {
    _hasHandles = true;
    _listTriggers.add(callback);
  }

  void onSingleUpdate(Function(Team) callback) {
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
  static List<Team> listDefault() => [];

  static Team singleDefault() {
    return Team(
      coreValuesScores: [],
      gameScores: [],
      innovationProjectScores: [],
      ranking: 0,
      robotDesignScores: [],
      teamAffiliation: "",
      teamId: "",
      teamName: "",
      teamNumber: "",
    );
  }

  Future<List<Team>> getList() async {
    try {
      var listString = await _ls.then((value) => value.getString(storeDbTeams));
      if (listString != null) {
        List<Team> list = jsonDecode(listString).map<Team>((s) => Team.fromJson(s)).toList();
        return sortTeamsByRank(list);
      } else {
        return listDefault();
      }
    } catch (e) {
      return listDefault();
    }
  }

  Future<Team> getSingle(String teamNumber) async {
    try {
      List<Team> list = await getList();
      int idx = list.indexWhere((s) => s.teamNumber == teamNumber);
      if (idx != -1) {
        return list[idx];
      } else {
        return singleDefault();
      }
    } catch (e) {
      return singleDefault();
    }
  }

  Future<void> _setList(List<Team> list) async {
    list = sortTeamsByRank(list);
    var listJson = list.map((e) => e.toJson()).toList();
    await _ls.then((value) => value.setString(storeDbTeams, jsonEncode(listJson)));
    // list triggers
    for (var trigger in _listTriggers) {
      trigger(list);
    }

    // single triggers
    for (Team s in list) {
      for (var trigger in _singleTriggers) {
        trigger(s);
      }
    }
  }

  Future<void> _setSingle(Team single) async {
    List<Team> list = await getList();
    int idx = list.indexWhere((element) => element.teamNumber == single.teamNumber);
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
      await getTeamsRequest().then((value) async {
        if (value.item1 == HttpStatus.ok) {
          await _setList(value.item2);
        }
      });
    }
  }

  Future<void> syncLocalSingle(String teamNumber) async {
    if (_hasHandles && teamNumber.isNotEmpty) {
      await getTeamRequest(teamNumber).then((value) async {
        if (value.item1 == HttpStatus.ok) {
          await _setSingle(value.item2 ?? await getSingle(teamNumber));
        }
      });
    }
  }
}
