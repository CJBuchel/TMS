import 'dart:convert';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:fast_rsa/fast_rsa.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms/constants.dart';

enum SecurityState { noSecurity, encrypting, secure }

class NetworkSecurity {
  static final Future<SharedPreferences> _localStorage = SharedPreferences.getInstance();
  static ValueNotifier<SecurityState> securityState = ValueNotifier<SecurityState>(SecurityState.noSecurity);

  static Future<void> setState(SecurityState state) async {
    securityState.value = state;
    await _localStorage.then((value) => value.setString(store_sec_state, EnumToString.convertToString(state)));
  }

  static Future<SecurityState> getState() async {
    try {
      var stateString = await _localStorage.then((value) => value.getString(store_sec_state));
      var state = EnumToString.fromString(SecurityState.values, stateString!);
      if (state != null) {
        securityState.value = state;
        return state;
      } else {
        securityState.value = SecurityState.noSecurity;
        return SecurityState.noSecurity;
      }
    } catch (e) {
      securityState.value = SecurityState.noSecurity;
      return SecurityState.noSecurity;
    }
  }

  static Future<void> setServerKey(String key) async {
    await _localStorage.then((value) => value.setString(store_nt_serverKey, key));
  }

  static Future<String> getServerKey() async {
    try {
      var key = await _localStorage.then((value) => value.getString(store_nt_serverKey));
      if (key != null) {
        return key;
      } else {
        return "";
      }
    } catch (e) {
      return "";
    }
  }

  static Future<void> setKeys(KeyPair keys) async {
    await _localStorage.then((value) => value.setString(store_nt_publicKey, keys.publicKey));
    await _localStorage.then((value) => value.setString(store_nt_privateKey, keys.privateKey));
  }

  static Future<KeyPair> getKeys() async {
    try {
      var pubKey = await _localStorage.then((value) => value.getString(store_nt_publicKey));
      var privKey = await _localStorage.then((value) => value.getString(store_nt_privateKey));
      if (pubKey != null && privKey != null) {
        return KeyPair(pubKey, privKey);
      } else {
        return KeyPair("", "");
      }
    } catch (e) {
      return KeyPair("", "");
    }
  }

  static Future<KeyPair> generateKeyPair() async {
    setState(SecurityState.encrypting);
    var keyPair;
    if (kIsWeb) {
      keyPair = await RSA.generate(rsa_bit_size_web);
    } else {
      keyPair = await RSA.generate(rsa_bit_size);
    }
    setState(SecurityState.secure);
    return keyPair;
  }

  static Future<String> encryptMessage(dynamic json, {String key = ''}) async {
    key = key.isEmpty ? await getServerKey() : key;
    setState(key.isEmpty ? SecurityState.noSecurity : await getState());
    return RSA.encryptPKCS1v15(jsonEncode(json), key);
  }

  static Future<dynamic> decryptMessage(String message, {String key = ''}) async {
    key = key.isEmpty ? (await getKeys()).privateKey : key;
    setState(key.isEmpty ? SecurityState.noSecurity : await getState());
    return jsonDecode(await RSA.decryptPKCS1v15(message, key));
  }
}