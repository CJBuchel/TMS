// To parse this JSON data, do
//
//     final networkSchema = networkSchemaFromJson(jsonString);

import 'dart:convert';

NetworkSchema networkSchemaFromJson(String str) => NetworkSchema.fromJson(json.decode(str));

String networkSchemaToJson(NetworkSchema data) => json.encode(data.toJson());

class NetworkSchema {
    LoginRequest loginRequest;
    LoginResponse loginResponse;
    RegisterRequest registerRequest;
    RegisterResponse registerResponse;
    TmsServerSocketMessage tmsServerSocketMessage;
    TournamentConfigSetBackupIntervalRequest tournamentConfigSetBackupIntervalRequest;
    TournamentConfigSetEndgameTimerLengthRequest tournamentConfigSetEndgameTimerLengthRequest;
    TournamentConfigSetNameRequest tournamentConfigSetNameRequest;
    TournamentConfigSetRetainBackupsRequest tournamentConfigSetRetainBackupsRequest;
    TournamentConfigSetSeasonRequest tournamentConfigSetSeasonRequest;
    TournamentConfigSetTimerLengthRequest tournamentConfigSetTimerLengthRequest;

    NetworkSchema({
        required this.loginRequest,
        required this.loginResponse,
        required this.registerRequest,
        required this.registerResponse,
        required this.tmsServerSocketMessage,
        required this.tournamentConfigSetBackupIntervalRequest,
        required this.tournamentConfigSetEndgameTimerLengthRequest,
        required this.tournamentConfigSetNameRequest,
        required this.tournamentConfigSetRetainBackupsRequest,
        required this.tournamentConfigSetSeasonRequest,
        required this.tournamentConfigSetTimerLengthRequest,
    });

    factory NetworkSchema.fromJson(Map<String, dynamic> json) => NetworkSchema(
        loginRequest: LoginRequest.fromJson(json["_login_request"]),
        loginResponse: LoginResponse.fromJson(json["_login_response"]),
        registerRequest: RegisterRequest.fromJson(json["_register_request"]),
        registerResponse: RegisterResponse.fromJson(json["_register_response"]),
        tmsServerSocketMessage: TmsServerSocketMessage.fromJson(json["_tms_server_socket_message"]),
        tournamentConfigSetBackupIntervalRequest: TournamentConfigSetBackupIntervalRequest.fromJson(json["_tournament_config_set_backup_interval_request"]),
        tournamentConfigSetEndgameTimerLengthRequest: TournamentConfigSetEndgameTimerLengthRequest.fromJson(json["_tournament_config_set_endgame_timer_length_request"]),
        tournamentConfigSetNameRequest: TournamentConfigSetNameRequest.fromJson(json["_tournament_config_set_name_request"]),
        tournamentConfigSetRetainBackupsRequest: TournamentConfigSetRetainBackupsRequest.fromJson(json["_tournament_config_set_retain_backups_request"]),
        tournamentConfigSetSeasonRequest: TournamentConfigSetSeasonRequest.fromJson(json["_tournament_config_set_season_request"]),
        tournamentConfigSetTimerLengthRequest: TournamentConfigSetTimerLengthRequest.fromJson(json["_tournament_config_set_timer_length_request"]),
    );

    Map<String, dynamic> toJson() => {
        "_login_request": loginRequest.toJson(),
        "_login_response": loginResponse.toJson(),
        "_register_request": registerRequest.toJson(),
        "_register_response": registerResponse.toJson(),
        "_tms_server_socket_message": tmsServerSocketMessage.toJson(),
        "_tournament_config_set_backup_interval_request": tournamentConfigSetBackupIntervalRequest.toJson(),
        "_tournament_config_set_endgame_timer_length_request": tournamentConfigSetEndgameTimerLengthRequest.toJson(),
        "_tournament_config_set_name_request": tournamentConfigSetNameRequest.toJson(),
        "_tournament_config_set_retain_backups_request": tournamentConfigSetRetainBackupsRequest.toJson(),
        "_tournament_config_set_season_request": tournamentConfigSetSeasonRequest.toJson(),
        "_tournament_config_set_timer_length_request": tournamentConfigSetTimerLengthRequest.toJson(),
    };
}

class LoginRequest {
    String password;
    String username;

    LoginRequest({
        required this.password,
        required this.username,
    });

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
    List<EchoTreeRole> roles;

    LoginResponse({
        required this.roles,
    });

    factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        roles: List<EchoTreeRole>.from(json["roles"].map((x) => EchoTreeRole.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "roles": List<dynamic>.from(roles.map((x) => x.toJson())),
    };
}


///Role used for authentication to branches of the database
class EchoTreeRole {
    String password;
    List<String> readEchoTrees;
    List<String> readWriteEchoTrees;
    String roleId;

    EchoTreeRole({
        required this.password,
        required this.readEchoTrees,
        required this.readWriteEchoTrees,
        required this.roleId,
    });

    factory EchoTreeRole.fromJson(Map<String, dynamic> json) => EchoTreeRole(
        password: json["password"],
        readEchoTrees: List<String>.from(json["read_echo_trees"].map((x) => x)),
        readWriteEchoTrees: List<String>.from(json["read_write_echo_trees"].map((x) => x)),
        roleId: json["role_id"],
    );

