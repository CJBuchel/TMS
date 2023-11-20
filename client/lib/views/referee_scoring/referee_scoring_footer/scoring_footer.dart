import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/utils/value_listenable_utils.dart';
import 'package:tms/views/referee_scoring/referee_scoring_footer/submission_dialog.dart';
import 'package:tms/views/referee_scoring/table_setup.dart';

class ScoringFooter extends StatelessWidget {
  // mains
  final double height;
  final ValueNotifier<Team?> nextTeamNotifier;
  final ValueNotifier<GameMatch?> nextMatchNotifier;
  final ValueNotifier<bool> lockedNotifier;

  // generic score info
  final ValueNotifier<int> scoreNotifier;
  final ValueNotifier<List<ScoreAnswer>> answersNotifier;
  final ValueNotifier<List<ScoreError>> errorsNotifier;
  final ValueNotifier<String> publicCommentNotifier;
  final ValueNotifier<String> privateCommentNotifier;

  // callbacks
  final Function() onClear;
  final Function() onSubmit;
  final Function() onNoShow;
  const ScoringFooter({
    Key? key,
    required this.height,
    required this.nextTeamNotifier,
    required this.nextMatchNotifier,
    required this.lockedNotifier,
    required this.scoreNotifier,
    required this.answersNotifier,
    required this.errorsNotifier,
    required this.publicCommentNotifier,
    required this.privateCommentNotifier,
    required this.onClear,
    required this.onSubmit,
    required this.onNoShow,
  }) : super(key: key);

  Future<bool?> showConfirmNoShow(BuildContext context) {
    return showDialog(
      context: context,
      builder: ((context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              Text(
                "Confirm No Show",
                style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text("This omits the team from the round. Are you sure?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                "Confirm",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      }),
    );
  }

  void postScoresheet(TeamGameScore scoresheet, BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ValueListenableBuilder3(
          first: nextMatchNotifier,
          second: nextTeamNotifier,
          third: lockedNotifier,
          builder: (context, nextMatch, nextTeam, locked, _) {
            return SubmissionDialog(
              nextMatch: nextMatch,
              nextTeam: nextTeam,
              locked: locked,
              scoresheet: scoresheet,
              onSubmit: () {
                onSubmit();
              },
            );
          },
        );
      },
    );
  }

  void submitScoresheet(BuildContext context) {
    if (nextMatchNotifier.value == null || nextTeamNotifier.value == null) return;
    RefereeTableUtil.getRefereeTable().then((refereeTable) {
      String gp = "";
      for (var answer in answersNotifier.value) {
        if (answer.id == "gp") {
          gp = answer.answer;
        }
      }

      // build scoresheet and send to server
      GameScoresheet innerScoresheet = GameScoresheet(
        answers: answersNotifier.value,
        privateComment: privateCommentNotifier.value,
        publicComment: publicCommentNotifier.value,
        round: nextMatchNotifier.value?.roundNumber ?? 1,
        teamId: nextTeamNotifier.value?.teamId ?? "",
        tournamentId: "", // only the server can set this
      );

      TeamGameScore scoresheet = TeamGameScore(
        cloudPublished: false,
        gp: gp,
        noShow: false,
        referee: refereeTable.referee,
        score: scoreNotifier.value,
        scoresheet: innerScoresheet,
        timeStamp: 0,
      );

      postScoresheet(scoresheet, context);
    });
  }

  void submitNoShow(BuildContext context) {
    // build scoresheet and send to server
    if (nextMatchNotifier.value == null || nextTeamNotifier.value == null) return;
    RefereeTableUtil.getRefereeTable().then((refereeTable) {
      GameScoresheet innerScoresheet = GameScoresheet(
        answers: [],
        privateComment: "",
        publicComment: "",
        round: nextMatchNotifier.value?.roundNumber ?? 1,
        teamId: nextTeamNotifier.value?.teamId ?? "",
        tournamentId: "", // only the server can set this
      );

      TeamGameScore scoresheet = TeamGameScore(
        cloudPublished: false,
        gp: "",
        noShow: true,
        referee: refereeTable.referee,
        score: 0,
        scoresheet: innerScoresheet,
        timeStamp: 0,
      );

      postScoresheet(scoresheet, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    double buttonHeight = Responsive.isDesktop(context)
        ? 40
        : Responsive.isTablet(context)
            ? 40
            : 35;
    double? fontSize = Responsive.isDesktop(context)
        ? 20
        : Responsive.isTablet(context)
            ? 16
            : null;

    // builder
    return ValueListenableBuilder3(
      first: errorsNotifier,
      second: nextMatchNotifier,
      third: nextTeamNotifier,
      builder: (context, errors, nextMatch, nextTeam, _) {
        bool isValidSubmit = errors.isEmpty && nextMatch != null && nextTeam != null;
        bool isValidNoShow = isValidSubmit;
        return Container(
          height: height,
          decoration: BoxDecoration(
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
                      child: SizedBox(
                        height: buttonHeight,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (isValidNoShow) {
                              showConfirmNoShow(context).then((confirmed) {
                                if (confirmed != null && confirmed) {
                                  submitNoShow(context);
                                }
                              });
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(isValidNoShow ? Colors.orange : Colors.grey),
                          ),
                          icon: Icon(Icons.no_accounts, size: fontSize),
                          label: Text("No Show", style: TextStyle(color: Colors.white, fontSize: fontSize)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SizedBox(
                        height: buttonHeight,
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
                      child: SizedBox(
                        height: buttonHeight,
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
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
