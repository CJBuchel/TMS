// To parse this JSON data, do
//
//     final tmsSchema = tmsSchemaFromJson(jsonString);

import 'dart:convert';

TmsSchema tmsSchemaFromJson(String str) => TmsSchema.fromJson(json.decode(str));

String tmsSchemaToJson(TmsSchema data) => json.encode(data.toJson());

class TmsSchema {
    TmsSchema({
        required this.addUserRequest,
        required this.deleteUserRequest,
        required this.event,
        required this.eventGetApiLinkRequest,
        required this.eventGetApiLinkResponse,
        required this.eventsGetResponse,
        required this.gameGetResponse,
        required this.gameMatch,
        required this.integrityMessage,
        required this.judgingSession,
        required this.judgingSessionAddRequest,
        required this.judgingSessionDeleteRequest,
        required this.judgingSessionGetRequest,
        required this.judgingSessionGetResponse,
        required this.judgingSessionUpdateRequest,
        required this.judgingSessionsGetResponse,
        required this.loginRequest,
        required this.loginResponse,
        required this.matchAddRequest,
        required this.matchDeleteRequest,
        required this.matchGetRequest,
        required this.matchGetResponse,
        required this.matchLoadedRequest,
        required this.matchUpdateRequest,
        required this.matchesGetResponse,
        required this.missionsGetResponse,
        required this.proxyBytesResponse,
        required this.purgeRequest,
        required this.questionsGetResponse,
        required this.questionsValidateRequest,
        required this.questionsValidateResponse,
        required this.registerRequest,
        required this.registerResponse,
        required this.seasonsGetResponse,
        required this.setupRequest,
        required this.socketEvent,
        required this.socketMatchLoadedMessage,
        required this.startTimerRequest,
        required this.team,
        required this.teamAddRequest,
        required this.teamDeleteRequest,
        required this.teamGetRequest,
        required this.teamGetResponse,
        required this.teamPostGameScoresheetRequest,
        required this.teamUpdateRequest,
        required this.teamsGetResponse,
        required this.updateUserRequest,
        required this.users,
        required this.usersRequest,
        required this.usersResponse,
    });

    AddUserRequest addUserRequest;
    DeleteUserRequest deleteUserRequest;
    Event event;
    ApiLinkRequest eventGetApiLinkRequest;
    ApiLinkResponse eventGetApiLinkResponse;
    EventResponse eventsGetResponse;
    GameResponse gameGetResponse;
    GameMatch gameMatch;
    IntegrityMessage integrityMessage;
    JudgingSession judgingSession;
    JudgingSessionAddRequest judgingSessionAddRequest;
    JudgingSessionDeleteRequest judgingSessionDeleteRequest;
    JudgingSessionRequest judgingSessionGetRequest;
    JudgingSessionResponse judgingSessionGetResponse;
    JudgingSessionUpdateRequest judgingSessionUpdateRequest;
    JudgingSessionsResponse judgingSessionsGetResponse;
    LoginRequest loginRequest;
    LoginResponse loginResponse;
    MatchAddRequest matchAddRequest;
    MatchDeleteRequest matchDeleteRequest;
    MatchRequest matchGetRequest;
    MatchResponse matchGetResponse;
    MatchLoadRequest matchLoadedRequest;
    MatchUpdateRequest matchUpdateRequest;
    MatchesResponse matchesGetResponse;
    MissionsResponse missionsGetResponse;
    ProxyBytesResponse proxyBytesResponse;
    PurgeRequest purgeRequest;
    QuestionsResponse questionsGetResponse;
    QuestionsValidateRequest questionsValidateRequest;
    QuestionsValidateResponse questionsValidateResponse;
    RegisterRequest registerRequest;
    RegisterResponse registerResponse;
    SeasonsResponse seasonsGetResponse;
    SetupRequest setupRequest;
    SocketMessage socketEvent;
    SocketMatchLoadedMessage socketMatchLoadedMessage;
    TimerRequest startTimerRequest;
    Team team;
    TeamAddRequest teamAddRequest;
    TeamDeleteRequest teamDeleteRequest;
    TeamRequest teamGetRequest;
    TeamResponse teamGetResponse;
    TeamPostGameScoresheetRequest teamPostGameScoresheetRequest;
    TeamUpdateRequest teamUpdateRequest;
    TeamsResponse teamsGetResponse;
    UpdateUserRequest updateUserRequest;
    User users;
    UsersRequest usersRequest;
    UsersResponse usersResponse;

