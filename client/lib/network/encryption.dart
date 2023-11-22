import 'dart:async';

import 'package:fast_rsa/fast_rsa.dart';
import 'package:logger/logger.dart';

class Encryption {
  // encrypt using a stream queue which monitors and allows only one encryption at a time
  static Future<String> encrypt(String rawMessage, String publicKey) async {
    try {
      String enc = await RSA.encryptPKCS1v15(rawMessage, publicKey).timeout(const Duration(seconds: 5), onTimeout: () {
        Logger().e("Encryption timed out");
        throw TimeoutException("Encryption timed out");
      });
      return enc;
    } catch (e) {
      rethrow;
    }
  }

  // decrypt using a stream queue which monitors and allows only one decryption at a time
  static Future<String> decrypt(String message, String privateKey) async {
    try {
      String dec = await RSA.decryptPKCS1v15(message, privateKey).timeout(const Duration(seconds: 5), onTimeout: () {
        Logger().e("Decryption timed out");
        throw TimeoutException("Decryption timed out");
      });
      return dec;
    } catch (e) {
      rethrow;
    }
  }
}
