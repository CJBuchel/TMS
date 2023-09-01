// To parse this JSON data, do
//
//     final tmsSchema = tmsSchemaFromJson(jsonString);

import 'dart:convert';

TmsSchema tmsSchemaFromJson(String str) => TmsSchema.fromJson(json.decode(str));

String tmsSchemaToJson(TmsSchema data) => json.encode(data.toJson());

class TmsSchema {
    TmsSchema({
        required this.event,
        required this.gameMatch,
        required this.integrityMessage,
        required this.judgingSession,
        required this.loginRequest,
        required this.loginResponse,
        required this.registerRequest,
        required this.registerResponse,
        required this.socketEvent,
        required this.startTimerRequest,
        required this.team,
        required this.users,
    });

    Event event;
    GameMatch gameMatch;
    IntegrityMessage integrityMessage;
    JudgingSession judgingSession;
    LoginRequest loginRequest;
    LoginResponse loginResponse;
    RegisterRequest registerRequest;
    RegisterResponse registerResponse;
    SocketMessage socketEvent;
    StartTimerRequest startTimerRequest;
    Team team;
    User users;

    factory TmsSchema.fromJson(Map<String, dynamic> json) => TmsSchema(
        event: Event.fromJson(json["event"]),
        gameMatch: GameMatch.fromJson(json["game_match"]),
        integrityMessage: IntegrityMessage.fromJson(json["integrity_message"]),
        judgingSession: JudgingSession.fromJson(json["judging_session"]),
        loginRequest: LoginRequest.fromJson(json["login_request"]),
        loginResponse: LoginResponse.fromJson(json["login_response"]),
        registerRequest: RegisterRequest.fromJson(json["register_request"]),
        registerResponse: RegisterResponse.fromJson(json["register_response"]),
        socketEvent: SocketMessage.fromJson(json["socket_event"]),
        startTimerRequest: StartTimerRequest.fromJson(json["start_timer_request"]),
        team: Team.fromJson(json["team"]),
        users: User.fromJson(json["users"]),
    );

    Map<String, dynamic> toJson() => {
        "event": event.toJson(),
        "game_match": gameMatch.toJson(),
        "integrity_message": integrityMessage.toJson(),
        "judging_session": judgingSession.toJson(),
        "login_request": loginRequest.toJson(),
        "login_response": loginResponse.toJson(),
        "register_request": registerRequest.toJson(),
        "register_response": registerResponse.toJson(),
        "socket_event": socketEvent.toJson(),
        "start_timer_request": startTimerRequest.toJson(),
        "team": team.toJson(),
        "users": users.toJson(),
    };
}

class Event {
    Event({
        required this.eventRounds,
        required this.name,
        required this.onlineLink,
        required this.pods,
        required this.season,
        required this.tables,
        required this.timerLength,
    });

    int eventRounds;
    String name;
    OnlineLink onlineLink;
    List<String> pods;
    String season;
    List<String> tables;
    int timerLength;

    factory Event.fromJson(Map<String, dynamic> json) => Event(
        eventRounds: json["event_rounds"],
        name: json["name"],
        onlineLink: OnlineLink.fromJson(json["online_link"]),
        pods: List<String>.from(json["pods"].map((x) => x)),
        season: json["season"],
        tables: List<String>.from(json["tables"].map((x) => x)),
        timerLength: json["timer_length"],
    );

    Map<String, dynamic> toJson() => {
        "event_rounds": eventRounds,
        "name": name,
        "online_link": onlineLink.toJson(),
        "pods": List<dynamic>.from(pods.map((x) => x)),
        "season": season,
        "tables": List<dynamic>.from(tables.map((x) => x)),
        "timer_length": timerLength,
    };
}

class OnlineLink {
    OnlineLink({
        required this.linked,
        required this.tournamentId,
        required this.tournamentToken,
    });

    bool linked;
    String tournamentId;
    String tournamentToken;

