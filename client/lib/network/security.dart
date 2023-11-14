import 'dart:convert';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:fast_rsa/fast_rsa.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms/constants.dart';
import 'package:tms/network/encryption_queue.dart';

enum SecurityState { noSecurity, encrypting, secure }

class NetworkSecurity {
  static final Future<SharedPreferences> _localStorage = SharedPreferences.getInstance();
  static ValueNotifier<SecurityState> securityState = ValueNotifier<SecurityState>(SecurityState.noSecurity);

  static Future<void> setState(SecurityState state) async {
    securityState.value = state;
    await _localStorage.then((value) => value.setString(storeSecState, EnumToString.convertToString(state)));
  }

  static Future<SecurityState> getState() async {
    try {
      var stateString = await _localStorage.then((value) => value.getString(storeSecState));
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
    await _localStorage.then((value) => value.setString(storeNtServerKey, key));
  }

  static Future<String> getServerKey() async {
    try {
      var key = await _localStorage.then((value) => value.getString(storeNtServerKey));
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
    await _localStorage.then((value) => value.setString(storeNtPublicKey, keys.publicKey));
    await _localStorage.then((value) => value.setString(storeNtPrivateKey, keys.privateKey));
  }

  static Future<KeyPair> getKeys() async {
    try {
      var pubKey = await _localStorage.then((value) => value.getString(storeNtPublicKey));
      var privKey = await _localStorage.then((value) => value.getString(storeNtPrivateKey));
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
    try {
      setState(SecurityState.encrypting);
      KeyPair keyPair;
      if (kIsWeb) {
        keyPair = await RSA.generate(rsaBitSizeWeb);
      } else {
        keyPair = await RSA.generate(rsaBitSize);
      }
      setState(SecurityState.secure);
      return keyPair;
    } catch (e) {
      return KeyPair("", "");
    }
  }

  static Future<String> encryptMessage(dynamic json, {String key = ''}) async {
    try {
      key = key.isEmpty ? await getServerKey() : key;
      setState(key.isEmpty ? SecurityState.noSecurity : await getState());
      String enc = await Encryption.encrypt(jsonEncode(json), key); // using stream queue
      return enc;
    } catch (e) {
      return "";
    }
  }

  static Future<Map<String, dynamic>> decryptMessage(String message, {String key = ''}) async {
    try {
      key = key.isEmpty ? (await getKeys()).privateKey : key;
      setState(key.isEmpty ? SecurityState.noSecurity : await getState());
      String dec = await Encryption.decrypt(message, key); // using stream queue
      return jsonDecode(dec);
    } catch (e) {
      return {};
    }
  }
}
