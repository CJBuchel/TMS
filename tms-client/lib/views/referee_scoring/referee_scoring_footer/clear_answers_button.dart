import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/game_scoring_provider.dart';

class ClearAnswersButton extends StatelessWidget {
  final double buttonHeight;
  final ScrollController? scrollController;

  ClearAnswersButton({
    Key? key,
    this.buttonHeight = 40,
    this.scrollController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: buttonHeight,
      padding: const EdgeInsets.only(left: 10, right: 15),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.clear),
        onPressed: () {
          Provider.of<GameScoringProvider>(context, listen: false).resetAnswers();
          scrollController?.animateTo(
            0.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.red,
        ),
        label: const Text("Clear"),
      ),
    );
  }
}
