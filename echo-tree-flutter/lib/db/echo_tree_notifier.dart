import 'dart:async';
import 'dart:convert';

import 'package:echo_tree_flutter/db/managed_tree.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class EchoTreeNotifier<K, V> extends ChangeNotifier {
  final ManagedTree managedTree;
  final V Function(dynamic) fromJson;
  Map<K, V> items = {};

  late final StreamSubscription<Map<String, dynamic>> _updatesStream;

  EchoTreeNotifier({required this.managedTree, required this.fromJson}) {
    _populateData();
    // listen and update items
    _updatesStream = managedTree.updates.listen((update) {
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

typedef EchoTreeDetailWidgetBuilder<V> = Widget Function(BuildContext context, V? value);
typedef EchoTreeMapWidgetBuilder<K, V> = Widget Function(BuildContext context, Map<K, V> items);

class EchoTreeDetailWidget<K, V> extends StatelessWidget {
  final K detailKey;
  final EchoTreeDetailWidgetBuilder<V> builder;
  const EchoTreeDetailWidget({super.key, required this.detailKey, required this.builder});

  @override
  Widget build(BuildContext context) {
    return Selector<EchoTreeNotifier<K, V>, V?>(
      selector: (_, nt) => nt.items[detailKey],
      shouldRebuild: (previous, next) => previous != next,
      builder: (context, value, _) {
        return builder(context, value);
      },
    );
  }
}

class EchoTreeMapWidget<K, V> extends StatelessWidget {
  final EchoTreeMapWidgetBuilder<K, V> builder;
  const EchoTreeMapWidget({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return Selector<EchoTreeNotifier<K, V>, Map<K, V>>(
      selector: (_, nt) => nt.items,
      shouldRebuild: (previous, next) => previous != next,
      builder: (context, items, _) {
        return builder(context, items);
      },
    );
  }
}
