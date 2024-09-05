import 'package:flutter/material.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';

class NoShowButton extends StatelessWidget {
  final double buttonHeight;
  final ScrollController? scrollController;
  final Team? team;
  final GameMatch? match;

  NoShowButton({
    Key? key,
    this.buttonHeight = 40,
    this.scrollController,
    this.team,
    this.match,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // disable if team or match is null
    bool disabled = team == null || match == null;

    return Container(
      height: buttonHeight,
      padding: const EdgeInsets.only(left: 15, right: 10),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.no_accounts),
        onPressed: () {
          if (!disabled) {
            // @TODO send no show to server
          }
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: disabled ? Colors.grey : Colors.orange,
        ),
        label: const Text("No Show"),
      ),
    );
  }
}
