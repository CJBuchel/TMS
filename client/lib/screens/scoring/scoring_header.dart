import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tms/constants.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/screens/scoring/table_setup.dart';

class ScoringHeader extends StatefulWidget {
  final List<Team> teams;
  final List<GameMatch> matches;
  const ScoringHeader({Key? key, required this.teams, required this.matches}) : super(key: key);

  @override
  State<ScoringHeader> createState() => _ScoringHeaderState();
}

class _ScoringHeaderState extends State<ScoringHeader> {
  Team? _nextTeam;
  GameMatch? _nextMatch;

  void setNextTableMatch() {
    // find next match for this table that hasn't bee completed
    if (widget.matches.isEmpty || widget.teams.isEmpty) {
      return;
    }

    RefereeTableUtil.getTable().then((thisTable) {
      for (var match in widget.matches) {
        if (!match.complete && !match.gameMatchDeferred) {
          if (match.onTableFirst.table == thisTable || match.onTableSecond.table == thisTable) {
            setState(() {
              _nextTeam = widget.teams.firstWhere((team) {
                return team.teamNumber == match.onTableFirst.teamNumber || team.teamNumber == match.onTableSecond.teamNumber;
              });

              _nextMatch = match;
            });
            return;
          }
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant ScoringHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.matches != widget.matches || oldWidget.teams != widget.teams) {
      setNextTableMatch();
    }
  }

  @override
  void initState() {
    super.initState();
    setNextTableMatch();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.isDarkTheme ? Colors.white : Colors.black),
        ),
      ),
      height: Responsive.isTablet(context) ? 50 : 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            "${_nextTeam?.teamNumber} | ${_nextTeam?.teamName}",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Round: ${_nextMatch?.roundNumber}",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Match ${_nextMatch?.matchNumber}",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_horiz),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text("Switch Table"),
                onTap: () {
                  Logger().i("Switch Table");
                  RefereeTableUtil.setTable("").then((v) {
                    Navigator.popAndPushNamed(context, "/referee/table_setup");
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
