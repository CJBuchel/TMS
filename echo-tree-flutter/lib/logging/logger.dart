import 'package:flutter/foundation.dart';

abstract class EchoTreeBaseLogger {
  void t(dynamic message) => debugPrint(message.toString());
  void d(dynamic message) => debugPrint(message.toString());
  void i(dynamic message) => debugPrint(message.toString());
  void w(dynamic message) => debugPrint(message.toString());
  void e(dynamic message) => debugPrint(message.toString());
  void f(dynamic message) => debugPrint(message.toString());
}

class EchoTreeDefaultLogger extends EchoTreeBaseLogger {}

class EchoTreeLogger {
  // singleton
  static final EchoTreeLogger _instance = EchoTreeLogger._internal();
  factory EchoTreeLogger() {
    return _instance;
  }

  EchoTreeLogger._internal();

  // default logger
  EchoTreeBaseLogger _logger = EchoTreeDefaultLogger();

  // set logger
  void useLogger(EchoTreeBaseLogger logger) {
    _logger = logger;
  }

  // loggers
  void t(dynamic message) => _logger.t(message);
  void d(dynamic message) => _logger.d(message);
  void i(dynamic message) => _logger.i(message);
  void w(dynamic message) => _logger.w(message);
  void e(dynamic message) => _logger.e(message);
  void f(dynamic message) => _logger.f(message);
}
