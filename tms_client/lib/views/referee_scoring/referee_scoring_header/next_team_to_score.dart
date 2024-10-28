import 'package:flutter/material.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';

class NextTeamToScore extends StatelessWidget {
  final Team? nextTeam;
  final double fontSize;

  const NextTeamToScore({
    Key? key,
    this.nextTeam,
    this.fontSize = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      "${nextTeam?.teamNumber} | ${nextTeam?.name}",
      style: TextStyle(
        fontSize: fontSize,
        color: Colors.white,
      ),
    );
  }
}
