import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms/constants.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/network/http.dart';
import 'package:tms/network/network.dart';
import 'package:tms/network/security.dart';
import 'package:tms/network/ws.dart';
import 'package:tms/requests/event_requests.dart';
import 'package:tms/requests/judging_requests.dart';
import 'package:tms/requests/match_requests.dart';
import 'package:tms/requests/team_requests.dart';
import 'package:tms/schema/tms_schema.dart';

// Database mixin for local database to update widget based on changes (update triggers only)
mixin LocalDatabaseMixin<T extends StatefulWidget> on AutoUnsubScribeMixin<T> {
  final Future<SharedPreferences> _localStorage = SharedPreferences.getInstance();

  // trigger list
  final List<Function(Event)> _eventTriggers = [];
  final List<Function(List<Team>)> _teamTriggers = [];
  final List<Function(List<GameMatch>)> _matchTriggers = [];
  final List<Function(List<JudgingSession>)> _judgingSessionTriggers = [];

  void onEventUpdate(Function(Event) callback) {
    _eventTriggers.add(callback);
  }

  void onTeamUpdate(Function(List<Team>) callback) {
    _teamTriggers.add(callback);
  }

  void onMatchUpdate(Function(List<GameMatch>) callback) {
    _matchTriggers.add(callback);
  }

  void onJudgingSessionUpdate(Function(List<JudgingSession>) callback) {
    _judgingSessionTriggers.add(callback);
  }

  void syncDatabase() async {
    var s = await Network.getStates();
    if (s.item1 == NetworkHttpConnectionState.connected && s.item2 == NetworkWebSocketState.connected && s.item3 == SecurityState.secure) {
      getEventRequest().then((value) async {
        if (value.item1 == HttpStatus.ok) {
          await _setEvent(value.item2 ?? await getEvent()); // use previous data as default
        }
      });

      getTeamsRequest().then((value) async {
        if (value.item1 == HttpStatus.ok) {
          await _setTeams(value.item2.isNotEmpty ? value.item2 : await getTeams()); // use previous data as default
        }
      });

      getMatchesRequest().then((value) async {
        if (value.item1 == HttpStatus.ok) {
          await _setMatches(value.item2.isNotEmpty ? value.item2 : await getMatches()); // use previous data as default
        }
      });

      getJudgingSessionsRequest().then((value) async {
        if (value.item1 == HttpStatus.ok) {
          await _setJudgingSessions(value.item2.isNotEmpty ? value.item2 : await getJudgingSessions()); // use previous data as default
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();

    syncDatabase();
    NetworkHttp.httpState.addListener(syncDatabase);
    NetworkWebSocket.wsState.addListener(syncDatabase);
    NetworkSecurity.securityState.addListener(syncDatabase);

    autoSubscribe("event", (m) {
      if (m.subTopic == "update") {
        getEventRequest().then((value) async {
          if (value.item1 == HttpStatus.ok) {
            _setEvent(value.item2 ?? await getEvent()); // use previous data as default
          }
        });
      }
    });

    autoSubscribe("teams", (m) {
      if (m.subTopic == "update") {
        getTeamsRequest().then((value) async {
          if (value.item1 == HttpStatus.ok) {
            _setTeams(value.item2.isNotEmpty ? value.item2 : await getTeams()); // use previous data as default
          }
        });
      }
    });

    autoSubscribe("matches", (m) {
      if (m.subTopic == "update") {
        getMatchesRequest().then((value) async {
          if (value.item1 == HttpStatus.ok) {
            _setMatches(value.item2.isNotEmpty ? value.item2 : await getMatches()); // use previous data as default
          }
        });
      }
    });

    autoSubscribe("judging_sessions", (m) {
      if (m.subTopic == "update") {
        getJudgingSessionsRequest().then((value) async {
          if (value.item1 == HttpStatus.ok) {
            _setJudgingSessions(value.item2.isNotEmpty ? value.item2 : await getJudgingSessions()); // use previous data as default
          }
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose(); // dispose will auto unsubscribe for us
    _eventTriggers.clear(); // clear all functions that were added
  }

  //
  // EVENT DATA
  //
  Event _eventDefault() {
    return Event(
      eventRounds: 3,
      name: "",
      pods: [],
      season: "",
      tables: [],
      timerLength: 150,
    );
  }

  Future<void> _setEvent(Event event) async {
    var eventJson = event.toJson();
    await _localStorage.then((value) => value.setString(storeDbEvent, jsonEncode(eventJson)));
    for (var trigger in _eventTriggers) {
      trigger(event);
    }
  }

  Future<Event> getEvent() async {
    try {
      var eventString = await _localStorage.then((value) => value.getString(storeDbEvent));
      if (eventString != null) {
        var event = Event.fromJson(jsonDecode(eventString));
        return event;
      } else {
        return _eventDefault();
      }
    } catch (e) {
      return _eventDefault();
    }
  }

  //
  // TEAM DATA
  //
  List<Team> _teamsDefault() {
    return [];
  }

  Future<void> _setTeams(List<Team> teams) async {
    var teamJson = teams.map((e) => e.toJson()).toList();
    await _localStorage.then((value) => value.setString(storeDbTeams, jsonEncode(teamJson)));
    for (var trigger in _teamTriggers) {
      trigger(teams);
    }
  }

  Future<List<Team>> getTeams() async {
    try {
      var teamsString = await _localStorage.then((value) => value.getString(storeDbTeams));
      if (teamsString != null) {
        var teams = jsonDecode(teamsString).map<Team>((e) => Team.fromJson(e)).toList();
        return teams;
      } else {
        return _teamsDefault();
      }
    } catch (e) {
      return _teamsDefault();
    }
  }

  //
  // MATCH DATA
  //
  List<GameMatch> _matchesDefault() {
    return [];
  }

  Future<void> _setMatches(List<GameMatch> matches) async {
    var matchesJson = matches.map((e) => e.toJson()).toList();
    await _localStorage.then((value) => value.setString(storeDbMatches, jsonEncode(matchesJson)));
    for (var trigger in _matchTriggers) {
      trigger(matches);
    }
  }

  Future<List<GameMatch>> getMatches() async {
    try {
      var matchesString = await _localStorage.then((value) => value.getString(storeDbMatches));
      if (matchesString != null) {
        var matches = jsonDecode(matchesString).map<GameMatch>((e) => GameMatch.fromJson(e)).toList();
        return matches;
      } else {
        return _matchesDefault();
      }
    } catch (e) {
      return _matchesDefault();
    }
  }

  //
  // JUDGING SESSION DATA
  //
  List<JudgingSession> _judgingSessionsDefault() {
    return [];
  }

  Future<void> _setJudgingSessions(List<JudgingSession> judgingSessions) async {
    var judgingSessionsJson = judgingSessions.map((e) => e.toJson()).toList();
    await _localStorage.then((value) => value.setString(storeDbJudgingSessions, jsonEncode(judgingSessionsJson)));
    for (var trigger in _judgingSessionTriggers) {
      trigger(judgingSessions);
    }
  }

  Future<List<JudgingSession>> getJudgingSessions() async {
    try {
      var judgingSessionsString = await _localStorage.then((value) => value.getString(storeDbJudgingSessions));
      if (judgingSessionsString != null) {
        var judgingSessions = jsonDecode(judgingSessionsString).map<JudgingSession>((e) => JudgingSession.fromJson(e)).toList();
        return judgingSessions;
      } else {
        return _judgingSessionsDefault();
      }
    } catch (e) {
      return _judgingSessionsDefault();
    }
  }
}
