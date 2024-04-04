// To parse this JSON data, do
//
//     final network = networkFromJson(jsonString);

import 'dart:convert';

Network networkFromJson(String str) => Network.fromJson(json.decode(str));

String networkToJson(Network data) => json.encode(data.toJson());

class Network {
    RegisterRequest registerRequest;
    RegisterResponse registerResponse;

    Network({
        required this.registerRequest,
        required this.registerResponse,
    });

    factory Network.fromJson(Map<String, dynamic> json) => Network(
        registerRequest: RegisterRequest.fromJson(json["_register_request"]),
        registerResponse: RegisterResponse.fromJson(json["_register_response"]),
    );

    Map<String, dynamic> toJson() => {
        "_register_request": registerRequest.toJson(),
        "_register_response": registerResponse.toJson(),
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
    String url;
    String uuid;

    RegisterResponse({
        required this.authToken,
        required this.url,
        required this.uuid,
    });

    factory RegisterResponse.fromJson(Map<String, dynamic> json) => RegisterResponse(
        authToken: json["auth_token"],
        url: json["url"],
        uuid: json["uuid"],
    );

    Map<String, dynamic> toJson() => {
        "auth_token": authToken,
        "url": url,
        "uuid": uuid,
    };
}
