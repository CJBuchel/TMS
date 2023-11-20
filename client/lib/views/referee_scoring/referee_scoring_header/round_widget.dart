import 'package:flutter/material.dart';
import 'package:tms/mixins/auto_subscribe.dart';
import 'package:tms/mixins/local_db_mixin.dart';
import 'package:tms/mixins/matches_local_db.dart';
import 'package:tms/schema/tms_schema.dart';

class RoundDropdownWidget extends StatefulWidget {
  final GameMatch? nextMatch;
  final Team? nextTeam;
  final ValueNotifier<bool> lockedNotifier;
  final Function(Team, GameMatch) onRoundChange;

  const RoundDropdownWidget({
    Key? key,
    required this.nextMatch,
    required this.nextTeam,
    required this.lockedNotifier,
    required this.onRoundChange,
  }) : super(key: key);

  @override
  State<RoundDropdownWidget> createState() => _RoundWidgetState();
}

class _RoundWidgetState extends State<RoundDropdownWidget> with AutoUnsubScribeMixin, LocalDatabaseMixin {
  final ValueNotifier<Event?> _eventNotifier = ValueNotifier<Event?>(null);

  set _setEvent(Event e) {
    if (_eventNotifier.value != e) {
      _eventNotifier.value = e;
    }
  }

  @override
  void initState() {
    super.initState();
    onEventUpdate((e) => _setEvent = e);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.lockedNotifier,
      builder: (context, locked, _) {
        if (locked) {
          return Text(
            "Round: ${widget.nextMatch?.roundNumber}",
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
          );
        } else {
          return ValueListenableBuilder(
            valueListenable: _eventNotifier,
            builder: (context, event, _) {
              return DropdownButton<String>(
                value: widget.nextMatch?.roundNumber.toString(),
                dropdownColor: Colors.blueGrey[800],
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    GameMatch m = MatchesLocalDB.singleDefault();
                    m.roundNumber = int.parse(newValue);
                    if (widget.nextTeam != null) widget.onRoundChange(widget.nextTeam!, m);
                  }
                },
                items: List.generate((event?.eventRounds ?? 0), (index) => index + 1).map<DropdownMenuItem<String>>((int round) {
                  return DropdownMenuItem<String>(
                    value: round.toString(),
                    child: Text(
                      "Round: $round",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  );
                }).toList(),
              );
            },
          );
        }
      },
    );
  }
}
