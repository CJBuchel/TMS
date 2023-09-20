import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/requests/match_requests.dart';
import 'package:tms/requests/team_requests.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/scoring/table_setup.dart';

class ScoringFooter extends StatelessWidget {
  final double height;
  final Team? nextTeam;
  final GameMatch? nextMatch;
  final int score;
  final String publicComment;
  final String privateComment;
  final List<ScoreError> errors;
  final List<ScoreAnswer> answers;
  final Function() onClear;
  final Function() onSubmit;
  final Function() onNoShow;
  const ScoringFooter({
    Key? key,
    required this.height,
    required this.answers,
    required this.score,
    required this.publicComment,
    required this.privateComment,
    required this.errors,
    required this.onClear,
    required this.onSubmit,
    required this.onNoShow,
    this.nextMatch,
    this.nextTeam,
  }) : super(key: key);

  void showSubmitErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
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
      }),
    );
  }

  void showStatusError(BuildContext context, int status) {
    if (status == HttpStatus.badRequest) {
      showSubmitErrorDialog(context, "Server Error (400): Bad Request");
    } else if (status == HttpStatus.unauthorized) {
      showSubmitErrorDialog(context, "Server Error (401): Unauthorized");
    } else {
      showSubmitErrorDialog(context, "Server Error ($status)");
    }
  }

  void submitScoresheet(BuildContext context) {
    if (nextMatch == null || nextTeam == null) return;
    RefereeTableUtil.getRefereeTable().then((refereeTable) {
      // build scoresheet and send to server
      GameScoresheet innerScoresheet = GameScoresheet(
        answers: answers,
        privateComment: privateComment,
        publicComment: publicComment,
        round: nextMatch?.roundNumber ?? 1,
        teamId: nextTeam?.teamId ?? "",
        tournamentId: "", // only the server can set this
      );

      TeamGameScore scoresheet = TeamGameScore(
        cloudPublished: false,
        gp: answers.firstWhere((element) => element.id == "gp").answer,
        noShow: false,
        referee: refereeTable.item1,
        score: score,
        scoresheet: innerScoresheet,
      );

      // send to server
      postTeamGameScoresheetRequest(nextTeam!.teamNumber, scoresheet).then((teamSubmitStatus) {
        if (teamSubmitStatus == HttpStatus.ok) {
          // update match
          GameMatch updatedGameMatch = nextMatch!;
          if (updatedGameMatch.onTableFirst.table == refereeTable.item2) {
            updatedGameMatch.onTableFirst.scoreSubmitted = true;
          } else if (updatedGameMatch.onTableSecond.table == refereeTable.item2) {
            updatedGameMatch.onTableSecond.scoreSubmitted = true;
          } else {
            showSubmitErrorDialog(context, "This table does not match the expected table for this match");
            return;
          }

          updateMatchRequest(updatedGameMatch.matchNumber, updatedGameMatch).then((matchUpdateStatus) {
            if (matchUpdateStatus == HttpStatus.ok) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check, color: Colors.green),
                      SizedBox(width: 16),
                      Text("Scoresheet Successfully submitted", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  backgroundColor: Colors.blueGrey[800],
                ),
              );
              onSubmit();
            } else {
              showStatusError(context, matchUpdateStatus);
            }
          });
        } else {
          showStatusError(context, teamSubmitStatus);
        }
      });
    });
  }

  void submitNoShow() {
    onNoShow();
  }

  @override
  Widget build(BuildContext context) {
    bool isValidSubmit = errors.isEmpty && nextMatch != null && nextTeam != null;
    bool isValidNoShow = isValidSubmit;
    double? fontSize = Responsive.isDesktop(context)
        ? 25
        : Responsive.isTablet(context)
            ? 16
            : null;
    return Container(
      height: height,
      decoration: BoxDecoration(
        // color: AppTheme.isDarkTheme ? Colors.blueGrey[800] : Colors.white,
        color: AppTheme.isDarkTheme ? Colors.transparent : Colors.white,

        border: Border(
          top: BorderSide(color: AppTheme.isDarkTheme ? Colors.white : Colors.black),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (isValidNoShow) {}
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(isValidNoShow ? Colors.orange : Colors.grey),
                    ),
                    icon: Icon(Icons.no_accounts, size: fontSize),
                    label: Text("No Show", style: TextStyle(color: Colors.white, fontSize: fontSize)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      onClear();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                    ),
                    icon: Icon(Icons.clear, size: fontSize),
                    label: Text("Clear", style: TextStyle(color: Colors.white, fontSize: fontSize)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (isValidSubmit) {
                        submitScoresheet(context);
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(isValidSubmit ? Colors.green : Colors.grey),
                    ),
                    icon: Icon(Icons.send, size: fontSize),
                    label: Text("Submit", style: TextStyle(color: Colors.white, fontSize: fontSize)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
