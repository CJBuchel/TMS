import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:echo_tree_flutter/logging/logger.dart';
import 'package:echo_tree_flutter/schemas/echo_tree_schema.dart';

class EchoResponderBroker {
  static final EchoResponderBroker _instance = EchoResponderBroker._internal();
  final _eventController = StreamController<StatusResponseEvent>.broadcast();

  Stream<StatusResponseEvent> get eventStream => _eventController.stream;

  factory EchoResponderBroker() {
    return _instance;
  }

  EchoResponderBroker._internal();

  void broker(String message) {
    try {
      StatusResponseEvent event = StatusResponseEvent.fromJson(jsonDecode(message));
      _eventController.add(event);
      switch (event.statusCode) {
        case HttpStatus.ok:
          EchoTreeLogger().t('Status OK: ${event.message}');
          break;
        case HttpStatus.badRequest:
          EchoTreeLogger().w('Status Bad Request: ${event.message}');
          break;
        case HttpStatus.unauthorized:
          EchoTreeLogger().w('Status Unauthorized: ${event.message}');
          break;
        case HttpStatus.forbidden:
          EchoTreeLogger().w('Status Forbidden: ${event.message}');
          break;
        case HttpStatus.notFound:
          EchoTreeLogger().w('Status Not Found: ${event.message}');
          break;
        case HttpStatus.internalServerError:
          EchoTreeLogger().w('Status Internal Server Error: ${event.message}');
          break;
        default:
          EchoTreeLogger().w('Status Unknown: ${event.message}');
      }
    } catch (e) {
      EchoTreeLogger().e('Error: $e');
    }
  }

  void dispose() {
    _eventController.close();
  }
}
