import 'package:echo_tree_flutter/db/managed_tree.dart';

class TreeHierarchy {
  final ManagedTree _hierarchy;

  TreeHierarchy() : _hierarchy = ManagedTree();

  Future<void> _initializeHierarchy(String metaDataTree, {Map<String, String>? hierarchy}) async {
    await _hierarchy.open(treeName: metaDataTree);

    if (hierarchy != null) {
      List<Future> futures = [];
      hierarchy.forEach((key, value) {
        futures.add(_hierarchy.insert(key, value));
      });
      await Future.wait(futures);
    }
  }

  Future<List<String>> getTreeMapNames(String metaDataTree, {Map<String, String>? hierarchy}) async {
    await _initializeHierarchy(metaDataTree, hierarchy: hierarchy);
    return Future.value(_hierarchy.getAsHashmap.keys.toList());
  }

  Future<int> clear() async {
    return _hierarchy.clear();
  }

  Future<void> drop() async {
    return _hierarchy.drop();
  }

  Future<void> open() {
    return _hierarchy.open();
  }

  Future<void> insertSchema(String tree, String value) {
    return _hierarchy.insert(tree, value);
  }

  Future<void> removeSchema(String tree) {
    return _hierarchy.remove(tree);
  }

  String getSchema(String tree) {
    return _hierarchy.get(tree);
  }

  void forEach(void Function(String, String) f) {
    _hierarchy.forEach(f);
  }
}