    factory OnlineLink.fromJson(Map<String, dynamic> json) => OnlineLink(
        linked: json["linked"],
        tournamentId: json["tournament_id"],
        tournamentToken: json["tournament_token"],
    );

    Map<String, dynamic> toJson() => {
        "linked": linked,
        "tournament_id": tournamentId,
        "tournament_token": tournamentToken,
    };
}

class GameMatch {
    GameMatch({
        required this.complete,
        required this.customMatch,
        required this.gameMatchDeferred,
        required this.endTime,
        required this.matchNumber,
        required this.onTableFirst,
        required this.onTableSecond,
        required this.startTime,
    });

    bool complete;
    bool customMatch;
    bool gameMatchDeferred;
    String endTime;
    String matchNumber;
    OnTable onTableFirst;
    OnTable onTableSecond;
    String startTime;

    factory GameMatch.fromJson(Map<String, dynamic> json) => GameMatch(
        complete: json["complete"],
        customMatch: json["custom_match"],
        gameMatchDeferred: json["deferred"],
        endTime: json["end_time"],
        matchNumber: json["match_number"],
        onTableFirst: OnTable.fromJson(json["on_table_first"]),
        onTableSecond: OnTable.fromJson(json["on_table_second"]),
        startTime: json["start_time"],
    );

    Map<String, dynamic> toJson() => {
        "complete": complete,
        "custom_match": customMatch,
        "deferred": gameMatchDeferred,
        "end_time": endTime,
        "match_number": matchNumber,
        "on_table_first": onTableFirst.toJson(),
        "on_table_second": onTableSecond.toJson(),
        "start_time": startTime,
    };
}

class OnTable {
    OnTable({
        required this.scoreSubmitted,
        required this.table,
        required this.teamNumber,
    });

    bool scoreSubmitted;
    String table;
    String teamNumber;

    factory OnTable.fromJson(Map<String, dynamic> json) => OnTable(
        scoreSubmitted: json["score_submitted"],
        table: json["table"],
        teamNumber: json["team_number"],
    );

    Map<String, dynamic> toJson() => {
        "score_submitted": scoreSubmitted,
        "table": table,
        "team_number": teamNumber,
    };
}

class IntegrityMessage {
    IntegrityMessage({
        required this.message,
    });

    String message;

    factory IntegrityMessage.fromJson(Map<String, dynamic> json) => IntegrityMessage(
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "message": message,
    };
}

class JudgingSession {
    JudgingSession({
        required this.complete,
        required this.customSession,
        required this.judgingSessionDeferred,
        required this.endTime,
        required this.room,
        required this.session,
        required this.startTime,
        required this.teamNumber,
    });

    bool complete;
    bool customSession;
    bool judgingSessionDeferred;
    String endTime;
    String room;
    String session;
    String startTime;
    String teamNumber;

    factory JudgingSession.fromJson(Map<String, dynamic> json) => JudgingSession(
        complete: json["complete"],
        customSession: json["custom_session"],
        judgingSessionDeferred: json["deferred"],
        endTime: json["end_time"],
        room: json["room"],
        session: json["session"],
        startTime: json["start_time"],
        teamNumber: json["team_number"],
    );

    Map<String, dynamic> toJson() => {
        "complete": complete,
        "custom_session": customSession,
        "deferred": judgingSessionDeferred,
        "end_time": endTime,
        "room": room,
        "session": session,
        "start_time": startTime,
        "team_number": teamNumber,
    };
}

class LoginRequest {
    LoginRequest({
        required this.password,
        required this.username,
    });

    String password;
    String username;

    factory LoginRequest.fromJson(Map<String, dynamic> json) => LoginRequest(
        password: json["password"],
        username: json["username"],
    );

    Map<String, dynamic> toJson() => {
        "password": password,
        "username": username,
    };
}

class LoginResponse {
    LoginResponse({
        required this.authToken,
        required this.permissions,
    });

