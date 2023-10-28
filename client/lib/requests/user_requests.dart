import 'dart:io';

import 'package:logger/logger.dart';
import 'package:tms/network/auth.dart';
import 'package:tms/network/network.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tuple/tuple.dart';

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
    return HttpStatus.badRequest;
  }
}

Future<Tuple2<int, List<User>>> getUsersRequest() async {
  try {
    var usersRequest = UsersRequest(authToken: await NetworkAuth.getToken());
    var res = await Network.serverPost("users/get", usersRequest.toJson());
    if (res.item1) {
      if (res.item3.isNotEmpty) {
        var usersResponse = UsersResponse.fromJson(res.item3);
        return Tuple2(res.item2, usersResponse.users);
      } else {
        return Tuple2(res.item2, []);
      }
    } else {
      return Tuple2(res.item2, []);
    }
  } catch (e) {
    Logger().e(e);
    return const Tuple2(HttpStatus.badRequest, []);
  }
}

Future<int> addUserRequest(User user) async {
  try {
    var addUserRequest = AddUserRequest(
      authToken: await NetworkAuth.getToken(),
      user: user,
    );
    var res = await Network.serverPost("user/add", addUserRequest.toJson());
    if (res.item1) {
      return res.item2;
    } else {
      return HttpStatus.badRequest;
    }
  } catch (e) {
    Logger().e(e);
    return HttpStatus.badRequest;
  }
}

Future<int> deleteUserRequest(String username) async {
  try {
    var deleteUserRequest = DeleteUserRequest(
      authToken: await NetworkAuth.getToken(),
      username: username,
    );
    var res = await Network.serverPost("user/delete", deleteUserRequest.toJson());
    if (res.item1) {
      return res.item2;
    } else {
      return HttpStatus.badRequest;
    }
  } catch (e) {
    Logger().e(e);
    return HttpStatus.badRequest;
  }
}

Future<int> updateUserRequest(String username, User user) async {
  try {
    var updateUserRequest = UpdateUserRequest(
      authToken: await NetworkAuth.getToken(),
      username: username,
      updatedUser: user,
    );
    var res = await Network.serverPost("user/update", updateUserRequest.toJson());
    if (res.item1) {
      return res.item2;
    } else {
      return HttpStatus.badRequest;
    }
  } catch (e) {
    Logger().e(e);
    return HttpStatus.badRequest;
  }
}
