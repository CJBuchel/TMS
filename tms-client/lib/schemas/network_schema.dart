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
    TournamentConfigSetNameRequest tournamentConfigSetNameRequest;

    NetworkSchema({
        required this.loginRequest,
        required this.loginResponse,
        required this.registerRequest,
        required this.registerResponse,
        required this.tournamentConfigSetNameRequest,
    });

    factory NetworkSchema.fromJson(Map<String, dynamic> json) => NetworkSchema(
        loginRequest: LoginRequest.fromJson(json["_login_request"]),
        loginResponse: LoginResponse.fromJson(json["_login_response"]),
        registerRequest: RegisterRequest.fromJson(json["_register_request"]),
        registerResponse: RegisterResponse.fromJson(json["_register_response"]),
        tournamentConfigSetNameRequest: TournamentConfigSetNameRequest.fromJson(json["_tournament_config_set_name_request"]),
    );

    Map<String, dynamic> toJson() => {
        "_login_request": loginRequest.toJson(),
        "_login_response": loginResponse.toJson(),
        "_register_request": registerRequest.toJson(),
        "_register_response": registerResponse.toJson(),
        "_tournament_config_set_name_request": tournamentConfigSetNameRequest.toJson(),
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
