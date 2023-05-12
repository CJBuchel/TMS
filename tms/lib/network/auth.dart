import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms/constants.dart';
import 'package:tms/network/security.dart';
import 'package:tms/schema/tms-schema.dart';
import 'package:http/http.dart' as http;

// Controls the login and permissions for the application
class NetworkAuth {
  static ValueNotifier<bool> loginState = ValueNotifier<bool>(false);
  static final Future<SharedPreferences> _localStorage = SharedPreferences.getInstance();
  static String _authToken = "";

  static Future<void> setLoginState(bool state) async {
    loginState.value = state;
  }

  static Future<bool> getLoginState() async {
    return loginState.value;
  }

  static Future<void> setToken(String token) async {
    _authToken = token;
  }

  static Future<String> getToken() async {
    return _authToken;
  }

  static Future<void> setUser(User user) async {
    var userJson = jsonEncode(user.toJson());
    await _localStorage.then((value) => value.setString(store_nt_authUser, userJson));
  }

  static Future<User> getUser() async {
    try {
      var userString = await _localStorage.then((value) => value.getString(store_nt_authUser));
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
  static Future<bool> login(String addr, String uuid) async {
    try {
      var user = await getUser();
      var message = LoginRequest(password: user.password, username: user.username);
      var encryptedM = await NetworkSecurity.encryptMessage(message.toJson());
      final res = await http.post(
        Uri.parse("http://$addr:$requestPort/requests/login/$uuid"),
        body: encryptedM,
      );

      if (res.body.isNotEmpty && res.statusCode == HttpStatus.ok) {
        var decryptedM = await NetworkSecurity.decryptMessage(res.body);
        var loginResponse = LoginResponse.fromJson(decryptedM);
        user.permissions = loginResponse.permissions;
        setToken(loginResponse.authToken);
        setLoginState(true);
        return true;
      }
    } catch (e) {
      Logger().e(e);
    }

    Logger().w("Login failed");

    setLoginState(false);
    return false;
  }
}
