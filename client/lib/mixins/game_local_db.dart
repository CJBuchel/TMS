import 'dart:convert';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms/constants.dart';
import 'package:tms/requests/game_requests.dart';
import 'package:tms/schema/tms_schema.dart';

class GameLocalDB {
  final Future<SharedPreferences> _ls = SharedPreferences.getInstance();

  final List<Function(Game)> _singleTriggers = [];

  bool _hasHandles = false;

  void onSingleUpdate(Function(Game) callback) {
    _hasHandles = true;
    _singleTriggers.add(callback);
  }

  void dispose() {
    _singleTriggers.clear();
  }

  //
  // Data sets
  //

  static Game singleDefault() {
    return Game(
      name: "",
      program: "",
      ruleBookUrl: "",
      missions: [],
      questions: [],
    );
  }

  Future<Game> getSingle() async {
    try {
      var singleString = await _ls.then((value) => value.getString(storeDbGame));
      if (singleString != null) {
        return Game.fromJson(jsonDecode(singleString));
      } else {
        return singleDefault();
      }
    } catch (e) {
      return singleDefault();
    }
  }

  Future<void> _setSingle(Game single) async {
    var singleJson = single.toJson();
    await _ls.then((value) => value.setString(storeDbGame, jsonEncode(singleJson)));
    for (var trigger in _singleTriggers) {
      Future(() async => trigger(single)).catchError((e) {
        Logger().e("Error triggering single update: $e");
      });
    }
  }

  Future<void> syncLocalSingle() async {
    if (_hasHandles) {
      await getGameRequest().then((value) async {
        if (value.item1 == HttpStatus.ok) {
          await _setSingle(value.item2 ?? await getSingle());
        }
      });
    }
  }
}
