import 'dart:async';

import 'package:fast_rsa/fast_rsa.dart';
import 'package:logger/logger.dart';

class EncryptionQueue {
  final _queue = StreamController<Function>();

  EncryptionQueue() {
    _queue.stream.asyncMap((f) => f()).listen(null, onError: (e, s) {
      Logger().e("EncryptionQueue error: $e");
    });
  }

  Future<String> addTask(Future<String> Function() task) {
    Completer<String> completer = Completer();
    _queue.sink.add(() async {
      try {
        var result = await task();
        completer.complete(result);
      } catch (e) {
        completer.completeError(e);
      }
    });

    return completer.future;
  }

  void dispose() {
    _queue.close();
  }
}

class Encryption {
  static final EncryptionQueue _queue = EncryptionQueue();

  static Future<String> _encryptWithTimeout(String rawMessage, String publicKey) async {
    return await RSA.encryptPKCS1v15(rawMessage, publicKey).timeout(const Duration(seconds: 3));
  }

  // encrypt using a stream queue which monitors and allows only one encryption at a time
  static Future<String> encrypt(String rawMessage, String publicKey, {int retries = 3}) async {
    int attempt = 0;
    while (attempt < retries) {
      try {
        return await _queue.addTask(() => _encryptWithTimeout(rawMessage, publicKey));
      } catch (e) {
        Logger().e("Encryption attempt $attempt failed: $e");
        attempt++;
        if (attempt >= retries) {
          rethrow;
        }
      }
    }

    throw Exception("Encryption failed after $retries attempts");
  }

  static Future<String> _decryptWithTimeout(String message, String privateKey) async {
    return await RSA.decryptPKCS1v15(message, privateKey).timeout(const Duration(seconds: 3));
  }

  // decrypt using a stream queue which monitors and allows only one decryption at a time
  static Future<String> decrypt(String message, String privateKey, {int retries = 3}) async {
    int attempt = 0;
    while (attempt < retries) {
      try {
        return await _queue.addTask(() => _decryptWithTimeout(message, privateKey));
      } catch (e) {
        Logger().e("Decryption attempt $attempt failed: $e");
        attempt++;
        if (attempt >= retries) {
          rethrow;
        }
      }
    }

    throw Exception("Decryption failed after 3 attempts");
  }
}
