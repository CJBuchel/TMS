import 'package:echo_tree_flutter/logging/logger.dart';
import 'package:logger/logger.dart';

enum LogLevel { trace, debug, info, warning, error, fatal }

class TmsLogger {
  static final TmsLogger _instance = TmsLogger._internal();
  TmsLogger._internal();

  LogLevel _logLevel = LogLevel.debug;

  factory TmsLogger() {
    return _instance;
  }

  void setLogLevel(LogLevel logLevel) {
    _logLevel = logLevel;
  }

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: false,
      printTime: true,
    ),
  );

  void t(dynamic message) {
    if (_logLevel.index <= LogLevel.trace.index) {
      _logger.d(message);
    }
  }

  void d(dynamic message) {
    if (_logLevel.index <= LogLevel.debug.index) {
      _logger.d(message);
    }
  }

  void i(dynamic message) {
    if (_logLevel.index <= LogLevel.info.index) {
      _logger.i(message);
    }
  }

  void e(dynamic message) {
    if (_logLevel.index <= LogLevel.error.index) {
      _logger.e(message);
    }
  }

  void w(dynamic message) {
    if (_logLevel.index <= LogLevel.warning.index) {
      _logger.w(message);
    }
  }

  void f(dynamic message) {
    if (_logLevel.index <= LogLevel.fatal.index) {
      _logger.e(message);
    }
  }
}

class EchoTreeTmsLogBinder implements EchoTreeBaseLogger {
  static final EchoTreeTmsLogBinder _instance = EchoTreeTmsLogBinder._internal();

  EchoTreeTmsLogBinder._internal();

  factory EchoTreeTmsLogBinder() {
    return _instance;
  }

  @override
  void t(dynamic message) => TmsLogger().t(message);

  @override
  void d(dynamic message) => TmsLogger().d(message);

  @override
  void i(dynamic message) => TmsLogger().i(message);

  @override
  void w(dynamic message) => TmsLogger().w(message);

  @override
  void e(dynamic message) => TmsLogger().e(message);

  @override
  void f(dynamic message) => TmsLogger().f(message);
}
