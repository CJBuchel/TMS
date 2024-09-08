import 'dart:async';

import 'package:echo_tree_flutter/client/network_service.dart';
import 'package:echo_tree_flutter/db/db.dart';
import 'package:echo_tree_flutter/db/managed_tree/managed_tree.dart';
import 'package:echo_tree_flutter/db/managed_tree/managed_tree_event.dart';
import 'package:echo_tree_flutter/echo_tree_flutter.dart';
import 'package:echo_tree_flutter/logging/logger.dart';
import 'package:flutter/widgets.dart';

class EchoTreeProvider<K, V> extends ChangeNotifier {
  final String tree;
  final V Function(String) fromJsonString;
  Map<K, V> items = {};

  late final StreamSubscription<ManagedTreeEvent> _eventStream;
  ManagedTree managedTree;

  EchoTreeProvider({required this.tree, required this.fromJsonString})
      : managedTree = Database().getTreeMap.getTree(tree) {
    // initial data population (if connected)
    if (EchoTreeClient().state.value == EchoTreeConnection.connected) {
      _populateData();
    }
    // add listener to check for connection (used to populate data if connection reset)
    EchoTreeClient().state.addListener(_connectedListener);
    // listen and update items in map
    _treeEventListener();
  }

  void _treeEventListener() async {
    managedTree.updateStream.listen((event) {});

    _eventStream = managedTree.updateStream.listen((event) {
      if (event.deleted) {
        items.remove(event.key as K);
      } else {
        if (event.value != null) {
          V? entry = _entryFromString(event.value as String);
          if (entry != null) items[event.key as K] = entry;
        }
      }

      // // notify listeners when the data changes
      notifyListeners();
    });
  }

  void _connectedListener() {
    if (EchoTreeClient().state.value == EchoTreeConnection.connected) {
      _populateData();
    }
  }

  V? _entryFromString(String strJson) {
    try {
      return fromJsonString(strJson);
    } catch (e) {
      EchoTreeLogger().w("Warning parsing data: $e, null entry returned");
      return null;
    }
  }

  void _populateData() {
    final rawData = managedTree.getDataMap();

    // New item map
    Map<K, V> newItems = {};
    rawData.forEach((key, value) {
      V? entry = _entryFromString(value);
      if (entry != null) {
        newItems[key as K] = entry;
      }
    });

    items = newItems;
  }

  @override
  void dispose() {
    _eventStream.cancel();
    super.dispose();
  }
}
