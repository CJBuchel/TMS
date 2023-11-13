import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/requests/match_requests.dart';
import 'package:tms/requests/team_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/referee_scoring/table_setup.dart';
import 'package:tms/views/shared/network_error_popup.dart';
import 'package:tuple/tuple.dart';

class SubmissionDialog extends StatelessWidget {
  final GameMatch? nextMatch;
  final Team? nextTeam;
  final bool locked;
  final TeamGameScore scoresheet;
  final Function() onSubmit;

  const SubmissionDialog({
    Key? key,
    required this.nextMatch,
    required this.nextTeam,
    required this.locked,
    required this.scoresheet,
    required this.onSubmit,
  }) : super(key: key);

  AlertDialog submitSuccessDialog(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.check, color: Colors.green),
          SizedBox(width: 10),
          Text(
            "Submit Success",
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Team ${nextTeam?.teamNumber}"),
          const Text("Scoresheet successfully submitted"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onSubmit();
          },
          child: const Text("OK"),
        ),
      ],
    );
  }

  AlertDialog submitErrorDialog(BuildContext context, String message) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning, color: Colors.red),
          SizedBox(width: 10),
          Text(
            "Submit Error",
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("OK"),
        ),
      ],
    );
  }

  AlertDialog loadingDialog(BuildContext context) {
    return const AlertDialog(
      title: Row(
        children: [
          SizedBox(width: 10),
          Text(
            "Submitting...",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
        ],
      ),
    );
  }

  Future<Tuple2<bool, int>> _postScoresheet(TeamGameScore scoresheet, BuildContext context) async {
    bool found = false;
    int status = HttpStatus.badRequest;

    await RefereeTableUtil.getRefereeTable().then((refereeTable) async {
      GameMatch updatedGameMatch = nextMatch!;
      if (locked) {
        found = false;
        for (var onTable in updatedGameMatch.matchTables) {
          if (onTable.table == refereeTable.table) {
            onTable.scoreSubmitted = true;
            found = true;
          }
        }
      }

      // send to server
      await postTeamGameScoresheetRequest(nextTeam!.teamNumber, scoresheet).then((teamSubmitStatus) async {
        if (teamSubmitStatus == HttpStatus.ok) {
          // update match
          if (locked) {
            await updateMatchRequest(updatedGameMatch.matchNumber, updatedGameMatch).then((matchUpdateStatus) {
              status = matchUpdateStatus;
            });
          } else {
            status = teamSubmitStatus;
          }
        } else {
          status = teamSubmitStatus;
        }
      });
    });

    return Tuple2(found, status);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _postScoresheet(scoresheet, context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // loading
          return loadingDialog(context);
        } else if (snapshot.hasData && snapshot.data != null) {
          if (!snapshot.data!.item1) {
            // if not found
            return submitErrorDialog(context, "This table does not match the expected table for this match");
          } else {
            // if found and status is not ok (error)
            if (snapshot.data!.item2 != HttpStatus.ok) {
              // if not ok
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pop(); // Close loading dialog
                int res = snapshot.data!.item2;
                showNetworkError(
                  res,
                  context,
                  subMessage: "Submission Error",
                );
              });
              return Container();
            } else {
              // if ok
              return submitSuccessDialog(context);
            }
          }
        } else {
          return submitErrorDialog(context, "An error occurred");
        }
      },
    );
  }
}
