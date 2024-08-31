import 'package:flutter/material.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';

class NextTeamToScore extends StatelessWidget {
  final Team? nextTeam;

  const NextTeamToScore({
    Key? key,
    this.nextTeam,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      "${nextTeam?.number} | ${nextTeam?.name}",
      style: const TextStyle(
        fontSize: 16,
        color: Colors.white,
      ),
    );
  }
}
