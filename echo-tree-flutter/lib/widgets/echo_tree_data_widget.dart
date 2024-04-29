import 'package:echo_tree_flutter/widgets/echo_tree_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

typedef EchoTreeDetailWidgetBuilder<V> = Widget Function(BuildContext context, V? value);
typedef EchoTreeMapWidgetBuilder<K, V> = Widget Function(BuildContext context, Map<K, V> items);

class EchoTreeDetailWidget<K, V> extends StatelessWidget {
  final K detailKey;
  final EchoTreeDetailWidgetBuilder<V> builder;
  const EchoTreeDetailWidget({super.key, required this.detailKey, required this.builder});

  @override
  Widget build(BuildContext context) {
    return Selector<EchoTreeProvider<K, V>, V?>(
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
    return Selector<EchoTreeProvider<K, V>, Map<K, V>>(
      selector: (_, nt) => nt.items,
      shouldRebuild: (previous, next) => previous != next,
      builder: (context, items, _) {
        return builder(context, items);
      },
    );
  }
}
