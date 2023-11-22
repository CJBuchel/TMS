import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tms/network/network.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tuple/tuple.dart';

mixin AutoUnsubScribeMixin<T extends StatefulWidget> on State<T> {
  final List<Tuple2<String, Function(SocketMessage)>> _subscriptions = [];

  void autoSubscribe(String channel, Function(SocketMessage) callback) {
    Network().subscribe(channel, callback);
    _subscriptions.add(Tuple2(channel, callback));
  }

  void autoUnsubscribe() async {
    for (var sub in _subscriptions) {
      Future(() {
        Network().unsubscribe(
          sub.item1,
          sub.item2,
        );
      }).catchError((e) {
        Logger().e("Error unsubscribing from ${sub.item1}: $e");
      });
    }
  }

  @override
  void dispose() {
    autoUnsubscribe();
    super.dispose();
  }
}
