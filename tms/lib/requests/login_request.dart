import 'dart:io';

import 'package:logger/logger.dart';
import 'package:tms/network/auth.dart';
import 'package:tms/network/network.dart';
import 'package:tms/schema/tms-schema.dart';

// Returns status code
Future<int> loginRequest(String username, String password) async {
  try {
    var message = LoginRequest(username: username, password: password).toJson();
    var res = await Network.serverPost("login", message);

    if (res.item1) {
      if (res.item3.isNotEmpty) {
        var user = await NetworkAuth.getUser();
        var loginResponse = LoginResponse.fromJson(res.item3);
        user.username = username;
        user.password = password;
        user.permissions = loginResponse.permissions;
        NetworkAuth.setToken(loginResponse.authToken);
        NetworkAuth.setUser(user);
        NetworkAuth.setLoginState(true);
        return res.item2;
      } else {
        return res.item2;
      }
    } else {
      return HttpStatus.badRequest;
    }
  } catch (e) {
    Logger().e(e);
    rethrow;
  }
}
