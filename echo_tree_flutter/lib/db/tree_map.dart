import 'dart:async';

import 'package:echo_tree_flutter/db/managed_tree/managed_tree.dart';
import 'package:echo_tree_flutter/logging/logger.dart';

class TreeMap {
  final Map<String, ManagedTree> _treeMap = {};

  void clear() async {
    List<Future> futures = [];
    _treeMap.forEach((key, tree) {
      futures.add(tree.clear());
    });

    await Future.wait(futures);
  }

  ManagedTree addTree(String treePath) {
    if (!_treeMap.containsKey(treePath)) {
      ManagedTree t = ManagedTree(treePath);
      _treeMap[treePath] = t;
      return t;
    } else {
      return _treeMap[treePath]!;
    }
  }

  void removeTree(String treePath) {
    if (_treeMap.containsKey(treePath)) {
      _treeMap[treePath]?.clear();
      _treeMap.remove(treePath);
    }
  }

  ManagedTree getTree(String treePath) {
    if (_treeMap.containsKey(treePath)) {
      return _treeMap[treePath]!;
    } else {
      EchoTreeLogger().w("Tree not found: $treePath, providing a new tree.");
      return addTree(treePath);
    }
  }

  void forEach(void Function(String, ManagedTree) f) {
    _treeMap.forEach(f);
  }

  bool get isEmpty => _treeMap.isEmpty;
}
