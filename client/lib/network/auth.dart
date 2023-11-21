import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms/constants.dart';
import 'package:tms/network/security.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:http/http.dart' as http;

// Controls the login and permissions for the application
class NetworkAuth {
  static final NetworkAuth _instance = NetworkAuth._internal();

  factory NetworkAuth() {
    return _instance;
  }

  NetworkAuth._internal();

  final ValueNotifier<bool> loginState = ValueNotifier<bool>(false);
  final Future<SharedPreferences> _localStorage = SharedPreferences.getInstance();
  String _authToken = "";

  Future<void> setLoginState(bool state) async {
    loginState.value = state;
  }

  Future<bool> getLoginState() async {
    return loginState.value;
  }

  Future<void> setToken(String token) async {
    _authToken = token;
  }

  Future<String> getToken() async {
    return _authToken;
  }

  Future<void> setUser(User user) async {
    var userJson = jsonEncode(user.toJson());
    await _localStorage.then((value) => value.setString(storeNtAuthUser, userJson));
  }

  Future<User> getUser() async {
    try {
      var userString = await _localStorage.then((value) => value.getString(storeNtAuthUser));
      if (userString != null) {
        var user = User.fromJson(jsonDecode(userString));
        return user;
      } else {
        return User(
          password: "",
          username: "",
          permissions: Permissions(admin: false, headReferee: false, judge: false, judgeAdvisor: false, referee: false),
        );
      }
    } catch (e) {
      return User(
        password: "",
        username: "",
        permissions: Permissions(admin: false, headReferee: false, judge: false, judgeAdvisor: false, referee: false),
      );
    }
  }

  // Returns true if the login was successful
  Future<bool> login(String addr, String uuid) async {
    try {
      var user = await getUser();
      var message = LoginRequest(password: user.password, username: user.username);
      var encryptedM = await NetworkSecurity().encryptMessage(message.toJson());
      final res = await http.post(
        Uri.parse("http://$addr:$requestPort/requests/login/$uuid"),
        body: encryptedM,
      );

      if (res.body.isNotEmpty && res.statusCode == HttpStatus.ok) {
        var decryptedM = await NetworkSecurity().decryptMessage(res.body);
        var loginResponse = LoginResponse.fromJson(decryptedM);
        user.permissions = loginResponse.permissions;
        setToken(loginResponse.authToken);
        setLoginState(true);
        return true;
      }
    } catch (e) {
      Logger().e(e);
    }

    // Logger().w("Login failed");

    setLoginState(false);
    return false;
  }
}
