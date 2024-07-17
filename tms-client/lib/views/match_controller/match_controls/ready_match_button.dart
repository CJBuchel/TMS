import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/game_match_provider.dart';

class ReadyMatchButton extends StatelessWidget {
  final WidgetStateProperty<Color?> _inactiveColor = const WidgetStatePropertyAll(Colors.grey);
  final WidgetStateProperty<Color?> _backgroundColor = const WidgetStatePropertyAll(Color(0xFF2B6E2E));
  final WidgetStateProperty<Color?> _overlayColor = const WidgetStatePropertyAll(Color(0xFF388E3C));

  Widget _buttons(BuildContext context) {
    return Selector<GameMatchProvider, ({bool canReady, bool canUnready})>(
      selector: (context, provider) {
        return (
          canReady: provider.canReady,
          canUnready: provider.canUnready,
        );
      },
      builder: (context, data, _) {
        if (data.canReady) {
          return Text("Can Ready");
        } else if (data.canUnready) {
          return Text("Can Unready");
        } else {
          return Text("Can't Ready/Unready");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      margin: const EdgeInsets.all(10),

      // ready/unready button
      child: _buttons(context),
    );
  }
}
