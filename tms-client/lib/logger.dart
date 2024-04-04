import 'package:logger/logger.dart';

class TmsLogger {
  static final TmsLogger _instance = TmsLogger._internal();
  TmsLogger._internal();

  factory TmsLogger() {
    return _instance;
  }

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  void t(dynamic message) {
    _logger.t(message);
  }

  void d(dynamic message) {
    _logger.d(message);
  }

  void i(dynamic message) {
    _logger.i(message);
  }

  void e(dynamic message) {
    _logger.e(message);
  }

  void w(dynamic message) {
    _logger.w(message);
  }

  void f(dynamic message) {
    _logger.f(message);
  }
}
