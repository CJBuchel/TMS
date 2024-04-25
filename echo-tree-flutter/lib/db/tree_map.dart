import 'package:echo_tree_flutter/db/managed_tree.dart';
import 'package:echo_tree_flutter/logging/logger.dart';

class TreeMap {
  final String _metaDataPath;
  final Map<String, ManagedTree> _treeMap = {};

  TreeMap(this._metaDataPath);

  void clear() async {
    List<Future> futures = [];
    _treeMap.forEach((key, tree) {
      futures.add(tree.clear());
    });

    await Future.wait(futures);
  }

  void drop() async {
    List<Future> futures = [];
    _treeMap.forEach((key, tree) {
      futures.add(tree.drop());
    });

    await Future.wait(futures);
    _treeMap.clear();
  }

  Future<void> openTree(String treeName) async {
    if (_treeMap.containsKey(treeName)) {
      EchoTreeLogger().w("Tree already open: $treeName");
      return;
    }

    if (!treeName.startsWith(_metaDataPath)) {
      _treeMap[treeName] = ManagedTree(treeName);
      await _treeMap[treeName]?.open();
    }
  }

  void removeTree(String treeName) {
    if (_treeMap.containsKey(treeName)) {
      _treeMap[treeName]?.clear();
      _treeMap[treeName]?.drop();
      _treeMap.remove(treeName);
    }
  }

  ManagedTree getTree(String treeName) {
    if (_treeMap.containsKey(treeName)) {
      return _treeMap[treeName]!;
    } else {
      return ManagedTree(treeName);
    }
  }

  void forEach(void Function(String, ManagedTree) f) {
    _treeMap.forEach(f);
  }
}
