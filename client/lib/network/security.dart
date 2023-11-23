import 'dart:convert';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms/constants.dart';

import 'package:fast_rsa/fast_rsa.dart' as fast_rsa;
import 'package:tms/network/encryption_queue.dart';

enum SecurityState { noSecurity, encrypting, secure }

class NetworkSecurity {
  static final NetworkSecurity _instance = NetworkSecurity._internal();

  factory NetworkSecurity() {
    return _instance;
  }

  NetworkSecurity._internal();

  final Future<SharedPreferences> _localStorage = SharedPreferences.getInstance();
  final ValueNotifier<SecurityState> securityState = ValueNotifier<SecurityState>(SecurityState.noSecurity);

  Future<void> setState(SecurityState state) async {
    securityState.value = state;
    await _localStorage.then((value) => value.setString(storeSecState, EnumToString.convertToString(state)));
  }

  Future<SecurityState> getState() async {
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

  Future<void> setServerKey(String key) async {
    await _localStorage.then((value) => value.setString(storeNtServerKey, key));
  }

  Future<String> getServerKey() async {
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

  Future<void> setKeys(fast_rsa.KeyPair keys) async {
    await _localStorage.then((value) => value.setString(storeNtPublicKey, keys.publicKey));
    await _localStorage.then((value) => value.setString(storeNtPrivateKey, keys.privateKey));
  }

  Future<fast_rsa.KeyPair> getKeys() async {
    try {
      var pubKey = await _localStorage.then((value) => value.getString(storeNtPublicKey));
      var privKey = await _localStorage.then((value) => value.getString(storeNtPrivateKey));
      if (pubKey != null && privKey != null) {
        return fast_rsa.KeyPair(pubKey, privKey);
      } else {
        return fast_rsa.KeyPair("", "");
      }
    } catch (e) {
      return fast_rsa.KeyPair("", "");
    }
  }

  Future<fast_rsa.KeyPair> generateKeyPair() async {
    try {
      setState(SecurityState.encrypting);
      fast_rsa.KeyPair keyPair;
      if (kIsWeb) {
        keyPair = await fast_rsa.RSA.generate(rsaBitSizeWeb);
      } else {
        keyPair = await fast_rsa.RSA.generate(rsaBitSize);
      }
      setState(SecurityState.secure);
      return keyPair;
    } catch (e) {
      return fast_rsa.KeyPair("", "");
    }
  }

  Future<String> encryptMessage(dynamic json, {String key = ''}) async {
    try {
      key = key.isEmpty ? await getServerKey() : key;
      setState(key.isEmpty ? SecurityState.noSecurity : await getState());
      String enc = await Encryption.encrypt(jsonEncode(json), key); // using stream queue
      return enc;
    } catch (e) {
      return "";
    }
  }

  Future<Map<String, dynamic>> decryptMessage(String message, {String key = ''}) async {
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
