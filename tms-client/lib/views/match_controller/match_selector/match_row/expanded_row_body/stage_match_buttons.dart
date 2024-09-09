import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/providers/robot_game_providers/game_match_status_provider.dart';

class StageMatchButtons extends StatelessWidget {
  final GameMatch match;
  final bool isStaged;

  const StageMatchButtons({
    Key? key,
    required this.match,
    required this.isStaged,
  }) : super(key: key);

  Widget _unstageButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        Provider.of<GameMatchStatusProvider>(context, listen: false).clearStagedMatches();
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
    );
  }

  Widget _stageButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        Provider.of<GameMatchStatusProvider>(context, listen: false).stageMatches([match.matchNumber]);
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: isStaged ? _unstageButton(context) : _stageButton(context),
    );
  }
}
