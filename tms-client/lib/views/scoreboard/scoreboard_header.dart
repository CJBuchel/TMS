import 'package:flutter/material.dart';
import 'package:tms/widgets/buttons/live_checkbox.dart';

class ScoreboardHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: Theme.of(context).appBarTheme.backgroundColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Row(
              children: [
                const Text("Match Schedule"),
                LiveCheckbox(
                  defaultValue: false,
                ),
              ],
            ),
          ),
          Center(
            child: Row(
              children: [
                const Text("Judging Schedule"),
                LiveCheckbox(
                  defaultValue: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
