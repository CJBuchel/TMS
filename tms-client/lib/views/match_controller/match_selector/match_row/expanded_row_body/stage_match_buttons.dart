import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/providers/game_match_provider.dart';

class StageMatchButtons extends StatelessWidget {
  final GameMatch match;

  const StageMatchButtons({
    Key? key,
    required this.match,
  }) : super(key: key);

  Widget _unstageButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Provider.of<GameMatchProvider>(context, listen: false).clearStagedMatches();
      },
      style: ButtonStyle(
        backgroundColor: const WidgetStatePropertyAll(Colors.white),
        overlayColor: WidgetStatePropertyAll(Colors.grey.shade200),
        splashFactory: NoSplash.splashFactory,
      ),
      icon: const Icon(
        Icons.chevron_right,
        color: Colors.blue,
      ),
      label: const Text(
        "Unstage Match",
        style: TextStyle(color: Colors.blue),
      ),
    );
  }

  Widget _stageButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Provider.of<GameMatchProvider>(context, listen: false).stageMatches([match.matchNumber]);
      },
      style: const ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(Colors.blue),
        overlayColor: WidgetStatePropertyAll(Colors.blueAccent),
        splashFactory: NoSplash.splashFactory,
      ),
      icon: const Icon(
        Icons.chevron_left,
        color: Colors.white,
      ),
      label: const Text(
        "Stage Match",
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector<GameMatchProvider, bool>(
      selector: (context, provider) {
        return provider.isMatchStaged(match.matchNumber);
      },
      builder: (context, isStaged, child) {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: isStaged ? _unstageButton(context) : _stageButton(context),
        );
      },
    );
  }
}
