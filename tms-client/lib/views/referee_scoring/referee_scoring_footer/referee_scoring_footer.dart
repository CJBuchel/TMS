import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
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

  Widget _buttons(BuildContext context) {
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
    return Container(
      height: footerHeight,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
            ),
            child: _buttons(context),
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
  }
}