    String authToken;
    Permissions permissions;

    factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        authToken: json["auth_token"],
        permissions: Permissions.fromJson(json["permissions"]),
    );

    Map<String, dynamic> toJson() => {
        "auth_token": authToken,
        "permissions": permissions.toJson(),
    };
}

class Permissions {
    Permissions({
        required this.admin,
        this.headReferee,
        this.judge,
        this.judgeAdvisor,
        this.referee,
    });

    bool admin;
    bool? headReferee;
    bool? judge;
    bool? judgeAdvisor;
    bool? referee;

    factory Permissions.fromJson(Map<String, dynamic> json) => Permissions(
        admin: json["admin"],
        headReferee: json["head_referee"],
        judge: json["judge"],
        judgeAdvisor: json["judge_advisor"],
        referee: json["referee"],
    );

    Map<String, dynamic> toJson() => {
        "admin": admin,
        "head_referee": headReferee,
        "judge": judge,
        "judge_advisor": judgeAdvisor,
        "referee": referee,
    };
}

class RegisterRequest {
    RegisterRequest({
        required this.key,
        required this.userId,
    });

    String key;
    String userId;

    factory RegisterRequest.fromJson(Map<String, dynamic> json) => RegisterRequest(
        key: json["key"],
        userId: json["user_id"],
    );

    Map<String, dynamic> toJson() => {
        "key": key,
        "user_id": userId,
    };
}

class RegisterResponse {
    RegisterResponse({
        required this.key,
        required this.urlPath,
        required this.urlScheme,
        required this.version,
    });

    String key;
    String urlPath;
    String urlScheme;
    String version;

    factory RegisterResponse.fromJson(Map<String, dynamic> json) => RegisterResponse(
        key: json["key"],
        urlPath: json["url_path"],
        urlScheme: json["url_scheme"],
        version: json["version"],
    );

    Map<String, dynamic> toJson() => {
        "key": key,
        "url_path": urlPath,
        "url_scheme": urlScheme,
        "version": version,
    };
}

class SocketMessage {
    SocketMessage({
        this.fromId,
        this.message,
        this.subTopic,
        required this.topic,
    });

    String? fromId;
    String? message;
    String? subTopic;
    String topic;

    factory SocketMessage.fromJson(Map<String, dynamic> json) => SocketMessage(
        fromId: json["from_id"],
        message: json["message"],
        subTopic: json["sub_topic"],
        topic: json["topic"],
    );

    Map<String, dynamic> toJson() => {
        "from_id": fromId,
        "message": message,
        "sub_topic": subTopic,
        "topic": topic,
    };
}

class StartTimerRequest {
    StartTimerRequest({
        required this.authToken,
    });

    String authToken;

    factory StartTimerRequest.fromJson(Map<String, dynamic> json) => StartTimerRequest(
        authToken: json["auth_token"],
    );

    Map<String, dynamic> toJson() => {
        "auth_token": authToken,
    };
}

class Team {
    Team({
        required this.coreValuesScores,
        required this.gameScores,
        required this.innovationProjectScores,
        required this.ranking,
        required this.robotDesignScores,
        required this.teamAffiliation,
        required this.teamId,
        required this.teamName,
        required this.teamNumber,
    });

    List<JudgingScoresheet> coreValuesScores;
    List<GameScoresheet> gameScores;
    List<JudgingScoresheet> innovationProjectScores;
    int ranking;
    List<JudgingScoresheet> robotDesignScores;
    String teamAffiliation;
    String teamId;
    String teamName;
    String teamNumber;

