import 'package:flutter/material.dart';

class TeamsRankingHeader extends StatelessWidget {
  final int numRounds;

  const TeamsRankingHeader({Key? key, required this.numRounds}) : super(key: key);

  Widget _scoresHeader(Color? evenColor, Color? oddColor) {
    List<Widget> scoreHeaders = [];

    if (numRounds > 1) {
      scoreHeaders.add(
        Expanded(
          flex: 1,
          child: Container(
            color: oddColor,
            child: const Center(
              child: Text(
                'Best',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      );
    }

    scoreHeaders.addAll(
      List.generate(
        numRounds,
        (index) => Expanded(
          flex: 1,
          child: Container(
            color: index % 2 == 0 ? evenColor : oddColor,
            child: Center(
              child: Text(
                'Round ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );

    return Row(
      children: scoreHeaders,
    );
  }

  @override
  Widget build(BuildContext context) {
    Color? evenDarkBackground = const Color(0xFF1B6A92);
    Color? oddDarkBackground = const Color(0xFF27A07A);

    Color? evenLightBackground = const Color(0xFF9CDEFF);
    Color? oddLightBackground = const Color(0xFF81FFD7);

    Color? evenBackground = Theme.of(context).brightness == Brightness.light ? evenLightBackground : evenDarkBackground;
    Color? oddBackground = Theme.of(context).brightness == Brightness.light ? oddLightBackground : oddDarkBackground;

    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            color: oddBackground,
            child: const Center(
              child: Text(
                'Rank',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            color: evenBackground,
            child: const Center(
              child: Text(
                'Team',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: _scoresHeader(evenBackground, oddBackground),
        ),
      ],
    );
  }
}
