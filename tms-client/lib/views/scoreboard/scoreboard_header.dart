import 'package:flutter/material.dart';
import 'package:tms/providers/local_storage_provider.dart';
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
                const Text(
                  "Match Schedule",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                LiveCheckbox(
                  defaultValue: TmsLocalStorageProvider().scoreboardShowMatchInfo,
                  onChanged: (show) => TmsLocalStorageProvider().scoreboardShowMatchInfo = show,
                ),
              ],
            ),
          ),
          Center(
            child: Row(
              children: [
                const Text(
                  "Judging Schedule",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                LiveCheckbox(
                  defaultValue: TmsLocalStorageProvider().scoreboardShowJudgingInfo,
                  onChanged: (show) => TmsLocalStorageProvider().scoreboardShowJudgingInfo = show,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
