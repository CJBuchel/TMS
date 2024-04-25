import 'dart:convert';

import 'package:echo_tree_flutter/db/db.dart';
import 'package:echo_tree_flutter/logging/logger.dart';
import 'package:echo_tree_flutter/schemas/echoTreeSchema.dart';

class EchoTreeBroker {
  static final EchoTreeBroker _instance = EchoTreeBroker._internal();

  factory EchoTreeBroker() {
    return _instance;
  }

  EchoTreeBroker._internal();

  Future<void> _setTree(EchoTreeEventTree tree) async {
    await Database().getTreeMap?.getTree(tree.treeName).setFromHashmap(tree.tree);
  }

  Future<void> _set(List<EchoTreeEventTree> trees) async {
    List<Future> futures = [];
    for (EchoTreeEventTree tree in trees) {
      futures.add(_setTree(tree));
    }

    await Future.wait(futures);
  }

  // broker method
  Future<void> broker(String message) async {
    try {
      EchoTreeEvent event = EchoTreeEvent.fromJson(jsonDecode(message));

      if (event.trees.isEmpty) {
        // clear all trees
        Database().getTreeMap?.clear();
      } else {
        // set the trees
        await _set(event.trees);
      }
    } catch (e) {
      EchoTreeLogger().e("Error: $e");
    }
  }
}
