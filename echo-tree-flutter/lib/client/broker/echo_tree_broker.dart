import 'dart:convert';

import 'package:echo_tree_flutter/db/db.dart';
import 'package:echo_tree_flutter/logging/logger.dart';
import 'package:echo_tree_flutter/schemas/echo_tree_schema.dart';

class EchoTreeBroker {
  static final EchoTreeBroker _instance = EchoTreeBroker._internal();

  factory EchoTreeBroker() {
    return _instance;
  }

  EchoTreeBroker._internal();

  Future<void> _setTree(EchoTreeEventTree tree) async {
    var t = Database().getTreeMap.getTree(tree.treeName);
    await t.setDataMap(tree.tree);
  }

  Future<void> _clearTree(String treeName) async {
    var t = Database().getTreeMap.getTree(treeName);
    await t.clear();
  }

  Future<void> _set(List<EchoTreeEventTree> trees) async {
    List<Future> futures = [];
    for (EchoTreeEventTree tree in trees) {
      if (tree.tree.isEmpty) {
        futures.add(_clearTree(tree.treeName));
      } else {
        futures.add(_setTree(tree));
      }
    }

    await Future.wait(futures);
  }

  // broker method
  Future<void> broker(String message) async {
    try {
      EchoTreeEvent event = EchoTreeEvent.fromJson(jsonDecode(message));

      if (event.trees.isEmpty) {
        // clear all trees
        Database().getTreeMap.clear();
      } else {
        // set the trees
        await _set(event.trees);
      }
    } catch (e) {
      EchoTreeLogger().e("Error: $e");
    }
  }
}
