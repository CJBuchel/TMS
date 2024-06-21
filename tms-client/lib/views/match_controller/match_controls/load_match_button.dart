import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/game_match_provider.dart';

class LoadMatchButton extends StatelessWidget {
  final MaterialStateProperty<Color?> _inactiveColor = const MaterialStatePropertyAll(Colors.grey);
  final MaterialStateProperty<Color?> _backgroundColor = const MaterialStatePropertyAll(Colors.orange);
  final MaterialStateProperty<Color?> _overlayColor = const MaterialStatePropertyAll(Colors.orangeAccent);

  Widget _loadButton(BuildContext context, {bool active = true}) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: active ? _backgroundColor : _inactiveColor,
        overlayColor: active ? _overlayColor : _inactiveColor,
      ),
      onPressed: () {
        if (active) {
          Provider.of<GameMatchProvider>(context, listen: false).loadMatches();
        }
      },
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.expand_more),
          Text('Load Match'),
          Icon(Icons.expand_more),
        ],
      ),
    );
  }

  Widget _unloadButton(BuildContext context, {bool active = true}) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: active ? _backgroundColor : _inactiveColor,
        overlayColor: active ? _overlayColor : _inactiveColor,
      ),
      onPressed: () {
        if (active) {}
      },
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(Icons.expand_less),
          Text('Unload Match'),
          Icon(Icons.expand_less),
        ],
      ),
    );
  }

  // Widget _

  Widget _button(BuildContext context) {
    return Selector<GameMatchProvider, ({bool canLoad, bool canUnload})>(
      selector: (context, provider) {
        return (
          canLoad: provider.canLoad,
          canUnload: provider.canUnload,
        );
      },
      builder: (context, data, _) {
        if (data.canLoad) {
          return _loadButton(context, active: data.canLoad);
        } else if (data.canUnload) {
          return _unloadButton(context, active: data.canUnload);
        } else {
          return _loadButton(context, active: data.canLoad);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      // width: 500,
      margin: const EdgeInsets.all(10),

      // load/unload button
      child: _button(context),
    );
  }
}
