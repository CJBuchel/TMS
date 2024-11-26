import 'package:flutter/material.dart';
import 'package:tms/generated/infra/database_schemas/game_match.dart';
import 'package:tms/generated/infra/database_schemas/tms_time/tms_date_time.dart';
import 'package:tms/widgets/timers/time_until.dart';

class NextMatchHeader extends StatelessWidget {
  final List<GameMatch> nextMatches;

  const NextMatchHeader({
    Key? key,
    required this.nextMatches,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      // mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // left match info/next/current
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.deepPurple[900],
              // only left border radius
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(15),
              ),
            ),
            padding: const EdgeInsets.only(
              top: 15,
              bottom: 15,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    nextMatches.map((m) => m.matchNumber).join(","),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    decoration: const ShapeDecoration(
                      color: Colors.white,
                      shape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                          topRight: Radius.circular(0),
                          bottomRight: Radius.circular(0),
                        ),
                        side: BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                    ),
                    child: const Text(
                      "Match",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // right Status time
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.pink[900],
              // only right border radius
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(15),
              ),
            ),
            padding: const EdgeInsets.only(
              top: 15,
              bottom: 15,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                    ),
                    decoration: const ShapeDecoration(
                      color: Colors.white,
                      shape: BeveledRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(0),
                          bottomLeft: Radius.circular(0),
                          topRight: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                        side: BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),
                    ),
                    child: const Text(
                      "Time",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${nextMatches.firstOrNull?.startTime.time.toString()} (",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      TimeUntil(
                        time: nextMatches.firstOrNull?.startTime ?? TmsDateTime(),
                        positiveStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        negativeStyle: const TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                        ),
                      ),
                      const Text(
                        ")",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
