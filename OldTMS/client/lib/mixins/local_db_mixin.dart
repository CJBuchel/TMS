import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/event_local_db.dart';
import 'package:tms/mixins/game_local_db.dart';
import 'package:tms/mixins/judging_local_db.dart';
import 'package:tms/mixins/matches_local_db.dart';
import 'package:tms/mixins/teams_local_db.dart';
import 'package:tms/network/auth.dart';
import 'package:tms/network/http.dart';
import 'package:tms/network/network.dart';
import 'package:tms/network/security.dart';
import 'package:tms/network/ws.dart';
import 'package:tms/schema/tms_schema.dart';

// Database mixin for local database to update widget based on changes (update triggers only)
mixin LocalDatabaseMixin<T extends StatefulWidget> on AutoUnsubScribeMixin<T> {
  // teams
  final TeamsLocalDB _teamsLocalDB = TeamsLocalDB();
  void onTeamUpdate(Function(Team) callback) => _teamsLocalDB.onSingleUpdate(callback);
  void onTeamsUpdate(Function(List<Team>) callback) => _teamsLocalDB.onListUpdate(callback);
  Future<List<Team>> getTeams() => _teamsLocalDB.getList();
  Future<Team> getTeam(String teamNumber) => _teamsLocalDB.getSingle(teamNumber);

  // matches
  final MatchesLocalDB _matchesLocalDB = MatchesLocalDB();
  void onMatchUpdate(Function(GameMatch) callback) => _matchesLocalDB.onSingleUpdate(callback);
  void onMatchesUpdate(Function(List<GameMatch>) callback) => _matchesLocalDB.onListUpdate(callback);
  Future<List<GameMatch>> getMatches() => _matchesLocalDB.getList();
  Future<GameMatch> getMatch(String matchNumber) => _matchesLocalDB.getSingle(matchNumber);

  // judging
  final JudgingLocalDB _judgingLocalDB = JudgingLocalDB();
  void onJudgingSessionUpdate(Function(JudgingSession) callback) => _judgingLocalDB.onSingleUpdate(callback);
  void onJudgingSessionsUpdate(Function(List<JudgingSession>) callback) => _judgingLocalDB.onListUpdate(callback);
  Future<List<JudgingSession>> getJudgingSessions() => _judgingLocalDB.getList();
  Future<JudgingSession> getJudgingSession(String sessionNumber) => _judgingLocalDB.getSingle(sessionNumber);

  // event
  final EventLocalDB _eventLocalDB = EventLocalDB();
  void onEventUpdate(Function(Event) callback) => _eventLocalDB.onSingleUpdate(callback);
  Future<Event> getEvent() => _eventLocalDB.getSingle();

  // game
  final GameLocalDB _gameLocalDB = GameLocalDB();
  void onGameUpdate(Function(Game) callback) => _gameLocalDB.onSingleUpdate(callback);
  Future<Game> getGame() => _gameLocalDB.getSingle();

  void syncDatabase() async {
    if (await Network().isConnected()) {
      _teamsLocalDB.syncLocalList();
      _matchesLocalDB.syncLocalList();
      _judgingLocalDB.syncLocalList();
      _eventLocalDB.syncLocalSingle();
      _gameLocalDB.syncLocalSingle();
    }
  }

  @override
  void initState() {
    super.initState();

    syncDatabase();
    NetworkHttp().httpState.addListener(syncDatabase);
    NetworkWebSocket().wsState.addListener(syncDatabase);
    NetworkSecurity().securityState.addListener(syncDatabase);
    NetworkAuth().loginState.addListener(syncDatabase);

    autoSubscribe("event", (m) {
      if (m.subTopic == "update") {
        _eventLocalDB.syncLocalSingle();
      }
    });

    autoSubscribe("game", (m) {
      if (m.subTopic == "update") {
        _gameLocalDB.syncLocalSingle();
      }
    });

    autoSubscribe("teams", (m) {
      if (m.subTopic == "update") {
        _teamsLocalDB.syncLocalList();
      }
    });

    autoSubscribe("team", (m) {
      if (m.subTopic == "update") {
        _teamsLocalDB.syncLocalSingle(m.message);
      }
    });

    autoSubscribe("matches", (m) {
      if (m.subTopic == "update") {
        _matchesLocalDB.syncLocalList();
      }
    });

    autoSubscribe("match", (m) {
      if (m.subTopic == "update") {
        if (m.message.isNotEmpty) {
          _matchesLocalDB.syncLocalSingle(m.message);
        }
      }
    });

    autoSubscribe("judging_sessions", (m) {
      if (m.subTopic == "update") {
        _judgingLocalDB.syncLocalList();
      }
    });

    autoSubscribe("judging_session", (m) {
      if (m.subTopic == "update") {
        _judgingLocalDB.syncLocalSingle(m.message);
      }
    });
  }

  @override
  void dispose() {
    super.dispose(); // dispose will auto unsubscribe for us
    NetworkHttp().httpState.removeListener(syncDatabase);
    NetworkWebSocket().wsState.removeListener(syncDatabase);
    NetworkSecurity().securityState.removeListener(syncDatabase);
    NetworkAuth().loginState.removeListener(syncDatabase);

    _teamsLocalDB.dispose();
    _matchesLocalDB.dispose();
    _judgingLocalDB.dispose();
    _eventLocalDB.dispose();
    _gameLocalDB.dispose();
  }
}
