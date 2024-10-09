import 'package:flutter/material.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';

class NextMatchInfo extends StatelessWidget {
  final List<GameMatch> nextMatches;

  const NextMatchInfo({
    Key? key,
    required this.nextMatches,
  }) : super(key: key);

  Widget _onTableItem(BuildContext context, GameMatchTable matchTable) {
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 20,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.red,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            height: 30,
            decoration: BoxDecoration(
              color: Colors.red,
              border: Border.all(
                color: Colors.red,
                width: 1,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Center(
              child: Text(
                "${matchTable.table}",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(5),
            child: Text(
              "Team ${matchTable.teamNumber}",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (nextMatches.isEmpty) {
      return const Center(
        child: Text(
          "No Matches",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      return SingleChildScrollView(
        child: Wrap(
          spacing: 10,
          runSpacing: 5,
          alignment: WrapAlignment.center,
          children: nextMatches.expand((m) {
            return m.gameMatchTables.map((t) {
              return _onTableItem(context, t);
            }).toList();
          }).toList(),
        ),
      );
    }
  }
}
