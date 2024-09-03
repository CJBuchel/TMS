import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:tms/views/referee_scoring/referee_scoring_footer/clear_answers_button.dart';
import 'package:tms/views/referee_scoring/referee_scoring_footer/floating_score.dart';
import 'package:tms/views/referee_scoring/referee_scoring_footer/no_show_button.dart';
import 'package:tms/views/referee_scoring/referee_scoring_footer/submit_answers_button.dart';

class RefereeScoringFooter extends StatelessWidget {
  final double footerHeight;

  RefereeScoringFooter({
    Key? key,
    this.footerHeight = 120,
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // (no show, clear)
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(flex: 1, child: NoShowButton(buttonHeight: buttonHeight)),
              Expanded(flex: 1, child: ClearAnswersButton(buttonHeight: buttonHeight)),
            ],
          ),
        ),

        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(flex: 1, child: SubmitAnswersButton(buttonHeight: buttonHeight)),
            ],
          ),
        ),
        // Submit
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: footerHeight,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.black,
            width: 1,
          ),
        ),
      ),
      child: _buttons(context),
    );
  }
}