    factory TmsSchema.fromJson(Map<String, dynamic> json) => TmsSchema(
        addUserRequest: AddUserRequest.fromJson(json["add_user_request"]),
        deleteUserRequest: DeleteUserRequest.fromJson(json["delete_user_request"]),
        event: Event.fromJson(json["event"]),
        eventGetApiLinkRequest: ApiLinkRequest.fromJson(json["event_get_api_link_request"]),
        eventGetApiLinkResponse: ApiLinkResponse.fromJson(json["event_get_api_link_response"]),
        eventsGetResponse: EventResponse.fromJson(json["events_get_response"]),
        gameGetResponse: GameResponse.fromJson(json["game_get_response"]),
        gameMatch: GameMatch.fromJson(json["game_match"]),
        integrityMessage: IntegrityMessage.fromJson(json["integrity_message"]),
        judgingSession: JudgingSession.fromJson(json["judging_session"]),
        judgingSessionAddRequest: JudgingSessionAddRequest.fromJson(json["judging_session_add_request"]),
        judgingSessionDeleteRequest: JudgingSessionDeleteRequest.fromJson(json["judging_session_delete_request"]),
        judgingSessionGetRequest: JudgingSessionRequest.fromJson(json["judging_session_get_request"]),
        judgingSessionGetResponse: JudgingSessionResponse.fromJson(json["judging_session_get_response"]),
        judgingSessionUpdateRequest: JudgingSessionUpdateRequest.fromJson(json["judging_session_update_request"]),
        judgingSessionsGetResponse: JudgingSessionsResponse.fromJson(json["judging_sessions_get_response"]),
        loginRequest: LoginRequest.fromJson(json["login_request"]),
        loginResponse: LoginResponse.fromJson(json["login_response"]),
        matchAddRequest: MatchAddRequest.fromJson(json["match_add_request"]),
        matchDeleteRequest: MatchDeleteRequest.fromJson(json["match_delete_request"]),
        matchGetRequest: MatchRequest.fromJson(json["match_get_request"]),
        matchGetResponse: MatchResponse.fromJson(json["match_get_response"]),
        matchLoadedRequest: MatchLoadRequest.fromJson(json["match_loaded_request"]),
        matchUpdateRequest: MatchUpdateRequest.fromJson(json["match_update_request"]),
        matchesGetResponse: MatchesResponse.fromJson(json["matches_get_response"]),
        missionsGetResponse: MissionsResponse.fromJson(json["missions_get_response"]),
        proxyBytesResponse: ProxyBytesResponse.fromJson(json["proxy_bytes_response"]),
        purgeRequest: PurgeRequest.fromJson(json["purge_request"]),
        questionsGetResponse: QuestionsResponse.fromJson(json["questions_get_response"]),
        questionsValidateRequest: QuestionsValidateRequest.fromJson(json["questions_validate_request"]),
        questionsValidateResponse: QuestionsValidateResponse.fromJson(json["questions_validate_response"]),
        registerRequest: RegisterRequest.fromJson(json["register_request"]),
        registerResponse: RegisterResponse.fromJson(json["register_response"]),
        seasonsGetResponse: SeasonsResponse.fromJson(json["seasons_get_response"]),
        setupRequest: SetupRequest.fromJson(json["setup_request"]),
        socketEvent: SocketMessage.fromJson(json["socket_event"]),
        socketMatchLoadedMessage: SocketMatchLoadedMessage.fromJson(json["socket_match_loaded_message"]),
        startTimerRequest: TimerRequest.fromJson(json["start_timer_request"]),
        team: Team.fromJson(json["team"]),
        teamAddRequest: TeamAddRequest.fromJson(json["team_add_request"]),
        teamDeleteRequest: TeamDeleteRequest.fromJson(json["team_delete_request"]),
        teamGetRequest: TeamRequest.fromJson(json["team_get_request"]),
        teamGetResponse: TeamResponse.fromJson(json["team_get_response"]),
        teamPostGameScoresheetRequest: TeamPostGameScoresheetRequest.fromJson(json["team_post_game_scoresheet_request"]),
        teamUpdateRequest: TeamUpdateRequest.fromJson(json["team_update_request"]),
        teamsGetResponse: TeamsResponse.fromJson(json["teams_get_response"]),
        updateUserRequest: UpdateUserRequest.fromJson(json["update_user_request"]),
        users: User.fromJson(json["users"]),
        usersRequest: UsersRequest.fromJson(json["users_request"]),
        usersResponse: UsersResponse.fromJson(json["users_response"]),
    );

    Map<String, dynamic> toJson() => {
        "add_user_request": addUserRequest.toJson(),
        "delete_user_request": deleteUserRequest.toJson(),
        "event": event.toJson(),
        "event_get_api_link_request": eventGetApiLinkRequest.toJson(),
        "event_get_api_link_response": eventGetApiLinkResponse.toJson(),
        "events_get_response": eventsGetResponse.toJson(),
        "game_get_response": gameGetResponse.toJson(),
        "game_match": gameMatch.toJson(),
        "integrity_message": integrityMessage.toJson(),
        "judging_session": judgingSession.toJson(),
        "judging_session_add_request": judgingSessionAddRequest.toJson(),
        "judging_session_delete_request": judgingSessionDeleteRequest.toJson(),
        "judging_session_get_request": judgingSessionGetRequest.toJson(),
        "judging_session_get_response": judgingSessionGetResponse.toJson(),
        "judging_session_update_request": judgingSessionUpdateRequest.toJson(),
        "judging_sessions_get_response": judgingSessionsGetResponse.toJson(),
        "login_request": loginRequest.toJson(),
        "login_response": loginResponse.toJson(),
        "match_add_request": matchAddRequest.toJson(),
        "match_delete_request": matchDeleteRequest.toJson(),
        "match_get_request": matchGetRequest.toJson(),
        "match_get_response": matchGetResponse.toJson(),
        "match_loaded_request": matchLoadedRequest.toJson(),
        "match_update_request": matchUpdateRequest.toJson(),
        "matches_get_response": matchesGetResponse.toJson(),
        "missions_get_response": missionsGetResponse.toJson(),
        "proxy_bytes_response": proxyBytesResponse.toJson(),
        "purge_request": purgeRequest.toJson(),
        "questions_get_response": questionsGetResponse.toJson(),
        "questions_validate_request": questionsValidateRequest.toJson(),
        "questions_validate_response": questionsValidateResponse.toJson(),
        "register_request": registerRequest.toJson(),
        "register_response": registerResponse.toJson(),
        "seasons_get_response": seasonsGetResponse.toJson(),
        "setup_request": setupRequest.toJson(),
        "socket_event": socketEvent.toJson(),
        "socket_match_loaded_message": socketMatchLoadedMessage.toJson(),
        "start_timer_request": startTimerRequest.toJson(),
        "team": team.toJson(),
        "team_add_request": teamAddRequest.toJson(),
        "team_delete_request": teamDeleteRequest.toJson(),
        "team_get_request": teamGetRequest.toJson(),
        "team_get_response": teamGetResponse.toJson(),
        "team_post_game_scoresheet_request": teamPostGameScoresheetRequest.toJson(),
        "team_update_request": teamUpdateRequest.toJson(),
        "teams_get_response": teamsGetResponse.toJson(),
        "update_user_request": updateUserRequest.toJson(),
        "users": users.toJson(),
        "users_request": usersRequest.toJson(),
        "users_response": usersResponse.toJson(),
    };
}

