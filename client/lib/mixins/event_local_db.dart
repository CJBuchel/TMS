import 'dart:convert';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms/constants.dart';
import 'package:tms/requests/event_requests.dart';
import 'package:tms/schema/tms_schema.dart';

class EventLocalDB {
  final Future<SharedPreferences> _ls = SharedPreferences.getInstance();

  final List<Function(Event)> _singleTriggers = [];

  bool _hasHandles = false;

  void onSingleUpdate(Function(Event) callback) {
    _hasHandles = true;
    _singleTriggers.add(callback);
  }

  void dispose() {
    _singleTriggers.clear();
  }

  //
  // Data sets
  //

  static Event singleDefault() {
    return Event(
      eventRounds: 3,
      name: "",
      pods: [],
      season: "",
      tables: [],
      endGameTimerLength: 30,
      timerLength: 150,
    );
  }

  Future<Event> getSingle() async {
    try {
      var singleString = await _ls.then((value) => value.getString(storeDbEvent));
      if (singleString != null) {
        return Event.fromJson(jsonDecode(singleString));
      } else {
        return singleDefault();
      }
    } catch (e) {
      return singleDefault();
    }
  }

  Future<void> _setSingle(Event single) async {
    var singleJson = single.toJson();
    await _ls.then((value) => value.setString(storeDbEvent, jsonEncode(singleJson)));
    for (var trigger in _singleTriggers) {
      Future(() => trigger(single)).catchError((e) {
        Logger().e("Error triggering single update: $e");
      });
    }
  }

  Future<void> syncLocalSingle() async {
    if (_hasHandles) {
      await getEventRequest().then((value) async {
        if (value.item1 == HttpStatus.ok) {
          await _setSingle(value.item2 ?? await getSingle());
        }
      });
    }
  }
}
