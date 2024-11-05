import 'dart:async';

import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/database_schemas/team.dart';
import 'package:tms/services/game_scoring_service.dart';
import 'package:tms/views/referee_scoring/referee_scoring_header/next_match_start_time.dart';
import 'package:tms/views/referee_scoring/referee_scoring_header/next_match_to_score.dart';
import 'package:tms/views/referee_scoring/referee_scoring_header/next_round_to_score.dart';
import 'package:tms/views/referee_scoring/referee_scoring_header/next_team_to_score.dart';
import 'package:tms/views/referee_scoring/referee_scoring_header/select_game_table.dart';

class RefereeScoringHeader extends StatefulWidget {
  final double headerHeight;
  final GameMatch? nextMatch;
  final Team? nextTeam;
  final int totalMatches;
  final int round;
  final String? table;

  const RefereeScoringHeader({
    Key? key,
    this.headerHeight = 45,
    required this.nextMatch,
    required this.nextTeam,
    required this.totalMatches,
    required this.round,
    required this.table,
  }) : super(key: key);

  @override
  State<RefereeScoringHeader> createState() => _RefereeScoringHeaderState();
}

class _RefereeScoringHeaderState extends State<RefereeScoringHeader> {
  GameScoringService _gameScoringService = GameScoringService();
  Timer? _timer;

  void _sendNotReadySignal() async {
    if (widget.table != null) {
      await _gameScoringService.sendTableNotReadySignal(widget.table!, "");
    }
  }

  void _sendStatusRequest() async {
    if (widget.table != null) {
      await _gameScoringService.sendTableReadySignal(widget.table!, widget.nextTeam?.teamNumber);
    } else {
      await _gameScoringService.sendTableNotReadySignal(widget.table!, "");
    }
  }

  @override
  void initState() {
    super.initState();

    // create a timer to send the status request every 5 seconds
    _sendStatusRequest();
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer t) {
      _sendStatusRequest();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sendNotReadySignal();
    super.dispose();
  }

  Widget _headerItem(Widget child) {
    return Expanded(
      flex: 1,
      child: Center(
        child: child,
      ),
    );
  }

  Widget _headerRow(BuildContext context) {
    double fontSize = 16;

    if (ResponsiveBreakpoints.of(context).isDesktop) {
      fontSize = 16;
    } else if (ResponsiveBreakpoints.of(context).isTablet) {
      fontSize = 12;
    } else {
      fontSize = 10;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // table name
        _headerItem(SelectGameTable(fontSize: fontSize)),
        // next team to score
        _headerItem(NextTeamToScore(nextTeam: widget.nextTeam, fontSize: fontSize)),
        // next match to score
        _headerItem(
          NextMatchToScore(
            nextMatch: widget.nextMatch,
            totalMatches: widget.totalMatches,
            fontSize: fontSize,
          ),
        ),
        // next round to score
        _headerItem(NextRoundToScore(round: widget.round, fontSize: fontSize)),
        // next match start time
        _headerItem(NextMatchTimeToScore(startTime: widget.nextMatch?.startTime, fontSize: fontSize)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.headerHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
        // bottom border only
        border: const Border(
          bottom: BorderSide(
            color: Colors.black,
            width: 1,
          ),
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          // bottomRight: Radius.circular(10),
        ),
      ),

      // row of widgets
      child: _headerRow(context),
    );
  }
}
