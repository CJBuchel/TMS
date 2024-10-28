import 'dart:async';

import 'package:echo_tree_flutter/echo_tree_flutter.dart';
import 'package:echo_tree_flutter/logging/logger.dart';
import 'package:flutter/widgets.dart';

// Auto unsubscribe from trees when the widget is disposed
mixin EchoTreeSubscriberMixin<T extends StatefulWidget> on State<T> {
  List<String> _subscriptions = [];

  Future<void> subscribeToTrees(List<String> trees) async {
    _subscriptions.addAll(trees);
    for (var tree in trees) {
      EchoTreeClient().subscribe([tree]);
    }
  }

  Future<void> subscribeToTree(tree) async {
    subscribeToTrees([tree]);
  }

  @override
  void dispose() {
    EchoTreeClient().unsubscribe(_subscriptions);
    super.dispose();
  }
}

// wraps around existing widget and provides subscriptions to trees (pair with provider or data widgets)
class EchoTreeLifetime extends StatefulWidget {
  final List<String> trees;
  final Widget child;
  final Duration delay;
  const EchoTreeLifetime({
    super.key,
    required this.trees,
    required this.child,
    // 500ms delay by default
    this.delay = const Duration(milliseconds: 500),
  });

  @override
  State<EchoTreeLifetime> createState() => _EchoTreeLifetimeState();
}

class _EchoTreeLifetimeState extends State<EchoTreeLifetime> with EchoTreeSubscriberMixin {
  @override
  void initState() {
    super.initState();
    EchoTreeLogger().d("Subscribing to trees: ${widget.trees}");
    // microtask
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(widget.delay).then((_) => subscribeToTrees(widget.trees));
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
