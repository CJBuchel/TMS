import 'dart:async';
import 'dart:convert';

import 'package:echo_tree_flutter/client/network_service.dart';
import 'package:echo_tree_flutter/db/db.dart';
import 'package:echo_tree_flutter/db/managed_tree.dart';
import 'package:echo_tree_flutter/echo_tree_flutter.dart';
import 'package:echo_tree_flutter/logging/logger.dart';
import 'package:flutter/widgets.dart';

class EchoTreeProvider<K, V> extends ChangeNotifier {
  final String tree;
  final V Function(dynamic) fromJson;
  Map<K, V> items = {};

  late final StreamSubscription<Map<String, dynamic>> _updatesStream;
  ManagedTree? managedTree;

  EchoTreeProvider({required this.tree, required this.fromJson}) {
    // populate data
    // _populateData();
    EchoTreeClient().state.addListener(_treeListener);
    // listen and update items
    _startListener();
  }

  void _startListener() async {
    managedTree = await Database().getTreeMap.getTree(tree);

    if (managedTree != null) {
      _updatesStream = managedTree!.updates.listen((update) {
        // EchoTreeLogger().i("updating items: $update");
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
    } else {
      EchoTreeLogger().e("Error: ManagedTree is null, the provider is not live");
    }
  }

  void _treeListener() {
    if (EchoTreeClient().state.value == EchoTreeConnection.connected) {
      _populateData();
    }
  }

  V? _entryFromData(dynamic data) {
    try {
      return fromJson(data);
    } catch (e) {
      EchoTreeLogger().w("Warning parsing data: $e, null entry returned");
      return null;
    }
  }

  void _populateData() {
    final rawData = managedTree?.getAsHashmap ?? {};
    EchoTreeLogger().i("Populating data: $rawData");

    // New item map
    Map<K, V> newItems = {};
    rawData.forEach((key, value) {
      V? entry = _entryFromData(value);
      if (entry != null) {
        newItems[key as K] = entry;
      }
    });

    items = newItems;
  }

  @override
  void dispose() {
    _updatesStream.cancel();
    super.dispose();
  }
}
