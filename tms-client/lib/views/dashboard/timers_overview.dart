import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tms/providers/robot_game_providers/game_match_status_provider.dart';
import 'package:tms/widgets/timers/judging_schedule_timer.dart';
import 'package:tms/widgets/timers/match_schedule_timer.dart';
import 'package:tms/widgets/timers/match_timer.dart';

class _MatchStatusData {
  bool isReady;
  bool isRunning;
  List<String> loadedMatchNumbers;

  _MatchStatusData({
    required this.isReady,
    required this.isRunning,
    required this.loadedMatchNumbers,
  });
}

class TimersOverview extends StatelessWidget {
  const TimersOverview({Key? key}) : super(key: key);

  Widget _item(Widget child) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // judging
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _item(const Text('Judging:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
              _item(const JudgingScheduleTimer(
                live: false,
                positiveStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                negativeStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              )),
              _item(const JudgingScheduleTimer(
                live: true,
                positiveStyle: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                negativeStyle: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              )),
            ],
          ),
        ),

        // Games
        Expanded(
          flex: 1,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _item(const Text('Games:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
                _item(const MatchScheduleTimer(
                  live: false,
                  positiveStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  negativeStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                )),
                _item(const MatchScheduleTimer(
                  live: true,
                  positiveStyle: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  negativeStyle: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                )),
              ],
            ),
          ),
        ),

        // actual match
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _item(const Text('Current Match:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
              _item(Selector<GameMatchStatusProvider, _MatchStatusData>(
                selector: (_, p) {
                  return _MatchStatusData(
                    isReady: p.isMatchesReady,
                    isRunning: p.isMatchesRunning,
                    loadedMatchNumbers: p.loadedMatchNumbers,
                  );
                },
                builder: (context, data, _) {
                  if (data.loadedMatchNumbers.isEmpty) {
                    return const Text(
                      'Not Loaded',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    );
                  } else {
                    Color color = data.isRunning
                        ? Colors.blue
                        : data.isReady
                            ? Colors.green
                            : Colors.red;

                    String statusText = data.isRunning
                        ? 'Running'
                        : data.isReady
                            ? 'Ready'
                            : 'Not Ready';

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Theme.of(context).dividerColor),
                            ),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            "Matches: ${data.loadedMatchNumbers.join(', ')}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              )),
              _item(const MatchTimer(
                idleStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                activeStyle: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                endgameStyle: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                stoppedStyle: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                soundEnabled: true,
              )),
            ],
          ),
        ),
      ],
    );
  }
}
