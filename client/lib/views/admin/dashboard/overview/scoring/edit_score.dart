import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/requests/team_requests.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/shared/dashboard/match_scores/edit_score_dialog.dart';
import 'package:tms/views/shared/network_error_popup.dart';

class EditOverviewScore {
  final String teamNumber;
  final TeamGameScore gameScore;

  EditOverviewScore({
    required this.teamNumber,
    required this.gameScore,
  });

  void show(BuildContext context) {
    // request the team scoresheet
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder(
          future: getTeamRequest(teamNumber),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final res = snapshot.data!;
              if (res.item1 == HttpStatus.ok) {
                if (res.item2 != null) {
                  final t = res.item2!;
                  // find the index of the scoresheet
                  final index = t.gameScores.indexWhere((element) {
                    if (element.timeStamp == gameScore.timeStamp) {
                      if (element.scoresheet.round == gameScore.scoresheet.round) {
                        if (element.score == gameScore.score) {
                          return true;
                        }
                      }
                    }
                    return false;
                  });

                  if (index != -1) {
                    return EditScoreDialog(team: t, index: index);
                  }
                }
              } else {
                return AlertDialog(
                  title: const Text('Network Error'),
                  content: const Text('There was an error connecting to the server.'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              }
            }
            return AlertDialog(
              title: const Text('Loading...'),
              content: const LinearProgressIndicator(),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
    // display loading while waiting for the scoresheet
    // getTeamRequest(teamNumber).then((res) {
    //   if (res.item1 == HttpStatus.ok) {
    //     if (res.item2 != null) {
    //       Team t = res.item2!;
    //       // find the index of the scoresheet
    //       int index = t.gameScores.indexWhere((element) {
    //         if (element.timeStamp == gameScore.timeStamp) {
    //           if (element.scoresheet.round == gameScore.scoresheet.round) {
    //             if (element.score == gameScore.score) {
    //               return true;
    //             }
    //           }
    //         }

    //         return false;
    //       });

    //       if (index != -1) {
    //         showDialog(
    //           context: context,
    //           builder: (context) {
    //             return EditScoreDialog(team: t, index: index);
    //           },
    //         );
    //       }
    //     } else {
    //       showNetworkError(res.item1, context);
    //     }
    //   }
    // });
  }
}
