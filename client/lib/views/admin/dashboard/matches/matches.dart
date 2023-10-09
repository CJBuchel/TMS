import 'package:flutter/material.dart';
import 'package:tms/views/admin/dashboard/matches/info.dart';
import 'package:tms/views/admin/dashboard/matches/match_edit_table.dart';

class Matches extends StatefulWidget {
  const Matches({Key? key}) : super(key: key);

  @override
  State<Matches> createState() => _MatchesState();
}

class _MatchesState extends State<Matches> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            // info section
            Container(
              height: 100,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey,
                    width: 2,
                  ),
                ),
              ),
              child: const Info(),
            ),

            // table section
            const Expanded(
              child: MatchEditTable(),
            ),
          ],
        );
      },
    );
  }
}
