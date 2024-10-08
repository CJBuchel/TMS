import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:tms/views/dashboard/dashboard_info_banner.dart';
import 'package:tms/views/dashboard/integrity_overview.dart';
import 'package:tms/views/dashboard/scoring_overview/scoring_overview.dart';
import 'package:tms/views/dashboard/timers_overview.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return EchoTreeLifetime(
      trees: [
        ":tournament:integrity_messages",
        ":judging:sessions",
        ":robot_game:matches",
        ":robot_game:game_scores",
        ":teams",
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              // header (matches, sessions, score submissions)
              SizedBox(
                height: 100,
                child: DashboardInfoBanner(),
              ),
              // event summery
              const Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          Expanded(flex: 1, child: TimersOverview()),
                          Expanded(flex: 1, child: IntegrityOverview()),
                        ],
                      ),
                    ),
                    Expanded(flex: 4, child: ScoringOverview()),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
