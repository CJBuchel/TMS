import 'dart:io';

class HttpStatusToMessage {
  static final HttpStatusToMessage _instance = HttpStatusToMessage._internal();
  HttpStatusToMessage._internal();

  factory HttpStatusToMessage() {
    return _instance;
  }

  String getMessage(int code) {
    var message = "";
    switch (code) {
      case HttpStatus.ok:
        message = "OK";
      case HttpStatus.badRequest:
        message = "Bad Request";
      case HttpStatus.unauthorized:
        message = "Unauthorized";
      case HttpStatus.forbidden:
        message = "Forbidden";
      case HttpStatus.notFound:
        message = "Not Found";
      case HttpStatus.internalServerError:
        message = "Internal Server Error";
      case HttpStatus.networkAuthenticationRequired:
        message = "Network Authentication Required";
      default:
        message = "Unknown";
    }

    message = "$message ($code)";
    return message;
  }
}
