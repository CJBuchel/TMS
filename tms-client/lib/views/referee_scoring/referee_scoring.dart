import 'package:flutter/material.dart';
import 'package:tms/views/referee_scoring/referee_scoring_footer/referee_scoring_footer.dart';
import 'package:tms/views/referee_scoring/referee_scoring_header/referee_scoring_header.dart';

class RefereeScoring extends StatelessWidget {
  const RefereeScoring({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // header
        RefereeScoringHeader(),
        // expanded scrollable list
        Expanded(
          child: ListView.builder(
            itemCount: 100,
            itemBuilder: (context, index) {
              return Container(
                child: Text('Team $index'),
              );
            },
          ),
        ),

        // footer
        RefereeScoringFooter(),
      ],
    );
  }
}
