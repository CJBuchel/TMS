// Singleton class to save data to database

import 'dart:collection';

import 'package:echo_tree_flutter/db/tree_hierarchy.dart';
import 'package:echo_tree_flutter/db/tree_map.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class Database {
  static final Database _instance = Database._internal();
  TreeHierarchy _treeHierarchy = TreeHierarchy("");
  TreeMap _treeMap = TreeMap("");

  factory Database() {
    return _instance;
  }

  Database._internal();

  void init(String path, String metadataPath, {Map<String, String>? hierarchy}) async {
    if (!kIsWeb) {
      // String path = Directory.current.path;
      // path += "/tree.kvdb";
      Hive.init(path);
    }

    _treeHierarchy = TreeHierarchy(metadataPath);
    _treeMap = await _treeHierarchy.openTreeMap(hierarchy: hierarchy);
  }

  TreeHierarchy get getTreeHierarchy => _treeHierarchy;
  TreeMap get getTreeMap => _treeMap;

  void clear() {
    _treeMap.clear();
    _treeHierarchy.clear();
  }

  void drop() {
    _treeMap.drop();
    _treeHierarchy.drop();
  }

  void addTree(String treeName, String schema) {
    _treeHierarchy.insertSchema(treeName, schema);
    _treeMap.openTree(treeName);
  }

  void removeTree(String treeName) {
    _treeHierarchy.removeSchema(treeName);
    _treeMap.removeTree(treeName);
  }

  HashMap<String, int> get getChecksums {
    HashMap<String, int> checksums = HashMap();
    _treeMap.forEach((treeName, tree) {
      checksums[treeName] = tree.getChecksum;
    });

    return checksums;
  }
}