    Map<String, dynamic> toJson() => {
        "password": password,
        "read_echo_trees": List<dynamic>.from(readEchoTrees.map((x) => x)),
        "read_write_echo_trees": List<dynamic>.from(readWriteEchoTrees.map((x) => x)),
        "role_id": roleId,
    };
}

class RegisterRequest {
    String? password;
    String? username;

    RegisterRequest({
        this.password,
        this.username,
    });

    factory RegisterRequest.fromJson(Map<String, dynamic> json) => RegisterRequest(
        password: json["password"],
        username: json["username"],
    );

    Map<String, dynamic> toJson() => {
        "password": password,
        "username": username,
    };
}

class RegisterResponse {
    String authToken;
    List<EchoTreeRole> roles;
    String serverIp;
    String url;
    String uuid;

    RegisterResponse({
        required this.authToken,
        required this.roles,
        required this.serverIp,
        required this.url,
        required this.uuid,
    });

    factory RegisterResponse.fromJson(Map<String, dynamic> json) => RegisterResponse(
        authToken: json["auth_token"],
        roles: List<EchoTreeRole>.from(json["roles"].map((x) => EchoTreeRole.fromJson(x))),
        serverIp: json["server_ip"],
        url: json["url"],
        uuid: json["uuid"],
    );

    Map<String, dynamic> toJson() => {
        "auth_token": authToken,
        "roles": List<dynamic>.from(roles.map((x) => x.toJson())),
        "server_ip": serverIp,
        "url": url,
        "uuid": uuid,
    };
}

class TmsServerSocketMessage {
    String authToken;
    String? message;
    TmsServerSocketEvent messageEvent;

    TmsServerSocketMessage({
        required this.authToken,
        this.message,
        required this.messageEvent,
    });

    factory TmsServerSocketMessage.fromJson(Map<String, dynamic> json) => TmsServerSocketMessage(
        authToken: json["auth_token"],
        message: json["message"],
        messageEvent: tmsServerSocketEventValues.map[json["message_event"]]!,
    );

    Map<String, dynamic> toJson() => {
        "auth_token": authToken,
        "message": message,
        "message_event": tmsServerSocketEventValues.reverse[messageEvent],
    };
}

enum TmsServerSocketEvent {
    PURGE_EVENT
}

final tmsServerSocketEventValues = EnumValues({
    "PurgeEvent": TmsServerSocketEvent.PURGE_EVENT
});

class TournamentConfigSetBackupIntervalRequest {
    int interval;

    TournamentConfigSetBackupIntervalRequest({
        required this.interval,
    });

    factory TournamentConfigSetBackupIntervalRequest.fromJson(Map<String, dynamic> json) => TournamentConfigSetBackupIntervalRequest(
        interval: json["interval"],
    );

    Map<String, dynamic> toJson() => {
        "interval": interval,
    };
}

class TournamentConfigSetEndgameTimerLengthRequest {
    int timerLength;

    TournamentConfigSetEndgameTimerLengthRequest({
        required this.timerLength,
    });

    factory TournamentConfigSetEndgameTimerLengthRequest.fromJson(Map<String, dynamic> json) => TournamentConfigSetEndgameTimerLengthRequest(
        timerLength: json["timer_length"],
    );

    Map<String, dynamic> toJson() => {
        "timer_length": timerLength,
    };
}

class TournamentConfigSetNameRequest {
    String name;

    TournamentConfigSetNameRequest({
        required this.name,
    });

    factory TournamentConfigSetNameRequest.fromJson(Map<String, dynamic> json) => TournamentConfigSetNameRequest(
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "name": name,
    };
}

class TournamentConfigSetRetainBackupsRequest {
    int retainBackups;

    TournamentConfigSetRetainBackupsRequest({
        required this.retainBackups,
    });

    factory TournamentConfigSetRetainBackupsRequest.fromJson(Map<String, dynamic> json) => TournamentConfigSetRetainBackupsRequest(
        retainBackups: json["retain_backups"],
    );

    Map<String, dynamic> toJson() => {
        "retain_backups": retainBackups,
    };
}

class TournamentConfigSetSeasonRequest {
    String season;

    TournamentConfigSetSeasonRequest({
        required this.season,
    });

    factory TournamentConfigSetSeasonRequest.fromJson(Map<String, dynamic> json) => TournamentConfigSetSeasonRequest(
        season: json["season"],
    );

    Map<String, dynamic> toJson() => {
        "season": season,
    };
}

class TournamentConfigSetTimerLengthRequest {
    int timerLength;

    TournamentConfigSetTimerLengthRequest({
        required this.timerLength,
    });

    factory TournamentConfigSetTimerLengthRequest.fromJson(Map<String, dynamic> json) => TournamentConfigSetTimerLengthRequest(
        timerLength: json["timer_length"],
    );

    Map<String, dynamic> toJson() => {
        "timer_length": timerLength,
    };
}

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
        reverseMap = map.map((k, v) => MapEntry(v, k));
        return reverseMap;
    }
}
