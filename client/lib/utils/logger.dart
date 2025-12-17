import 'package:logger/logger.dart';

enum LogLevel { trace, debug, info, warning, error, fatal }

class TmsLogger {
  static final TmsLogger _instance = TmsLogger._internal();
  TmsLogger._internal();

  LogLevel _logLevel = LogLevel.debug;

  factory TmsLogger() {
    return _instance;
  }

  set level(LogLevel level) => _logLevel = level;

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 5,
      lineLength: 100,
      colors: true,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
  );

  void t(dynamic message) {
    if (_logLevel.index <= LogLevel.trace.index) {
      _logger.t(message);
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

  void w(dynamic message) {
    if (_logLevel.index <= LogLevel.warning.index) {
      _logger.w(message);
    }
  }

  void e(dynamic message) {
    if (_logLevel.index <= LogLevel.error.index) {
      _logger.e(message);
    }
  }

  void f(dynamic message) {
    if (_logLevel.index <= LogLevel.fatal.index) {
      _logger.f(message);
    }
  }
}

// Global logger instance
final logger = TmsLogger();
