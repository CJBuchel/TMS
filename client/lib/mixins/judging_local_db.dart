import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms/constants.dart';
import 'package:tms/requests/judging_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/sorter_util.dart';

class JudgingLocalDB {
  final Future<SharedPreferences> _ls = SharedPreferences.getInstance();

  final List<Function(List<JudgingSession>)> _listTriggers = [];
  final List<Function(JudgingSession)> _singleTriggers = [];

  bool _hasHandles = false;

  void onListUpdate(Function(List<JudgingSession>) callback) {
    _hasHandles = true;
    _listTriggers.add(callback);
  }

  void onSingleUpdate(Function(JudgingSession) callback) {
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
  static List<JudgingSession> listDefault() => [];

  static JudgingSession singleDefault() {
    return JudgingSession(
      sessionNumber: "",
      complete: false,
      judgingSessionDeferred: false,
      startTime: "",
      endTime: "",
      judgingPods: [],
    );
  }

  Future<List<JudgingSession>> getList() async {
    try {
      var listString = await _ls.then((value) => value.getString(storeDbJudgingSessions));
      if (listString != null) {
        List<JudgingSession> list = jsonDecode(listString).map<JudgingSession>((s) => JudgingSession.fromJson(s)).toList();
        return sortJudgingByTime(list);
      } else {
        return listDefault();
      }
    } catch (e) {
      return listDefault();
    }
  }

  Future<JudgingSession> getSingle(String sessionNumber) async {
    try {
      List<JudgingSession> list = await getList();
      int idx = list.indexWhere((s) => s.sessionNumber == sessionNumber);
      if (idx != -1) {
        return list[idx];
      } else {
        return singleDefault();
      }
    } catch (e) {
      return singleDefault();
    }
  }

  Future<void> _setList(List<JudgingSession> list) async {
    list = sortJudgingByTime(list);
    var listJson = list.map((e) => e.toJson()).toList();
    await _ls.then((value) => value.setString(storeDbJudgingSessions, jsonEncode(listJson)));
    // list triggers
    for (var trigger in _listTriggers) {
      trigger(list);
    }

    // single triggers
    for (JudgingSession s in list) {
      for (var trigger in _singleTriggers) {
        trigger(s);
      }
    }
  }

  Future<void> _setSingle(JudgingSession single) async {
    List<JudgingSession> list = await getList();
    int idx = list.indexWhere((element) => element.sessionNumber == single.sessionNumber);
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
      await getJudgingSessionsRequest().then((value) async {
        if (value.item1 == HttpStatus.ok) {
          await _setList(value.item2);
        }
      });
    }
  }

  Future<void> syncLocalSingle(String sessionNumber) async {
    if (_hasHandles && sessionNumber.isNotEmpty) {
      await getJudgingSessionRequest(sessionNumber).then((value) async {
        if (value.item1 == HttpStatus.ok) {
          await _setSingle(value.item2 ?? await getSingle(sessionNumber));
        }
      });
    }
  }
}
