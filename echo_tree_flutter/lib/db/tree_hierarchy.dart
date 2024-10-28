import 'package:echo_tree_flutter/db/managed_tree/managed_tree.dart';

class TreeHierarchy {
  final ManagedTree _hierarchy;

  TreeHierarchy(String hierarchyPath) : _hierarchy = ManagedTree(hierarchyPath);

  Future<void> _initializeHierarchy({Map<String, String>? hierarchy}) async {
    if (hierarchy != null) {
      List<Future> futures = [];
      hierarchy.forEach((key, value) {
        futures.add(_hierarchy.insert(key, value));
      });
      await Future.wait(futures);
    }
  }

  Future<List<String>> getTreeMapPaths({Map<String, String>? hierarchy}) async {
    await _initializeHierarchy(hierarchy: hierarchy);
    return Future.value(_hierarchy.getDataMap().keys.toList());
  }

  Future<void> clear() async {
    return _hierarchy.clear();
  }

  Future<void> insertSchema(String treePath, String value) {
    return _hierarchy.insert(treePath, value);
  }

  Future<void> removeSchema(String treePath) {
    return _hierarchy.remove(treePath);
  }

  String getSchema(String treePath) {
    return _hierarchy.get(treePath);
  }

  void forEach(void Function(String, String) f) {
    _hierarchy.forEach(f);
  }
}
