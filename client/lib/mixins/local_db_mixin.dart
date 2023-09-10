import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
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

  final List<Function(List<Team>)> _teamListTriggers = [];
  final List<Function(Team)> _teamTriggers = [];

  final List<Function(List<GameMatch>)> _matchListTriggers = [];
  final List<Function(GameMatch)> _matchTriggers = [];

  final List<Function(List<JudgingSession>)> _judgingSessionListTriggers = [];
  final List<Function(JudgingSession)> _judgingSessionTriggers = [];

  void onEventUpdate(Function(Event) callback) {
    _eventTriggers.add(callback);
  }

  void onTeamsUpdate(Function(List<Team>) callback) {
    _teamListTriggers.add(callback);
  }

  void onTeamUpdate(Function(Team) callback) {
    _teamTriggers.add(callback);
  }

  void onMatchesUpdate(Function(List<GameMatch>) callback) {
    _matchListTriggers.add(callback);
  }

  void onMatchUpdate(Function(GameMatch) callback) {
    _matchTriggers.add(callback);
  }

  void onJudgingSessionsUpdate(Function(List<JudgingSession>) callback) {
    _judgingSessionListTriggers.add(callback);
  }

  void onJudgingSessionUpdate(Function(JudgingSession) callback) {
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
            _setTeams(value.item2); // use previous data as default
          }
        });
      }
    });

    autoSubscribe("team", (m) {
      if (m.subTopic == "update") {
        if (m.message != null && m.message is String) {
          Logger().i("Received team update for ${m.message}");
          getTeamRequest(m.message as String).then((value) async {
            if (value.item1 == HttpStatus.ok) {
              _setTeam(value.item2 ?? await getTeam(m.message as String)); // use previous data as default
            }
          });
        }
      }
    });

    autoSubscribe("matches", (m) {
      if (m.subTopic == "update") {
        getMatchesRequest().then((value) async {
          if (value.item1 == HttpStatus.ok) {
            _setMatches(value.item2); // use previous data as default
          }
        });
      }
    });

    autoSubscribe("match", (m) {
      if (m.subTopic == "update") {
        if (m.message != null && m.message is String) {
          Logger().i("Received match update for ${m.message}");
          getMatchRequest(m.message as String).then((value) async {
            if (value.item1 == HttpStatus.ok) {
              _setMatch(value.item2 ?? await getMatch(m.message as String)); // use previous data as default
            }
          });
        }
      }
    });

    autoSubscribe("judging_sessions", (m) {
      if (m.subTopic == "update") {
        getJudgingSessionsRequest().then((value) async {
          if (value.item1 == HttpStatus.ok) {
            _setJudgingSessions(value.item2); // use previous data as default
          }
        });
      }
    });

    autoSubscribe("judging_session", (m) {
      if (m.subTopic == "update") {
        if (m.message != null && m.message is String) {
          Logger().i("Received judging session update for ${m.message}");
          getJudgingSessionRequest(m.message as String).then((value) async {
            if (value.item1 == HttpStatus.ok) {
              _setJudgingSession(value.item2 ?? await getJudgingSession(m.message as String)); // use previous data as default
            }
          });
        }
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

  Team _teamDefault() {
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

  Future<void> _setTeams(List<Team> teams) async {
    var teamJson = teams.map((e) => e.toJson()).toList();
    await _localStorage.then((value) => value.setString(storeDbTeams, jsonEncode(teamJson)));
    for (var trigger in _teamListTriggers) {
      trigger(teams);
    }
  }

  Future<void> _setTeam(Team team) async {
    var teams = await getTeams();
    var index = teams.indexWhere((t) => t.teamNumber == team.teamNumber);
    if (index != -1) {
      teams[index] = team;
    } else {
      teams.add(team);
    }

    var teamsJson = teams.map((e) => e.toJson()).toList();
    await _localStorage.then((value) => value.setString(storeDbTeams, jsonEncode(teamsJson)));
    for (var trigger in _teamTriggers) {
      trigger(team);
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

  Future<Team> getTeam(String teamNumber) async {
    try {
      // find team in list and return
      var teams = await getTeams();
      var index = teams.indexWhere((t) => t.teamNumber == teamNumber);
      if (index != -1) {
        return teams[index];
      } else {
        return _teamDefault();
      }
    } catch (e) {
      return _teamDefault();
    }
  }

  //
  // MATCH DATA
  //
  List<GameMatch> _matchesDefault() {
    return [];
  }

  OnTable _onTableDefault() {
    return OnTable(scoreSubmitted: false, table: "", teamNumber: "");
  }

  GameMatch _matchDefault() {
    return GameMatch(
      complete: false,
      customMatch: false,
      gameMatchDeferred: false,
      endTime: "",
      matchNumber: "",
      onTableFirst: _onTableDefault(),
      onTableSecond: _onTableDefault(),
      startTime: "",
    );
  }

  Future<void> _setMatches(List<GameMatch> matches) async {
    var matchesJson = matches.map((e) => e.toJson()).toList();
    await _localStorage.then((value) => value.setString(storeDbMatches, jsonEncode(matchesJson)));
    for (var trigger in _matchListTriggers) {
      trigger(matches);
    }
  }

  Future<void> _setMatch(GameMatch match) async {
    var matches = await getMatches();
    var index = matches.indexWhere((m) => m.matchNumber == match.matchNumber);
    if (index != -1) {
      matches[index] = match;
    } else {
      matches.add(match);
    }

    var matchesJson = matches.map((e) => e.toJson()).toList();
    await _localStorage.then((value) => value.setString(storeDbMatches, jsonEncode(matchesJson)));
    for (var trigger in _matchTriggers) {
      trigger(match);
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

  Future<GameMatch> getMatch(String matchNumber) async {
    try {
      // find match in list and return
      var matches = await getMatches();
      var index = matches.indexWhere((m) => m.matchNumber == matchNumber);
      if (index != -1) {
        return matches[index];
      } else {
        return _matchDefault();
      }
    } catch (e) {
      return _matchDefault();
    }
  }

  //
  // JUDGING SESSION DATA
  //
  List<JudgingSession> _judgingSessionsDefault() {
    return [];
  }

  JudgingSession _judgingSessionDefault() {
    return JudgingSession(
      sessionNumber: "",
      complete: false,
      customSession: false,
      judgingSessionDeferred: false,
      startTime: "",
      endTime: "",
      judgingPods: [],
    );
  }

  Future<void> _setJudgingSessions(List<JudgingSession> judgingSessions) async {
    var judgingSessionsJson = judgingSessions.map((e) => e.toJson()).toList();
    await _localStorage.then((value) => value.setString(storeDbJudgingSessions, jsonEncode(judgingSessionsJson)));
    for (var trigger in _judgingSessionListTriggers) {
      trigger(judgingSessions);
    }
  }

  Future<void> _setJudgingSession(JudgingSession session) async {
    var judgingSessions = await getJudgingSessions();
    var index = judgingSessions.indexWhere((js) => js.sessionNumber == session.sessionNumber);
    if (index != -1) {
      judgingSessions[index] = session;
    } else {
      judgingSessions.add(session);
    }

    var judgingSessionsJson = judgingSessions.map((e) => e.toJson()).toList();
    await _localStorage.then((value) => value.setString(storeDbJudgingSessions, jsonEncode(judgingSessionsJson)));
    for (var trigger in _judgingSessionTriggers) {
      trigger(session);
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

  Future<JudgingSession> getJudgingSession(String sessionNumber) async {
    try {
      // find session in list and return
      var judgingSessions = await getJudgingSessions();
      var index = judgingSessions.indexWhere((js) => js.sessionNumber == sessionNumber);
      if (index != -1) {
        return judgingSessions[index];
      } else {
        return _judgingSessionDefault();
      }
    } catch (e) {
      return _judgingSessionDefault();
    }
  }
}
