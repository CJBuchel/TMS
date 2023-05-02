import 'dart:convert';

import 'package:fast_rsa/fast_rsa.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tms/constants.dart';

class NetworkSecurity {
  static final Future<SharedPreferences> _localStorage = SharedPreferences.getInstance();

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
    return await RSA.generate(rsa_bit_size);
  }

  static Future<String> encryptMessage(dynamic json, {String key = ''}) async {
    key = key.isEmpty ? await getServerKey() : key;
    return RSA.encryptPKCS1v15(jsonEncode(json), key);
  }

  static Future<dynamic> decryptMessage(String message, {String key = ''}) async {
    key = key.isEmpty ? (await getKeys()).privateKey : key;
    return jsonDecode(await RSA.decryptPKCS1v15(message, key));
  }
}
