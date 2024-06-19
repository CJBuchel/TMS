import 'package:flutter/material.dart';
import 'package:tms/network/network.dart';
import 'package:tms/network/ws.dart';
import 'package:tms/schemas/network_schema.dart';

// monitor subs to server events, unsubscribes when widget is disposed
mixin ServerEventSubscriberMixin<T extends StatefulWidget> on State<T> {
  Map<TmsServerSocketEvent, TmsEventHandler> _subscriptions = {};

  void subscribeToEvent(TmsServerSocketEvent event, TmsEventHandler handler) {
    _subscriptions[event] = handler;
    Network().subscribe(event, handler);
  }

  void autoUnsubscribe() {
    for (var event in _subscriptions.keys) {
      if (_subscriptions[event] != null) Network().unsubscribe(event, _subscriptions[event]!);
    }
  }

  @override
  void dispose() {
    autoUnsubscribe();
    super.dispose();
  }
}
