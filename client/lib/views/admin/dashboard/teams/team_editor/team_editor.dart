import 'package:accordion/accordion.dart';
import 'package:flutter/material.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/views/admin/dashboard/teams/team_editor/info_banner.dart';
import 'package:tms/views/admin/dashboard/teams/team_editor/match_scores/match_scores.dart';
import 'package:tms/views/admin/dashboard/teams/team_editor/team_general_edit.dart';

class TeamEditor extends StatelessWidget {
  final ValueNotifier<String?> selectedTeamNumberNotifier;
  final ValueNotifier<Team?> selectedTeamNotifier;
  const TeamEditor({
    Key? key,
    required this.selectedTeamNumberNotifier,
    required this.selectedTeamNotifier,
  }) : super(key: key);

  Widget _paddedInner(Widget child) {
    return Padding(
      padding: const EdgeInsets.all(50),
      child: child,
    );
  }

  Widget _selectedTeamAutoNotifier({required Function(Team) builder}) {
    return ValueListenableBuilder(
      valueListenable: selectedTeamNotifier,
      builder: (context, Team? team, child) {
        if (team == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return builder(team);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedTeamNumberNotifier,
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
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                ),
                child: _selectedTeamAutoNotifier(builder: (t) {
                  return TeamInfoBanner(
                    team: t,
                  );
                }),
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
                            child: _selectedTeamAutoNotifier(builder: (t) {
                              return TeamGeneralEdit(
                                team: t,
                                onTeamDelete: () {
                                  selectedTeamNotifier.value = null;
                                  selectedTeamNumberNotifier.value = null;
                                },
                                onUpdate: (t) {
                                  // of there was a team number change, update the number notifier
                                  if (selectedTeamNumberNotifier.value != t.teamNumber) {
                                    selectedTeamNumberNotifier.value = t.teamNumber;
                                  }
                                },
                              );
                            }),
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
                            child: _selectedTeamAutoNotifier(builder: (t) {
                              return MatchScores(team: t);
                            }),
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
