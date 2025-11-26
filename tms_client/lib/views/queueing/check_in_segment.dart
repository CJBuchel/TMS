import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/providers/teams_provider.dart';
import 'package:tms/services/game_match_service.dart';
import 'package:tms/widgets/dialogs/snackbar_dialog.dart';

const _checkInColor = Colors.green;
const _notPlayingColor = Color(0xFFD55C00);

class CheckInSegment extends StatelessWidget {
  final String matchNumber;
  final GameMatchTable table;
  final bool isLoaded;

  const CheckInSegment({
    Key? key,
    required this.matchNumber,
    required this.table,
    required this.isLoaded,
  }) : super(key: key);

  Widget buildTeam() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Selector<TeamsProvider, String>(
        selector: (_, teamsProvider) {
          return '${table.teamNumber} | ${teamsProvider.getTeam(table.teamNumber).name}';
        },
        builder: (context, data, _) {
          return Text(
            data,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          );
        },
      ),
    );
  }

  Widget buildTable() {
    return Text(
      '${table.table}',
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check in color
    Color checkInColor;

    if (table.checkInStatus == TeamCheckInStatus.checkedIn) {
      checkInColor = _checkInColor;
    } else if (table.checkInStatus == TeamCheckInStatus.notPlaying) {
      checkInColor = _notPlayingColor;
    } else {
      checkInColor = Colors.transparent;
    }

    IconData statusIcon = Icons.hourglass_empty_outlined;
    Color statusColor = Colors.grey;

    switch (table.checkInStatus) {
      case TeamCheckInStatus.notCheckedIn:
        statusIcon = Icons.hourglass_empty_outlined;
        statusColor = Colors.grey;
        break;
      case TeamCheckInStatus.notPlaying:
        statusIcon = Icons.check_circle;
        statusColor = const Color(0xFFD55C00);
        break;
      case TeamCheckInStatus.checkedIn:
        statusIcon = Icons.check_circle_outline;
        statusColor = Colors.green;
        break;
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          GameMatchService()
              .toggleTeamCheckIn(matchNumber, table.teamNumber)
              .then(
            (status) {
              if (status != HttpStatus.ok) {
                SnackBarDialog.fromStatus(
                  message: "Team Check In: ${table.teamNumber}",
                  status: status,
                ).show(context);
              }
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 8.0,
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: checkInColor,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      buildTable(),
                      buildTeam(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