class AddUserRequest {
    AddUserRequest({
        required this.authToken,
        required this.user,
    });

    String authToken;
    User user;

    factory AddUserRequest.fromJson(Map<String, dynamic> json) => AddUserRequest(
        authToken: json["auth_token"],
        user: User.fromJson(json["user"]),
    );

    Map<String, dynamic> toJson() => {
        "auth_token": authToken,
        "user": user.toJson(),
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

class DeleteUserRequest {
    DeleteUserRequest({
        required this.authToken,
        required this.username,
    });

    String authToken;
    String username;

    factory DeleteUserRequest.fromJson(Map<String, dynamic> json) => DeleteUserRequest(
        authToken: json["auth_token"],
        username: json["username"],
    );

    Map<String, dynamic> toJson() => {
        "auth_token": authToken,
        "username": username,
    };
}

class Event {
    Event({
        required this.endGameTimerLength,
        required this.eventRounds,
        required this.name,
        required this.pods,
        required this.season,
        required this.tables,
        required this.timerLength,
    });

    int endGameTimerLength;
    int eventRounds;
    String name;
    List<String> pods;
    String season;
    List<String> tables;
    int timerLength;

    factory Event.fromJson(Map<String, dynamic> json) => Event(
        endGameTimerLength: json["end_game_timer_length"],
        eventRounds: json["event_rounds"],
        name: json["name"],
        pods: List<String>.from(json["pods"].map((x) => x)),
        season: json["season"],
        tables: List<String>.from(json["tables"].map((x) => x)),
        timerLength: json["timer_length"],
    );

    Map<String, dynamic> toJson() => {
        "end_game_timer_length": endGameTimerLength,
        "event_rounds": eventRounds,
        "name": name,
        "pods": List<dynamic>.from(pods.map((x) => x)),
        "season": season,
        "tables": List<dynamic>.from(tables.map((x) => x)),
        "timer_length": timerLength,
    };
}

class ApiLinkRequest {
    ApiLinkRequest({
        required this.authToken,
    });

    String authToken;

    factory ApiLinkRequest.fromJson(Map<String, dynamic> json) => ApiLinkRequest(
        authToken: json["auth_token"],
    );

    Map<String, dynamic> toJson() => {
        "auth_token": authToken,
    };
}

class ApiLinkResponse {
    ApiLinkResponse({
        required this.apiLink,
    });

    ApiLink apiLink;

    factory ApiLinkResponse.fromJson(Map<String, dynamic> json) => ApiLinkResponse(
        apiLink: ApiLink.fromJson(json["api_link"]),
    );

    Map<String, dynamic> toJson() => {
        "api_link": apiLink.toJson(),
    };
}

class ApiLink {
    ApiLink({
        required this.linked,
        required this.tournamentId,
        required this.tournamentToken,
    });

    bool linked;
    String tournamentId;
    String tournamentToken;

    factory ApiLink.fromJson(Map<String, dynamic> json) => ApiLink(
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

class EventResponse {
    EventResponse({
        required this.event,
    });

    Event event;

    factory EventResponse.fromJson(Map<String, dynamic> json) => EventResponse(
        event: Event.fromJson(json["event"]),
    );

    Map<String, dynamic> toJson() => {
        "event": event.toJson(),
    };
}

class GameResponse {
    GameResponse({
        required this.game,
    });

    Game game;

    factory GameResponse.fromJson(Map<String, dynamic> json) => GameResponse(
        game: Game.fromJson(json["game"]),
    );

    Map<String, dynamic> toJson() => {
        "game": game.toJson(),
    };
}

class Game {
    Game({
        required this.missions,
        required this.name,
        required this.program,
        required this.questions,
        required this.ruleBookUrl,
    });

    List<Mission> missions;
    String name;
    String program;
    List<Score> questions;
    String ruleBookUrl;

    factory Game.fromJson(Map<String, dynamic> json) => Game(
        missions: List<Mission>.from(json["missions"].map((x) => Mission.fromJson(x))),
        name: json["name"],
        program: json["program"],
        questions: List<Score>.from(json["questions"].map((x) => Score.fromJson(x))),
        ruleBookUrl: json["rule_book_url"],
    );

    Map<String, dynamic> toJson() => {
        "missions": List<dynamic>.from(missions.map((x) => x.toJson())),
        "name": name,
        "program": program,
        "questions": List<dynamic>.from(questions.map((x) => x.toJson())),
        "rule_book_url": ruleBookUrl,
    };
}

class Mission {
    Mission({
        this.image,
        required this.prefix,
        required this.title,
    });

    String? image;
    String prefix;
    String title;

    factory Mission.fromJson(Map<String, dynamic> json) => Mission(
        image: json["image"],
        prefix: json["prefix"],
        title: json["title"],
    );

    Map<String, dynamic> toJson() => {
        "image": image,
        "prefix": prefix,
        "title": title,
    };
}

class Score {
    Score({
        required this.defaultValue,
        required this.id,
        required this.label,
        required this.labelShort,
        required this.questionInput,
    });

    DefaultValue defaultValue;
    String id;
    String label;
    String labelShort;
    QuestionInput questionInput;

    factory Score.fromJson(Map<String, dynamic> json) => Score(
        defaultValue: DefaultValue.fromJson(json["default_value"]),
        id: json["id"],
        label: json["label"],
        labelShort: json["label_short"],
        questionInput: QuestionInput.fromJson(json["question_input"]),
    );

    Map<String, dynamic> toJson() => {
        "default_value": defaultValue.toJson(),
        "id": id,
        "label": label,
        "label_short": labelShort,
        "question_input": questionInput.toJson(),
    };
}

class DefaultValue {
    DefaultValue({
        this.number,
        this.text,
    });

    int? number;
    String? text;

    factory DefaultValue.fromJson(Map<String, dynamic> json) => DefaultValue(
        number: json["Number"],
        text: json["Text"],
    );

    Map<String, dynamic> toJson() => {
        "Number": number,
        "Text": text,
    };
}

class QuestionInput {
    QuestionInput({
        this.numerical,
        this.categorical,
    });

    Numerical? numerical;
    Categorical? categorical;

    factory QuestionInput.fromJson(Map<String, dynamic> json) => QuestionInput(
        numerical: json["Numerical"] == null ? null : Numerical.fromJson(json["Numerical"]),
        categorical: json["Categorical"] == null ? null : Categorical.fromJson(json["Categorical"]),
    );

    Map<String, dynamic> toJson() => {
        "Numerical": numerical?.toJson(),
        "Categorical": categorical?.toJson(),
    };
}

class Categorical {
    Categorical({
        required this.options,
    });

    List<String> options;

    factory Categorical.fromJson(Map<String, dynamic> json) => Categorical(
        options: List<String>.from(json["options"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "options": List<dynamic>.from(options.map((x) => x)),
    };
}

class Numerical {
    Numerical({
        required this.max,
        required this.min,
    });

    int max;
    int min;

    factory Numerical.fromJson(Map<String, dynamic> json) => Numerical(
        max: json["max"],
        min: json["min"],
    );

    Map<String, dynamic> toJson() => {
        "max": max,
        "min": min,
    };
}

class GameMatch {
    GameMatch({
        required this.complete,
        required this.gameMatchDeferred,
        required this.endTime,
        required this.exhibitionMatch,
        required this.matchNumber,
        required this.matchTables,
        required this.roundNumber,
        required this.startTime,
    });

    bool complete;
    bool gameMatchDeferred;
    String endTime;
    bool exhibitionMatch;
    String matchNumber;
    List<OnTable> matchTables;
    int roundNumber;
    String startTime;

    factory GameMatch.fromJson(Map<String, dynamic> json) => GameMatch(
        complete: json["complete"],
        gameMatchDeferred: json["deferred"],
        endTime: json["end_time"],
        exhibitionMatch: json["exhibition_match"],
        matchNumber: json["match_number"],
        matchTables: List<OnTable>.from(json["match_tables"].map((x) => OnTable.fromJson(x))),
        roundNumber: json["round_number"],
        startTime: json["start_time"],
    );

    Map<String, dynamic> toJson() => {
        "complete": complete,
        "deferred": gameMatchDeferred,
        "end_time": endTime,
        "exhibition_match": exhibitionMatch,
        "match_number": matchNumber,
        "match_tables": List<dynamic>.from(matchTables.map((x) => x.toJson())),
        "round_number": roundNumber,
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
        required this.judgingSessionDeferred,
        required this.endTime,
        required this.judgingPods,
        required this.sessionNumber,
        required this.startTime,
    });

    bool complete;
    bool judgingSessionDeferred;
    String endTime;
    List<JudgingPod> judgingPods;
    String sessionNumber;
    String startTime;

    factory JudgingSession.fromJson(Map<String, dynamic> json) => JudgingSession(
        complete: json["complete"],
        judgingSessionDeferred: json["deferred"],
        endTime: json["end_time"],
        judgingPods: List<JudgingPod>.from(json["judging_pods"].map((x) => JudgingPod.fromJson(x))),
        sessionNumber: json["session_number"],
        startTime: json["start_time"],
    );

    Map<String, dynamic> toJson() => {
        "complete": complete,
        "deferred": judgingSessionDeferred,
        "end_time": endTime,
        "judging_pods": List<dynamic>.from(judgingPods.map((x) => x.toJson())),
        "session_number": sessionNumber,
        "start_time": startTime,
    };
}

class JudgingPod {
    JudgingPod({
        required this.pod,
        required this.scoreSubmitted,
        required this.teamNumber,
    });

    String pod;
    bool scoreSubmitted;
    String teamNumber;

    factory JudgingPod.fromJson(Map<String, dynamic> json) => JudgingPod(
        pod: json["pod"],
        scoreSubmitted: json["score_submitted"],
        teamNumber: json["team_number"],
    );

    Map<String, dynamic> toJson() => {
        "pod": pod,
        "score_submitted": scoreSubmitted,
        "team_number": teamNumber,
    };
}

class JudgingSessionAddRequest {
    JudgingSessionAddRequest({
        required this.authToken,
        required this.judgingSession,
    });

    String authToken;
    JudgingSession judgingSession;

    factory JudgingSessionAddRequest.fromJson(Map<String, dynamic> json) => JudgingSessionAddRequest(
        authToken: json["auth_token"],
        judgingSession: JudgingSession.fromJson(json["judging_session"]),
    );

    Map<String, dynamic> toJson() => {
        "auth_token": authToken,
        "judging_session": judgingSession.toJson(),
    };
}

class JudgingSessionDeleteRequest {
    JudgingSessionDeleteRequest({
        required this.authToken,
        required this.sessionNumber,
    });

    String authToken;
    String sessionNumber;

    factory JudgingSessionDeleteRequest.fromJson(Map<String, dynamic> json) => JudgingSessionDeleteRequest(
        authToken: json["auth_token"],
        sessionNumber: json["session_number"],
    );

    Map<String, dynamic> toJson() => {
        "auth_token": authToken,
        "session_number": sessionNumber,
    };
}

class JudgingSessionRequest {
    JudgingSessionRequest({
        required this.sessionNumber,
    });

    String sessionNumber;

    factory JudgingSessionRequest.fromJson(Map<String, dynamic> json) => JudgingSessionRequest(
        sessionNumber: json["session_number"],
    );

    Map<String, dynamic> toJson() => {
        "session_number": sessionNumber,
    };
}

class JudgingSessionResponse {
    JudgingSessionResponse({
        required this.judgingSession,
    });

    JudgingSession judgingSession;

    factory JudgingSessionResponse.fromJson(Map<String, dynamic> json) => JudgingSessionResponse(
        judgingSession: JudgingSession.fromJson(json["judging_session"]),
    );

    Map<String, dynamic> toJson() => {
        "judging_session": judgingSession.toJson(),
    };
}

class JudgingSessionUpdateRequest {
    JudgingSessionUpdateRequest({
        required this.authToken,
        required this.judgingSession,
        required this.sessionNumber,
    });

    String authToken;
    JudgingSession judgingSession;
    String sessionNumber;

    factory JudgingSessionUpdateRequest.fromJson(Map<String, dynamic> json) => JudgingSessionUpdateRequest(
        authToken: json["auth_token"],
        judgingSession: JudgingSession.fromJson(json["judging_session"]),
        sessionNumber: json["session_number"],
    );

    Map<String, dynamic> toJson() => {
        "auth_token": authToken,
        "judging_session": judgingSession.toJson(),
        "session_number": sessionNumber,
    };
}

class JudgingSessionsResponse {
    JudgingSessionsResponse({
        required this.judgingSessions,
    });

    List<JudgingSession> judgingSessions;

    factory JudgingSessionsResponse.fromJson(Map<String, dynamic> json) => JudgingSessionsResponse(
        judgingSessions: List<JudgingSession>.from(json["judging_sessions"].map((x) => JudgingSession.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "judging_sessions": List<dynamic>.from(judgingSessions.map((x) => x.toJson())),
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

class MatchAddRequest {
    MatchAddRequest({
        required this.authToken,
        required this.matchData,
    });

    String authToken;
    GameMatch matchData;

    factory MatchAddRequest.fromJson(Map<String, dynamic> json) => MatchAddRequest(
        authToken: json["auth_token"],
        matchData: GameMatch.fromJson(json["match_data"]),
    );

    Map<String, dynamic> toJson() => {
        "auth_token": authToken,
        "match_data": matchData.toJson(),
    };
}

class MatchDeleteRequest {
    MatchDeleteRequest({
        required this.authToken,
        required this.matchNumber,
    });

    String authToken;
    String matchNumber;

    factory MatchDeleteRequest.fromJson(Map<String, dynamic> json) => MatchDeleteRequest(
        authToken: json["auth_token"],
        matchNumber: json["match_number"],
    );

    Map<String, dynamic> toJson() => {
        "auth_token": authToken,
        "match_number": matchNumber,
    };
}

class MatchRequest {
    MatchRequest({
        required this.matchNumber,
    });

    String matchNumber;

    factory MatchRequest.fromJson(Map<String, dynamic> json) => MatchRequest(
        matchNumber: json["match_number"],
    );

    Map<String, dynamic> toJson() => {
        "match_number": matchNumber,
    };
}

class MatchResponse {
    MatchResponse({
        required this.gameMatch,
    });

    GameMatch gameMatch;

    factory MatchResponse.fromJson(Map<String, dynamic> json) => MatchResponse(
        gameMatch: GameMatch.fromJson(json["game_match"]),
    );

    Map<String, dynamic> toJson() => {
        "game_match": gameMatch.toJson(),
    };
}

class MatchLoadRequest {
    MatchLoadRequest({
        required this.authToken,
        required this.matchNumbers,
    });

    String authToken;
    List<String> matchNumbers;

    factory MatchLoadRequest.fromJson(Map<String, dynamic> json) => MatchLoadRequest(
        authToken: json["auth_token"],
        matchNumbers: List<String>.from(json["match_numbers"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "auth_token": authToken,
        "match_numbers": List<dynamic>.from(matchNumbers.map((x) => x)),
    };
}

class MatchUpdateRequest {
    MatchUpdateRequest({
        required this.authToken,
        required this.matchData,
        required this.matchNumber,
    });

    String authToken;
    GameMatch matchData;
    String matchNumber;

    factory MatchUpdateRequest.fromJson(Map<String, dynamic> json) => MatchUpdateRequest(
        authToken: json["auth_token"],
        matchData: GameMatch.fromJson(json["match_data"]),
        matchNumber: json["match_number"],
    );

    Map<String, dynamic> toJson() => {
        "auth_token": authToken,
        "match_data": matchData.toJson(),
        "match_number": matchNumber,
    };
}

class MatchesResponse {
    MatchesResponse({
        required this.matches,
    });

    List<GameMatch> matches;

    factory MatchesResponse.fromJson(Map<String, dynamic> json) => MatchesResponse(
        matches: List<GameMatch>.from(json["matches"].map((x) => GameMatch.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "matches": List<dynamic>.from(matches.map((x) => x.toJson())),
    };
}

class MissionsResponse {
    MissionsResponse({
        required this.missions,
    });

    List<Mission> missions;

    factory MissionsResponse.fromJson(Map<String, dynamic> json) => MissionsResponse(
        missions: List<Mission>.from(json["missions"].map((x) => Mission.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "missions": List<dynamic>.from(missions.map((x) => x.toJson())),
    };
}

class ProxyBytesResponse {
    ProxyBytesResponse({
        required this.bytes,
    });

    List<int> bytes;

    factory ProxyBytesResponse.fromJson(Map<String, dynamic> json) => ProxyBytesResponse(
        bytes: List<int>.from(json["bytes"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "bytes": List<dynamic>.from(bytes.map((x) => x)),
    };
}

class PurgeRequest {
    PurgeRequest({
        required this.authToken,
    });

    String authToken;

    factory PurgeRequest.fromJson(Map<String, dynamic> json) => PurgeRequest(
        authToken: json["auth_token"],
    );

    Map<String, dynamic> toJson() => {
        "auth_token": authToken,
    };
}

class QuestionsResponse {
    QuestionsResponse({
        required this.questions,
    });

    List<Score> questions;

    factory QuestionsResponse.fromJson(Map<String, dynamic> json) => QuestionsResponse(
        questions: List<Score>.from(json["questions"].map((x) => Score.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "questions": List<dynamic>.from(questions.map((x) => x.toJson())),
    };
}

class QuestionsValidateRequest {
    QuestionsValidateRequest({
        required this.answers,
        required this.authToken,
    });

    List<ScoreAnswer> answers;
    String authToken;

    factory QuestionsValidateRequest.fromJson(Map<String, dynamic> json) => QuestionsValidateRequest(
        answers: List<ScoreAnswer>.from(json["answers"].map((x) => ScoreAnswer.fromJson(x))),
        authToken: json["auth_token"],
    );

    Map<String, dynamic> toJson() => {
        "answers": List<dynamic>.from(answers.map((x) => x.toJson())),
        "auth_token": authToken,
    };
}

class ScoreAnswer {
    ScoreAnswer({
        required this.answer,
        required this.id,
    });

    String answer;
    String id;

    factory ScoreAnswer.fromJson(Map<String, dynamic> json) => ScoreAnswer(
        answer: json["answer"],
        id: json["id"],
    );

    Map<String, dynamic> toJson() => {
        "answer": answer,
        "id": id,
    };
}

class QuestionsValidateResponse {
    QuestionsValidateResponse({
        required this.errors,
        required this.score,
    });

    List<ScoreError> errors;
    int score;

    factory QuestionsValidateResponse.fromJson(Map<String, dynamic> json) => QuestionsValidateResponse(
        errors: List<ScoreError>.from(json["errors"].map((x) => ScoreError.fromJson(x))),
        score: json["score"],
    );

    Map<String, dynamic> toJson() => {
        "errors": List<dynamic>.from(errors.map((x) => x.toJson())),
        "score": score,
    };
}

class ScoreError {
    ScoreError({
        required this.id,
        required this.message,
    });

    String id;
    String message;

    factory ScoreError.fromJson(Map<String, dynamic> json) => ScoreError(
        id: json["id"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "message": message,
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

class SeasonsResponse {
    SeasonsResponse({
        required this.seasons,
    });

    List<String> seasons;

    factory SeasonsResponse.fromJson(Map<String, dynamic> json) => SeasonsResponse(
        seasons: List<String>.from(json["seasons"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "seasons": List<dynamic>.from(seasons.map((x) => x)),
    };
}

class SetupRequest {
    SetupRequest({
        required this.adminPassword,
        required this.authToken,
        required this.event,
        required this.judgingSessions,
        required this.matches,
        required this.teams,
        required this.users,
    });

    String adminPassword;
    String authToken;
    Event event;
    List<JudgingSession> judgingSessions;
    List<GameMatch> matches;
    List<Team> teams;
    List<User> users;

    factory SetupRequest.fromJson(Map<String, dynamic> json) => SetupRequest(
        adminPassword: json["admin_password"],
        authToken: json["auth_token"],
        event: Event.fromJson(json["event"]),
        judgingSessions: List<JudgingSession>.from(json["judging_sessions"].map((x) => JudgingSession.fromJson(x))),
        matches: List<GameMatch>.from(json["matches"].map((x) => GameMatch.fromJson(x))),
        teams: List<Team>.from(json["teams"].map((x) => Team.fromJson(x))),
        users: List<User>.from(json["users"].map((x) => User.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "admin_password": adminPassword,
        "auth_token": authToken,
        "event": event.toJson(),
        "judging_sessions": List<dynamic>.from(judgingSessions.map((x) => x.toJson())),
        "matches": List<dynamic>.from(matches.map((x) => x.toJson())),
        "teams": List<dynamic>.from(teams.map((x) => x.toJson())),
        "users": List<dynamic>.from(users.map((x) => x.toJson())),
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

    List<TeamJudgingScore> coreValuesScores;
    List<TeamGameScore> gameScores;
    List<TeamJudgingScore> innovationProjectScores;
    int ranking;
    List<TeamJudgingScore> robotDesignScores;
    String teamAffiliation;
    String teamId;
    String teamName;
    String teamNumber;

    factory Team.fromJson(Map<String, dynamic> json) => Team(
        coreValuesScores: List<TeamJudgingScore>.from(json["core_values_scores"].map((x) => TeamJudgingScore.fromJson(x))),
        gameScores: List<TeamGameScore>.from(json["game_scores"].map((x) => TeamGameScore.fromJson(x))),
        innovationProjectScores: List<TeamJudgingScore>.from(json["innovation_project_scores"].map((x) => TeamJudgingScore.fromJson(x))),
        ranking: json["ranking"],
        robotDesignScores: List<TeamJudgingScore>.from(json["robot_design_scores"].map((x) => TeamJudgingScore.fromJson(x))),
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

class TeamJudgingScore {
    TeamJudgingScore({
        required this.cloudPublished,
        required this.judge,
        required this.noShow,
        required this.score,
        required this.scoresheet,
        required this.timeStamp,
    });

    bool cloudPublished;
    String judge;
    bool noShow;
    int score;
    JudgingScoresheet scoresheet;
    int timeStamp;

    factory TeamJudgingScore.fromJson(Map<String, dynamic> json) => TeamJudgingScore(
        cloudPublished: json["cloud_published"],
        judge: json["judge"],
        noShow: json["no_show"],
        score: json["score"],
        scoresheet: JudgingScoresheet.fromJson(json["scoresheet"]),
        timeStamp: json["time_stamp"],
    );

    Map<String, dynamic> toJson() => {
        "cloud_published": cloudPublished,
        "judge": judge,
        "no_show": noShow,
        "score": score,
        "scoresheet": scoresheet.toJson(),
        "time_stamp": timeStamp,
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

    List<ScoreAnswer> answers;
    String feedbackCrit;
    String feedbackPros;
    String teamId;
    String tournamentId;

    factory JudgingScoresheet.fromJson(Map<String, dynamic> json) => JudgingScoresheet(
        answers: List<ScoreAnswer>.from(json["answers"].map((x) => ScoreAnswer.fromJson(x))),
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

class TeamGameScore {
    TeamGameScore({
        required this.cloudPublished,
        required this.gp,
        required this.noShow,
        required this.referee,
        required this.score,
        required this.scoresheet,
        required this.timeStamp,
    });

    bool cloudPublished;
    String gp;
    bool noShow;
    String referee;
    int score;
    GameScoresheet scoresheet;
    int timeStamp;

    factory TeamGameScore.fromJson(Map<String, dynamic> json) => TeamGameScore(
        cloudPublished: json["cloud_published"],
        gp: json["gp"],
        noShow: json["no_show"],
        referee: json["referee"],
        score: json["score"],
        scoresheet: GameScoresheet.fromJson(json["scoresheet"]),
        timeStamp: json["time_stamp"],
    );

    Map<String, dynamic> toJson() => {
        "cloud_published": cloudPublished,
        "gp": gp,
        "no_show": noShow,
        "referee": referee,
        "score": score,
        "scoresheet": scoresheet.toJson(),
        "time_stamp": timeStamp,
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

    List<ScoreAnswer> answers;
    String privateComment;
    String publicComment;
    int round;
    String teamId;
    String tournamentId;

    factory GameScoresheet.fromJson(Map<String, dynamic> json) => GameScoresheet(
        answers: List<ScoreAnswer>.from(json["answers"].map((x) => ScoreAnswer.fromJson(x))),
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

class SocketMessage {
    SocketMessage({
        this.fromId,
        required this.message,
        required this.subTopic,
        required this.topic,
    });

    String? fromId;
    String message;
    String subTopic;
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

class SocketMatchLoadedMessage {
    SocketMatchLoadedMessage({
        required this.matchNumbers,
    });

    List<String> matchNumbers;

    factory SocketMatchLoadedMessage.fromJson(Map<String, dynamic> json) => SocketMatchLoadedMessage(
        matchNumbers: List<String>.from(json["match_numbers"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "match_numbers": List<dynamic>.from(matchNumbers.map((x) => x)),
    };
}

class TimerRequest {
    TimerRequest({
        required this.authToken,
    });

    String authToken;

    factory TimerRequest.fromJson(Map<String, dynamic> json) => TimerRequest(
        authToken: json["auth_token"],
    );

    Map<String, dynamic> toJson() => {
        "auth_token": authToken,
    };
}

class TeamAddRequest {
    TeamAddRequest({
        required this.authToken,
        required this.teamAffiliation,
        required this.teamName,
        required this.teamNumber,
    });

    String authToken;
    String teamAffiliation;
    String teamName;
    String teamNumber;

    factory TeamAddRequest.fromJson(Map<String, dynamic> json) => TeamAddRequest(
        authToken: json["auth_token"],
        teamAffiliation: json["team_affiliation"],
        teamName: json["team_name"],
        teamNumber: json["team_number"],
    );

    Map<String, dynamic> toJson() => {
        "auth_token": authToken,
        "team_affiliation": teamAffiliation,
        "team_name": teamName,
        "team_number": teamNumber,
    };
}

class TeamDeleteRequest {
    TeamDeleteRequest({
        required this.authToken,
        required this.teamNumber,
    });

    String authToken;
    String teamNumber;

    factory TeamDeleteRequest.fromJson(Map<String, dynamic> json) => TeamDeleteRequest(
        authToken: json["auth_token"],
        teamNumber: json["team_number"],
    );

    Map<String, dynamic> toJson() => {
        "auth_token": authToken,
        "team_number": teamNumber,
    };
}

class TeamRequest {
    TeamRequest({
        required this.teamNumber,
    });

    String teamNumber;

    factory TeamRequest.fromJson(Map<String, dynamic> json) => TeamRequest(
        teamNumber: json["team_number"],
    );

    Map<String, dynamic> toJson() => {
        "team_number": teamNumber,
    };
}

class TeamResponse {
    TeamResponse({
        required this.team,
    });

    Team team;

    factory TeamResponse.fromJson(Map<String, dynamic> json) => TeamResponse(
        team: Team.fromJson(json["team"]),
    );

    Map<String, dynamic> toJson() => {
        "team": team.toJson(),
    };
}

class TeamPostGameScoresheetRequest {
    TeamPostGameScoresheetRequest({
        required this.authToken,
        this.matchNumber,
        required this.scoresheet,
        this.table,
        required this.teamNumber,
        required this.updateMatch,
    });

    String authToken;
    String? matchNumber;
    TeamGameScore scoresheet;
    String? table;
    String teamNumber;
    bool updateMatch;

    factory TeamPostGameScoresheetRequest.fromJson(Map<String, dynamic> json) => TeamPostGameScoresheetRequest(
        authToken: json["auth_token"],
        matchNumber: json["match_number"],
        scoresheet: TeamGameScore.fromJson(json["scoresheet"]),
        table: json["table"],
        teamNumber: json["team_number"],
        updateMatch: json["update_match"],
    );

    Map<String, dynamic> toJson() => {
        "auth_token": authToken,
        "match_number": matchNumber,
        "scoresheet": scoresheet.toJson(),
        "table": table,
        "team_number": teamNumber,
        "update_match": updateMatch,
    };
}

class TeamUpdateRequest {
    TeamUpdateRequest({
        required this.authToken,
        required this.teamData,
        required this.teamNumber,
    });

    String authToken;
    Team teamData;
    String teamNumber;

    factory TeamUpdateRequest.fromJson(Map<String, dynamic> json) => TeamUpdateRequest(
        authToken: json["auth_token"],
        teamData: Team.fromJson(json["team_data"]),
        teamNumber: json["team_number"],
    );

    Map<String, dynamic> toJson() => {
        "auth_token": authToken,
        "team_data": teamData.toJson(),
        "team_number": teamNumber,
    };
}

class TeamsResponse {
    TeamsResponse({
        required this.teams,
    });

    List<Team> teams;

    factory TeamsResponse.fromJson(Map<String, dynamic> json) => TeamsResponse(
        teams: List<Team>.from(json["teams"].map((x) => Team.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "teams": List<dynamic>.from(teams.map((x) => x.toJson())),
    };
}

class UpdateUserRequest {
    UpdateUserRequest({
        required this.authToken,
        required this.updatedUser,
        required this.username,
    });

    String authToken;
    User updatedUser;
    String username;

    factory UpdateUserRequest.fromJson(Map<String, dynamic> json) => UpdateUserRequest(
        authToken: json["auth_token"],
        updatedUser: User.fromJson(json["updated_user"]),
        username: json["username"],
    );

    Map<String, dynamic> toJson() => {
        "auth_token": authToken,
        "updated_user": updatedUser.toJson(),
        "username": username,
    };
}

class UsersRequest {
    UsersRequest({
        required this.authToken,
    });

    String authToken;

    factory UsersRequest.fromJson(Map<String, dynamic> json) => UsersRequest(
        authToken: json["auth_token"],
    );

    Map<String, dynamic> toJson() => {
        "auth_token": authToken,
    };
}

class UsersResponse {
    UsersResponse({
        required this.users,
    });

    List<User> users;

    factory UsersResponse.fromJson(Map<String, dynamic> json) => UsersResponse(
        users: List<User>.from(json["users"].map((x) => User.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "users": List<dynamic>.from(users.map((x) => x.toJson())),
    };
}
