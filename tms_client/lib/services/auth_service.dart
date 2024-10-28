import 'dart:io';

import 'package:tms/generated/infra/database_schemas/user.dart';
import 'package:tms/generated/infra/network_schemas/login_requests.dart';
import 'package:tms/generated/infra/network_schemas/user_requests.dart';
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
      var response = await Network().networkPost("/logout", null);

      if (response.$1) {
        TmsLogger().i("Logout successful");
      }
      return response.$2;
    } catch (e) {
      TmsLogger().e("Error: $e");
      return HttpStatus.badRequest;
    }
  }

  Future<int> insertUser(String? userId, User user) async {
    try {
      var request = UserInsertRequest(userId: userId, user: user).toJsonString();
      var response = await Network().networkPost("/users/insert_user", request);
      if (response.$1) {
        TmsLogger().i("Inserted user ${user.username}");
        return HttpStatus.ok;
      } else {
        return response.$2;
      }
    } catch (e) {
      TmsLogger().e("Error: $e");
      return HttpStatus.badRequest;
    }
  }

  Future<int> removeUser(String userId) async {
    try {
      var request = UserRemoveRequest(userId: userId).toJsonString();
      var response = await Network().networkDelete("/users/remove_user", request);
      if (response.$1) {
        TmsLogger().i("Removed user: $userId");
        return HttpStatus.ok;
      } else {
        return response.$2;
      }
    } catch (e) {
      TmsLogger().e("Error: $e");
      return HttpStatus.badRequest;
    }
  }
}
