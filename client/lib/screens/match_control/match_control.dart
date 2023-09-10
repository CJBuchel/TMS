import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tms/responsive.dart';
import 'package:tms/schema/tms_schema.dart';
import 'package:tms/screens/match_control/match_control_table.dart';
import 'package:tms/screens/selector/screen_selector.dart';
import 'package:tms/screens/shared/tool_bar.dart';

class MatchControl extends StatefulWidget {
  const MatchControl({Key? key}) : super(key: key);

  @override
  _MatchControlState createState() => _MatchControlState();
}

class _MatchControlState extends State<MatchControl> {
  String? loadedMatch;

  List<Widget> _getControl() {
    return [
      const Text("Information 1"),
      const Text("Information 2"),
      ElevatedButton(onPressed: () {}, child: const Text("Button 1")),
      ElevatedButton(onPressed: () {}, child: const Text("Button 2")),
    ];
  }

  void onSelectedMatches(List<GameMatch> matches) {
    Logger().i("Selected Matches: ${matches.map((e) => e.matchNumber).toList()}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TmsToolBar(),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (!Responsive.isMobile(context)) {
            return Row(
              children: [
                SizedBox(
                  width: constraints.maxWidth / 2, // 50%
                  child: Column(
                    children: _getControl(),
                  ),
                ),
                SizedBox(
                  width: (constraints.maxWidth / 2), // 50%
                  child: MatchControlTable(
                    con: constraints,
                    onSelected: onSelectedMatches,
                    loadedMatch: loadedMatch,
                  ),
                ),
              ],
            );
          } else {
            return SizedBox(
              width: constraints.maxWidth,
              child: MatchControlTable(
                con: constraints,
                onSelected: onSelectedMatches,
                loadedMatch: loadedMatch,
              ),
            );
          }
        },
      ),
    );
  }
}
