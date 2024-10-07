import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:tms/views/dashboard/dashboard_info_banner.dart';
import 'package:tms/views/dashboard/integrity_overview.dart';
import 'package:tms/views/dashboard/scoring_overview.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EchoTreeLifetime(
      trees: [
        ":tournament:integrity_messages",
        ":judging:sessions",
        ":robot_game:matches",
        ":robot_game:game_scores",
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // header (matches, sessions, score submissions)
              Container(
                height: 100,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: DashboardInfoBanner(),
              ),
              // event summery
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.red,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Theme.of(context).dividerColor,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: const Center(
                                    child: Text("Event summary"),
                                  ),
                                ),
                              ),
                              Expanded(flex: 1, child: IntegrityOverview()),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.blue,
                              width: 1,
                            ),
                          ),
                          child: ScoringOverview(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
