import 'package:echo_tree_flutter/db/db.dart';
import 'package:echo_tree_flutter/echo_tree_flutter.dart';
import 'package:echo_tree_flutter/logging/logger.dart';
import 'package:flutter/widgets.dart';

// Auto unsubscribe from trees when the widget is disposed
mixin EchoTreeSubscriberMixin<T extends StatefulWidget> on State<T> {
  List<String> _subscriptions = [];

  void subscribeToTrees(List<String> trees) {
    _subscriptions.addAll(trees);
    for (var tree in trees) {
      if (Database().getTreeMap.treeExists(tree)) {
        EchoTreeClient().subscribe([tree]);
        continue;
      } else {
        Database().getTreeMap.onTreeExists(tree, () {
          EchoTreeLogger().d("Tree created $tree, running sub function...");
          EchoTreeClient().subscribe([tree]);
        });
      }
    }
  }

  void subscribeToTree(tree) {
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
  const EchoTreeLifetime({super.key, required this.trees, required this.child});

  @override
  State<EchoTreeLifetime> createState() => _EchoTreeLifetimeState();
}

class _EchoTreeLifetimeState extends State<EchoTreeLifetime> with EchoTreeSubscriberMixin {
  @override
  void initState() {
    super.initState();
    EchoTreeLogger().d("Subscribing to trees: ${widget.trees}");
    subscribeToTrees(widget.trees);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
