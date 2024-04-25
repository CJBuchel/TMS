import 'package:echo_tree_flutter/db/managed_tree.dart';
import 'package:echo_tree_flutter/db/tree_map.dart';

class TreeHierarchy {
  final ManagedTree _hierarchy;
  final String _metaDataPath;

  TreeHierarchy(
    this._metaDataPath, {
    Map<String, String>? hierarchy,
  }) : _hierarchy = ManagedTree("$_metaDataPath:hierarchy:trees");

  Future<TreeMap> openTreeMap({Map<String, String>? hierarchy}) async {
    await _hierarchy.open();

    if (hierarchy != null) {
      List<Future> futures = [];
      hierarchy.forEach((key, value) {
        futures.add(_hierarchy.insert(key, value));
      });
      await Future.wait(futures);
    }

    Map<String, String> metadataMap = _hierarchy.getAsHashmap;
    TreeMap map = TreeMap(_metaDataPath);

    List<Future> futures = [];
    metadataMap.forEach((treeName, schema) {
      if (!treeName.startsWith(_metaDataPath)) {
        futures.add(map.openTree(treeName));
      }
    });

    await Future.wait(futures);

    return map;
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
