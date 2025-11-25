import 'package:echo_tree_flutter/widgets/echo_tree_lifetime_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/providers/robot_game_providers/game_match_provider.dart';
import 'package:tms/providers/robot_game_providers/game_match_status_provider.dart';
import 'package:tms/views/queueing/queue_card.dart';

class _QueueItemData {
  final GameMatch match;
  final List<GameMatch> loadedMatches;

  _QueueItemData({
    required this.match,
    required this.loadedMatches,
  });
}

class Queueing extends StatelessWidget {
  const Queueing({Key? key}) : super(key: key);

  Widget _matchItem(int listIndex) {
    return Selector2<GameMatchProvider, GameMatchStatusProvider,
        _QueueItemData>(
      selector: (_, gameMatchProvider, statusProvider) {
        List<GameMatch> loadedMatches =
            statusProvider.getLoadedMatches(gameMatchProvider.matches);
        return _QueueItemData(
          match: gameMatchProvider.matches[listIndex],
          loadedMatches: loadedMatches,
        );
      },
      shouldRebuild: (previous, next) => previous != next,
      builder: (context, data, _) {
        // Determine background color based on match status
        Color statusColor = Colors.blue; // Default color
        if (data.match.completed) {
          statusColor = Colors.green;
        } else if (data.loadedMatches
            .any((m) => m.matchNumber == data.match.matchNumber)) {
          statusColor = Colors.orange;
        }

        return Theme(
            data: Theme.of(context).copyWith(
              iconTheme: Theme.of(context).iconTheme.copyWith(
                    color: data.match.completed ? Colors.black : null,
                  ),
              textTheme: Theme.of(context).textTheme.apply(
                    bodyColor: data.match.completed ? Colors.black : null,
                    displayColor: data.match.completed ? Colors.black : null,
                  ),
            ),
            child: QueueCard(
              match: data.match,
              loadedMatches: data.loadedMatches,
              statusColor: statusColor,
            ));
      },
    );
  }

  Widget _matchList() {
    return Selector<GameMatchProvider, List<GameMatch>>(
      selector: (_, gameMatchProvider) => gameMatchProvider.matchesByTime,
      builder: (context, matches, _) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _matchItem(index);
                },
                childCount: matches.length,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return EchoTreeLifetime(
        trees: [
          ":robot_game:tables",
          ":robot_game:matches",
          ":robot_game:categories",
          ":teams",
        ],
        child: Column(
          children: [
            Expanded(
              child: _matchList(),
            ),
          ],
        ));
  }
}
