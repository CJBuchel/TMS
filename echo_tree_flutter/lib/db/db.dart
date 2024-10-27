// Singleton class to save data to database

import 'dart:collection';

import 'package:echo_tree_flutter/db/tree_hierarchy.dart';
import 'package:echo_tree_flutter/db/tree_map.dart';
import 'package:echo_tree_flutter/logging/logger.dart';

class Database {
  static const String METADATA_PATH = "metadata";

  static final Database _instance = Database._internal();
  final TreeHierarchy _treeHierarchy = TreeHierarchy("$METADATA_PATH:hierarchy:trees");
  final TreeMap _treeMap = TreeMap();

  factory Database() {
    return _instance;
  }

  Database._internal();

  Future<void> init({Map<String, String>? hierarchy}) async {
    List<String> trees = await _treeHierarchy.getTreeMapPaths(hierarchy: hierarchy);
    for (var treePath in trees) {
      if (treePath.startsWith(METADATA_PATH)) {
        EchoTreeLogger().w("Trees cannot have metadata reference: $treePath");
      } else {
        _treeMap.addTree(treePath);
      }
    }
  }

  TreeHierarchy get getTreeHierarchy => _treeHierarchy;
  TreeMap get getTreeMap => _treeMap;

  void clear() {
    _treeMap.clear();
    _treeHierarchy.clear();
  }

  void addTree(String treeName, String schema) {
    _treeHierarchy.insertSchema(treeName, schema);
    _treeMap.addTree(treeName);
  }

  void removeTree(String treeName) {
    _treeHierarchy.removeSchema(treeName);
    _treeMap.removeTree(treeName);
  }

  HashMap<String, int> get getChecksums {
    HashMap<String, int> checksums = HashMap();
    _treeMap.forEach((treeName, tree) {
      checksums[treeName] = tree.checksum;
    });

    return checksums;
  }
}
