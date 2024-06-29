import 'dart:io';

import 'package:tms/generated/infra/network_schemas/login_requests.dart';
import 'package:tms/utils/logger.dart';
import 'package:tms/network/network.dart';

class AuthService {
  Future<(int, LoginResponse?)> login(String username, String password) async {
    try {
      var request = LoginRequest(password: password, username: username).toJsonString();
      var response = await Network().networkPost("/login", request);

      if (response.$1) {
        LoginResponse loginResponse = LoginResponse.fromJsonString(json: response.$3);
        TmsLogger().i("Login successful: ${loginResponse.roles}");
        return (HttpStatus.ok, loginResponse);
      } else {
        return (response.$2, null);
      }
    } catch (e) {
      TmsLogger().e("Error: $e");
      return (HttpStatus.badRequest, null);
    }
  }

  Future<int> logout() async {
    try {
      var response = await Network().networkPost("/logout", {});

      if (response.$1) {
        TmsLogger().i("Logout successful");
      }
      return response.$2;
    } catch (e) {
      TmsLogger().e("Error: $e");
      return HttpStatus.badRequest;
    }
  }
}
