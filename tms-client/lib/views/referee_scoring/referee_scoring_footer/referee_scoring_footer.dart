import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:tms/providers/robot_game_providers/game_table_provider.dart';
import 'package:tms/views/referee_scoring/referee_scoring_footer/clear_answers_button.dart';
import 'package:tms/views/referee_scoring/referee_scoring_footer/no_show_button.dart';
import 'package:tms/views/referee_scoring/referee_scoring_footer/submit_answers_button.dart';
import 'package:tms/widgets/game_scoring/with_next_game_scoring.dart';

class RefereeScoringFooter extends StatelessWidget {
  final double footerHeight;
  final ScrollController? scrollController;

  RefereeScoringFooter({
    Key? key,
    this.footerHeight = 120,
    this.scrollController,
  }) : super(key: key);

  Widget _buttons(BuildContext context, String table, String referee) {
    double buttonHeight = 40;

    if (ResponsiveBreakpoints.of(context).isDesktop) {
      buttonHeight = 40;
    } else if (ResponsiveBreakpoints.of(context).isTablet) {
      buttonHeight = 40;
    } else if (ResponsiveBreakpoints.of(context).isMobile) {
      buttonHeight = 35;
    }

    return WithNextGameScoring(
      builder: (context, nextMatch, nextTeam, totalMatches, round) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // (no show, clear)
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      flex: 1,
                      child: NoShowButton(
                        buttonHeight: buttonHeight,
                        scrollController: scrollController,
                        team: nextTeam,
                        match: nextMatch,
                        table: table,
                        referee: referee,
                        round: round,
                      )),
                  Expanded(
                    flex: 1,
                    child: ClearAnswersButton(
                      buttonHeight: buttonHeight,
                      scrollController: scrollController,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    flex: 1,
                    child: SubmitAnswersButton(
                      buttonHeight: buttonHeight,
                      scrollController: scrollController,
                      team: nextTeam,
                      match: nextMatch,
                      table: table,
                      referee: referee,
                      round: round,
                    ),
                  ),
                ],
              ),
            ),
            // Submit
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Selector<GameTableProvider, ({String table, String referee})>(
      selector: (context, provider) {
        return (table: provider.localGameTable, referee: provider.localReferee);
      },
      builder: (context, data, _) {
        return Container(
          height: footerHeight,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                ),
                child: _buttons(context, data.table, data.referee),
              ),
              Positioned(
                left: 118,
                right: 0,
                top: 0,
                child: Container(
                  height: 2,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
