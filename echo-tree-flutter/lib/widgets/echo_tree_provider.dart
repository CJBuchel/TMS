import 'dart:async';
import 'dart:convert';

import 'package:echo_tree_flutter/db/db.dart';
import 'package:echo_tree_flutter/db/managed_tree.dart';
import 'package:echo_tree_flutter/logging/logger.dart';
import 'package:flutter/widgets.dart';

class EchoTreeProvider<K, V> extends ChangeNotifier {
  final String tree;
  final V Function(dynamic) fromJson;
  Map<K, V> items = {};

  late final StreamSubscription<Map<String, dynamic>> _updatesStream;
  ManagedTree managedTree;

  EchoTreeProvider({required this.tree, required this.fromJson}) : managedTree = Database().getTreeMap.getTree(tree) {
    _populateData();
    // listen and update items
    _updatesStream = managedTree.updates.listen((update) {
      EchoTreeLogger().i("updating items: $update");
      update.forEach((key, value) {
        if (value == null) {
          items.remove(key as K);
        } else {
          items[key as K] = fromJson(jsonDecode(value as String));
        }
      });

      // notify listeners when the data changes
      notifyListeners();
    });
  }

  void _populateData() {
    final rawData = managedTree.getAsHashmap;
    items = rawData.map((key, value) => MapEntry(key as K, fromJson(value)));
  }

  @override
  void dispose() {
    _updatesStream.cancel();
    super.dispose();
  }
}
