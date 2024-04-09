import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/local_storage.dart';
import 'package:tms/logger.dart';
import 'package:tms/schemas/networkSchema.dart';
import 'package:tms/services/AuthService.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  String get authToken => TmsLocalStorage().authToken;
  String get uuid => TmsLocalStorage().uuid;

  bool get isLoggedIn => TmsLocalStorage().isLoggedIn;
  String get username => TmsLocalStorage().authUsername;
  String get password => TmsLocalStorage().authPassword;
  List<String> get roles => TmsLocalStorage().authRoles;

  final TmsLocalStorage _localStorage = TmsLocalStorage();
  late final VoidCallback _lsListener;

  AuthProvider() {
    _lsListener = () {
      TmsLogger().i("Auth Provider - Local Storage Changed");
      notifyListeners();
    };

    _localStorage.addListener(_lsListener);
  }

  Future<int> login(String username, String password) async {
    var result = await _authService.login(username, password);
    int status = result.$1;
    LoginResponse? loginResponse = result.$2;

    if (status == HttpStatus.ok) {
      TmsLocalStorage().authUsername = username;
      TmsLocalStorage().authPassword = password;
      TmsLocalStorage().authRoles = loginResponse?.roles ?? [];

      TmsLocalStorage().isLoggedIn = true;
      notifyListeners();
    } else {
      TmsLocalStorage().isLoggedIn = false;
    }

    return status;
  }
}
