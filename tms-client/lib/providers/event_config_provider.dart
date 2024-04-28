import 'package:flutter/material.dart';
import 'package:tms/services/event_config_service.dart';

class EventConfigProvider extends ChangeNotifier {
  EventConfigService _service = EventConfigService();
  String _eventName = '';

  String get eventName => _eventName;

  Future<int> setEventName(String name) async {
    _eventName = name;
    int status = await _service.setEventName(name);
    notifyListeners();
    return status;
  }
}
