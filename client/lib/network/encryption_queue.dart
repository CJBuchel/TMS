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

  void addTask(Future<String> Function() task) {
    _queue.sink.add(task);
  }

  void dispose() {
    _queue.close();
  }
}

class Encryption {
  static final EncryptionQueue _queue = EncryptionQueue();

  // encrypt using a stream queue which monitors and allows only one encryption at a time
  static Future<String> encrypt(String rawMessage, String publicKey) async {
    Completer<String> completer = Completer();

    _queue.addTask(() async {
      try {
        String enc = await RSA.encryptPKCS1v15(rawMessage, publicKey).timeout(const Duration(seconds: 5));
        completer.complete(enc);
      } catch (e) {
        completer.completeError(e);
      }
      return completer.future;
    });

    return completer.future;
  }

  // decrypt using a stream queue which monitors and allows only one decryption at a time
  static Future<String> decrypt(String message, String privateKey) async {
    Completer<String> completer = Completer();

    _queue.addTask(() async {
      try {
        String dec = await RSA.decryptPKCS1v15(message, privateKey).timeout(const Duration(seconds: 5));
        completer.complete(dec);
      } catch (e) {
        completer.completeError(e);
      }
      return completer.future;
    });

    return completer.future;
  }
}
