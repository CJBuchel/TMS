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

    NetworkSchema({
        required this.loginRequest,
        required this.loginResponse,
        required this.registerRequest,
        required this.registerResponse,
    });

    factory NetworkSchema.fromJson(Map<String, dynamic> json) => NetworkSchema(
        loginRequest: LoginRequest.fromJson(json["_login_request"]),
        loginResponse: LoginResponse.fromJson(json["_login_response"]),
        registerRequest: RegisterRequest.fromJson(json["_register_request"]),
        registerResponse: RegisterResponse.fromJson(json["_register_response"]),
    );

    Map<String, dynamic> toJson() => {
        "_login_request": loginRequest.toJson(),
        "_login_response": loginResponse.toJson(),
        "_register_request": registerRequest.toJson(),
        "_register_response": registerResponse.toJson(),
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
    List<String> roles;

    LoginResponse({
        required this.roles,
    });

    factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        roles: List<String>.from(json["roles"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "roles": List<dynamic>.from(roles.map((x) => x)),
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
    String serverIp;
    String url;
    String uuid;

    RegisterResponse({
        required this.authToken,
        required this.serverIp,
        required this.url,
        required this.uuid,
    });

    factory RegisterResponse.fromJson(Map<String, dynamic> json) => RegisterResponse(
        authToken: json["auth_token"],
        serverIp: json["server_ip"],
        url: json["url"],
        uuid: json["uuid"],
    );

    Map<String, dynamic> toJson() => {
        "auth_token": authToken,
        "server_ip": serverIp,
        "url": url,
        "uuid": uuid,
    };
}
