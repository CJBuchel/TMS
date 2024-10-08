import 'dart:convert';

import 'package:echo_tree_flutter/db/db.dart';
import 'package:echo_tree_flutter/logging/logger.dart';
import 'package:echo_tree_flutter/schemas/echo_tree_schema.dart';

class EchoItemBroker {
  static final EchoItemBroker _instance = EchoItemBroker._internal();

  factory EchoItemBroker() {
    return _instance;
  }

  EchoItemBroker._internal();

  Future<void> _remove(String treeName, String key) async {
    // delete the item
    var t = await Database().getTreeMap.getTree(treeName);
    t.remove(key);
  }

  Future<void> _insert(String treeName, String key, String data) async {
    // insert the item
    var t = await Database().getTreeMap.getTree(treeName);
    await t.insert(key, data);
  }

  // broker method
  Future<void> broker(String message) async {
    try {
      // convert to echo item event
      EchoItemEvent event = EchoItemEvent.fromJson(jsonDecode(message));

      if (event.data != null && (event.data?.isNotEmpty ?? false)) {
        // update the item
        await _insert(event.treeName, event.key, event.data!);
      } else {
        // remove the item
        await _remove(event.treeName, event.key);
      }
    } catch (e) {
      EchoTreeLogger().e("Error: $e");
    }
  }
}
