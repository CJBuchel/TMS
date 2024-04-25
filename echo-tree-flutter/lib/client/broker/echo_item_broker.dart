import 'dart:convert';

import 'package:echo_tree_flutter/db/db.dart';
import 'package:echo_tree_flutter/logging/logger.dart';
import 'package:echo_tree_flutter/schemas/echoTreeSchema.dart';

class EchoItemBroker {
  static final EchoItemBroker _instance = EchoItemBroker._internal();

  factory EchoItemBroker() {
    return _instance;
  }

  EchoItemBroker._internal();

  Future<void> _remove(String treeName, String key) async {
    // delete the item
    await Database().getTreeMap?.getTree(treeName).remove(key);
  }

  Future<void> _insert(String treeName, String key, String data) async {
    // insert the item
    EchoTreeLogger().i("Got insertion request from server: $key, $data");
    await Database().getTreeMap?.getTree(treeName).insert(key, data);
  }

  // broker method
  Future<void> broker(String message) async {
    try {
      // convert to echo item event
      EchoItemEvent event = EchoItemEvent.fromJson(jsonDecode(message));

      if (event.data.isEmpty) {
        await _remove(event.treeName, event.key);
      } else {
        // update the item
        await _insert(event.treeName, event.key, event.data);
      }
    } catch (e) {
      EchoTreeLogger().e("Error: $e");
    }
  }
}