    factory Team.fromJson(Map<String, dynamic> json) => Team(
        coreValuesScores: List<JudgingScoresheet>.from(json["core_values_scores"].map((x) => JudgingScoresheet.fromJson(x))),
        gameScores: List<GameScoresheet>.from(json["game_scores"].map((x) => GameScoresheet.fromJson(x))),
        innovationProjectScores: List<JudgingScoresheet>.from(json["innovation_project_scores"].map((x) => JudgingScoresheet.fromJson(x))),
        ranking: json["ranking"],
        robotDesignScores: List<JudgingScoresheet>.from(json["robot_design_scores"].map((x) => JudgingScoresheet.fromJson(x))),
        teamAffiliation: json["team_affiliation"],
        teamId: json["team_id"],
        teamName: json["team_name"],
        teamNumber: json["team_number"],
    );

    Map<String, dynamic> toJson() => {
        "core_values_scores": List<dynamic>.from(coreValuesScores.map((x) => x.toJson())),
        "game_scores": List<dynamic>.from(gameScores.map((x) => x.toJson())),
        "innovation_project_scores": List<dynamic>.from(innovationProjectScores.map((x) => x.toJson())),
        "ranking": ranking,
        "robot_design_scores": List<dynamic>.from(robotDesignScores.map((x) => x.toJson())),
        "team_affiliation": teamAffiliation,
        "team_id": teamId,
        "team_name": teamName,
        "team_number": teamNumber,
    };
}

class JudgingScoresheet {
    JudgingScoresheet({
        required this.answers,
        required this.feedbackCrit,
        required this.feedbackPros,
        required this.teamId,
        required this.tournamentId,
    });

    List<Answer> answers;
    String feedbackCrit;
    String feedbackPros;
    String teamId;
    String tournamentId;

    factory JudgingScoresheet.fromJson(Map<String, dynamic> json) => JudgingScoresheet(
        answers: List<Answer>.from(json["answers"].map((x) => Answer.fromJson(x))),
        feedbackCrit: json["feedback_crit"],
        feedbackPros: json["feedback_pros"],
        teamId: json["team_id"],
        tournamentId: json["tournament_id"],
    );

    Map<String, dynamic> toJson() => {
        "answers": List<dynamic>.from(answers.map((x) => x.toJson())),
        "feedback_crit": feedbackCrit,
        "feedback_pros": feedbackPros,
        "team_id": teamId,
        "tournament_id": tournamentId,
    };
}

class Answer {
    Answer({
        required this.answer,
        required this.id,
    });

    String answer;
    String id;

    factory Answer.fromJson(Map<String, dynamic> json) => Answer(
        answer: json["answer"],
        id: json["id"],
    );

    Map<String, dynamic> toJson() => {
        "answer": answer,
        "id": id,
    };
}

class GameScoresheet {
    GameScoresheet({
        required this.answers,
        required this.privateComment,
        required this.publicComment,
        required this.round,
        required this.teamId,
        required this.tournamentId,
    });

    List<Answer> answers;
    String privateComment;
    String publicComment;
    int round;
    String teamId;
    String tournamentId;

    factory GameScoresheet.fromJson(Map<String, dynamic> json) => GameScoresheet(
        answers: List<Answer>.from(json["answers"].map((x) => Answer.fromJson(x))),
        privateComment: json["private_comment"],
        publicComment: json["public_comment"],
        round: json["round"],
        teamId: json["team_id"],
        tournamentId: json["tournament_id"],
    );

    Map<String, dynamic> toJson() => {
        "answers": List<dynamic>.from(answers.map((x) => x.toJson())),
        "private_comment": privateComment,
        "public_comment": publicComment,
        "round": round,
        "team_id": teamId,
        "tournament_id": tournamentId,
    };
}

class User {
    User({
        required this.password,
        required this.permissions,
        required this.username,
    });

    String password;
    Permissions permissions;
    String username;

    factory User.fromJson(Map<String, dynamic> json) => User(
        password: json["password"],
        permissions: Permissions.fromJson(json["permissions"]),
        username: json["username"],
    );

    Map<String, dynamic> toJson() => {
        "password": password,
        "permissions": permissions.toJson(),
        "username": username,
    };
}
