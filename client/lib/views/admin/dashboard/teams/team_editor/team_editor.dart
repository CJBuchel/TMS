import 'package:accordion/accordion.dart';
import 'package:flutter/material.dart';
import 'package:tms/constants.dart';
import 'package:tms/views/admin/dashboard/teams/team_editor/info_banner.dart';
import 'package:tms/views/admin/dashboard/teams/team_editor/match_scores/match_scores.dart';
import 'package:tms/views/admin/dashboard/teams/team_editor/team_general_edit.dart';

class TeamEditor extends StatelessWidget {
  final ValueNotifier<String?> selectedTeamNumber;
  const TeamEditor({
    Key? key,
    required this.selectedTeamNumber,
  }) : super(key: key);

  Widget _paddedInner(Widget child) {
    return Padding(
      padding: const EdgeInsets.all(50),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedTeamNumber,
      builder: (context, String? teamNumber, child) {
        if (teamNumber == null) {
          return const Center(
            child: Text("No Team Selected", style: TextStyle(fontSize: 30)),
          );
        } else {
          return Column(
            children: [
              // info banner
              Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: AppTheme.isDarkTheme ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                child: TeamInfoBanner(
                  teamNumber: teamNumber,
                ),
              ),

              // team settings
              Expanded(
                child: SingleChildScrollView(
                  child: _paddedInner(
                    Accordion(
                      maxOpenSections: 1,
                      children: [
                        // general settings
                        AccordionSection(
                          isOpen: true,
                          headerBackgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                          contentBackgroundColor: Theme.of(context).cardColor,
                          header: const SizedBox(
                            height: 50,
                            child: Center(
                              child: Text("General Settings"),
                            ),
                          ),
                          content: Material(
                            color: Colors.transparent,
                            child: TeamGeneralEdit(
                              teamNumber: teamNumber,
                              onTeamDelete: () {
                                selectedTeamNumber.value = null;
                              },
                              onUpdate: (t) {
                                // of there was a team number change, update the notifier
                                if (selectedTeamNumber.value != t.teamNumber) {
                                  selectedTeamNumber.value = t.teamNumber;
                                }
                              },
                            ),
                          ),
                        ),

                        // match scores
                        AccordionSection(
                          isOpen: false,
                          headerBackgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                          contentBackgroundColor: Theme.of(context).cardColor,
                          header: const SizedBox(
                            height: 50,
                            child: Center(
                              child: Text("Match Scores"),
                            ),
                          ),
                          content: Material(
                            color: Colors.transparent,
                            child: MatchScores(teamNumber: teamNumber),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
